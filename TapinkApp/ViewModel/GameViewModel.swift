import Combine
import SwiftUI
import func AVFoundation.AVMakeRect

final class GameViewModel: ObservableObject {
  @Published var size: CGSize = .init(width: 393, height: 851)
  @Published var route: Route = .splash
  @AppStorage("isWelcome") var isWelcome = true
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Modes
  enum SceneMode { case menu, game }
  @Published var mode: SceneMode = .menu
  private(set) var screenRect: CGRect = .zero
  private var menuStartBig: CGPoint = .zero
  @Published var openLevels = Array(repeating: true, count: 3) + Array(repeating: false, count: 7)
  @Published var openSkins = Array(repeating: true, count: 2) +  Array(repeating: false, count: 8)
  @Published var currentLevel = 6
  @Published var currentSkin = 1
  @Published var balance = 0
  
  @Published var isWin = false

  
  @Published var big: CGPoint = .zero
  @Published var small: CGPoint = .zero
  @Published var prizeCount = 0
  @Published var hasWon = false
  @Published var showSmall = true
  @Published var animationProgress: CGFloat = 0
  @Published var oldBig: CGPoint = .zero
  private var startBigPoint: CGPoint = .zero
  @Published var loseAnimation: CGFloat = 0
  
  @Published var radius: CGFloat = 490
  @Published var bigrad: CGFloat = 25
  @Published var smallrad: CGFloat = 15
  @Published var isMenu = false
  
  let orbitRadius: CGFloat = 50
  private var rotationAngle: CGFloat = 0
  private var timerCancellable: AnyCancellable?
  private var isRotationPaused = false
  @Published var crossAngle: CGFloat = 0          // animates slowly
  private var crossBasePath: CGPath?              // unrotated cross
  private var crossPivot: CGPoint = .zero
  
  // RECT
  @Published var movingBlockRect: CGRect = .zero
  private let movingBlockSize: CGFloat = 35
  private var movingBlockTopY: CGFloat = 0
  private var movingBlockBottomY: CGFloat = 0
  private var movingBlockDirection: CGFloat = 1  // +1 down, -1 up
  private var movingBlockSpeed: CGFloat = 1.6
  
  private func updateMovingBlock() {
    guard currentLevel == 6 else { return }
    var y = movingBlockRect.midY + movingBlockSpeed * movingBlockDirection
    if y >= movingBlockBottomY {
      y = movingBlockBottomY
      movingBlockDirection = -1
    } else if y <= movingBlockTopY {
      y = movingBlockTopY
      movingBlockDirection = 1
    }
    movingBlockRect.origin.y = y - movingBlockRect.height / 2
  }
  
  // MARK: - Game field
  private(set) var gameField: CGRect = .zero
  private(set) var gameFieldPath: CGPath?
  private(set) var gameFieldBounds: CGRect = .zero
  // <- the playable shape (even-odd)
  
  // thickness of the purple "walls"
  var wallWidth: CGFloat = 4
  var portalRect: CGRect = .zero
  var bonusRect: CGRect = .zero
  
  func setGameField(size: CGSize) {
    let fieldWidth = size.width //size.width * 0.9 // level 4
    let fieldHeight = size.height * 0.7
    let center = CGPoint(x: size.width / 2, y: size.height / 2)
    
    gameFieldBounds = CGRect(
      x: center.x - fieldWidth / 2,
      y: center.y - fieldHeight / 2,
      width: fieldWidth,
      height: fieldHeight
    )
    
    // Build Level 2 shape
    //  gameFieldPath = level2PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    //  gameFieldPath = level3PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    // gameFieldPath = level4PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    gameFieldPath = level10PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)//level4PlayablePath
    let cross = crossShapeLevel10(in: gameFieldBounds, wallWidth: wallWidth)
    crossBasePath = cross.path
    crossPivot    = cross.pivot
    
    
    if currentLevel == 6 {
      let inner = gameFieldBounds.insetBy(dx: wallWidth, dy: wallWidth)
      
      // fixed X near top-right (like your screenshot); change if you want
      let x = inner.minX + inner.width * 0.78
      
      // compute top/bottom Y available along that X inside the path
      let span = verticalSpan(atX: x) ?? (inner.minY, inner.maxY)
      
      movingBlockTopY = span.minY + movingBlockSize / 2
      movingBlockBottomY = span.maxY - movingBlockSize / 2
      movingBlockDirection = 1
      
      // start at the top
      movingBlockRect = CGRect(
        x: x - movingBlockSize / 2,
        y: movingBlockTopY - movingBlockSize / 2,
        width: movingBlockSize,
        height: movingBlockSize
      )
    }
    
    // Inner playable “corridor” bounds (inside walls)
    let inner = gameFieldBounds.insetBy(dx: wallWidth, dy: wallWidth)
    
    // ---- FIXED POSITIONS ----
    
    // 1) Big circle starts at the upper/top area (tweak offset if you like)
    let startOffset: CGFloat = 160
    startBigPoint = CGPoint(x: inner.minX + 3*startOffset, y: inner.minY + startOffset)
    
    // 2) Portal fixed near the left-bottom area
    //    (kept safely inside walls by a margin)
    let portalSize = CGSize(width: 50, height: 50)
    let portalMargin: CGFloat = 24
    portalRect = CGRect(
      x: inner.minX + portalMargin,
      y: inner.maxY - portalSize.height - portalMargin,
      width: portalSize.width,
      height: portalSize.height
    )
    
    // 3) Bonus fixed at the center (no randomness)
    let bonusSize = CGSize(width: 40, height: 40)
    bonusRect = CGRect(
      x: inner.midX - bonusSize.width / 2,
      y: inner.midY - bonusSize.height / 2,
      width: bonusSize.width,
      height: bonusSize.height
    )
    
    // Now reset to use these fixed placements
    resetGame()
  }
  
  
  private func circleIntersectsRect(center: CGPoint, radius: CGFloat, rect: CGRect) -> Bool {
    // nearest point on rect to the circle center
    let nx = max(rect.minX, min(center.x, rect.maxX))
    let ny = max(rect.minY, min(center.y, rect.maxY))
    let dx = center.x - nx
    let dy = center.y - ny
    return dx*dx + dy*dy <= radius*radius
  }
  
  private func verticalSpan(atX x: CGFloat, margin: CGFloat = 4) -> (minY: CGFloat, maxY: CGFloat)? {
    guard let path = gameFieldPath else { return nil }
    let b = gameFieldBounds.insetBy(dx: wallWidth, dy: wallWidth)
    var first: CGFloat? = nil
    var last: CGFloat? = nil
    var y = b.minY
    // 1pt step is fine (runs once during setup)
    while y <= b.maxY {
      if path.contains(CGPoint(x: x, y: y), using: .evenOdd) {
        first = first ?? y
        last = y
      } else if first != nil { break }        // stop at the first continuous segment
      y += 1
    }
    if let f = first, let l = last {
      return (f + margin, l - margin)
    }
    return nil
  }
  
  //  func resetGame() {
  //      hasWon = false
  //      prizeCount = 0
  //      rotationAngle = 0
  //
  //      // Use the fixed start point set in `setGameField`
  //      big = startBigPoint
  //      updateSmallPosition()
  //  }
  
  // MARK: - Setup
  //     func setGameField(size: CGSize) {
  //        let fieldWidth = size.width * 0.9
  //        let fieldHeight = size.height * 0.7
  //        let center = CGPoint(x: size.width / 2, y: size.height / 2)
  //
  //        gameField = CGRect(
  //            x: center.x - fieldWidth / 2,
  //            y: center.y - fieldHeight / 2,
  //            width: fieldWidth,
  //            height: fieldHeight
  //        )
  //
  //        // Portal at bottom center of field
  //        portalRect = CGRect(
  //            x: gameField.midX - 25,
  //            y: gameField.maxY - 80,
  //            width: 50,
  //            height: 50
  //        )
  //
  //        // Bonus in the middle
  //        bonusRect = CGRect(
  //            x: gameField.midX - 20,
  //            y: gameField.midY - 20,
  //            width: 40,
  //            height: 40
  //        )
  //
  //        resetGame()
  //    }
  
  func resetGame() {
    hasWon = false
    prizeCount = 0
    rotationAngle = 0
//    loseAnimation = 1
    big = CGPoint(x: gameFieldBounds.midX, y: gameFieldBounds.midY)
    
 //   big = CGPoint(x: gameFieldBounds.midX + gameFieldBounds.width*0.3, y: gameFieldBounds.minY + 40)
    updateSmallPosition()
    //  stopGameLoop()
  }
  
  // MARK: - Game loop
  func startGameLoop() {
    stopGameLoop()
    timerCancellable = Timer
      .publish(every: 0.016, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in self?.tick() }
  }
  
  func stopGameLoop() {
    timerCancellable?.cancel()
    timerCancellable = nil
  }
  
//  private func tick() {
//    guard !hasWon, !isRotationPaused else { return }
//    
//    rotationAngle += 0.08
//    crossAngle += 0.01
//    updateSmallPosition()
//    updateMovingBlock()
//    checkLoseCondition()
//    checkBonusCollision()
//    checkWinCondition()
//  }
  
  // MARK: - Tap
  func handleTap() {
    isRotationPaused = true
    rotationAngle = 0
    showSmall = false
    let dx = small.x - big.x
    let dy = small.y - big.y
    //  oldBig = big
    big = CGPoint(x: small.x + dx, y: small.y + dy)
    
    updateSmallPosition()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.isRotationPaused = false
      self?.showSmall = true
    }
  }
  
  // MARK: - Helpers
  private func updateSmallPosition() {
    small = CGPoint(
      x: big.x + cos(rotationAngle) * orbitRadius,
      y: big.y + sin(rotationAngle) * orbitRadius
    )
  }
  
  private func checkWinCondition() {
    if portalRect.contains(small) {
      hasWon = true
      withAnimation {
        big = CGPoint(x: portalRect.midX, y: portalRect.midY)
      }
      small = big
    }
  }
  
  private func checkBonusCollision() {
    if bonusRect.contains(small) || bonusRect.contains(big) {
      prizeCount += 1
      // respawn inside game field
      bonusRect.origin = CGPoint(
        x: CGFloat.random(in: gameFieldBounds.minX...(gameFieldBounds.maxX - bonusRect.width)),
        y: CGFloat.random(in: gameFieldBounds.minY...(gameFieldBounds.maxY - bonusRect.height))
      )
    }
  }
  
  private func checkLoseCondition() {
    // circles must stay strictly inside the field
    //   let bigInside = gameField.contains(big)
    // let smallInside = gameField.contains(small)
//    let bigInside = pointInsideField(big)
//    let smallInside = pointInsideField(small) || currentLevel == 9
//    if !bigInside || !smallInside {
//      resetGame()
//    }
    
    let bigInside   = circleInsideField(center: big, radius: bigrad)
      let smallInside = (currentLevel == 9)
            ? true
    : circleInsideField(center: small, radius: smallrad)

        if !bigInside || !smallInside {
          loseAnimation = 1
          DispatchQueue.main.asyncAfter(deadline: .now() +  1) { [weak self] in
            self?.resetGame()
          }
          return
        }
    
    
    
    
    if intersectsRotatingCross(center: big, radius: 10) ||
        intersectsRotatingCross(center: small, radius: 5) {
      resetGame()
    }
    
    if currentLevel == 6 {
      if circleIntersectsRect(center: big, radius: 10, rect: movingBlockRect) ||
          circleIntersectsRect(center: small, radius: 5, rect: movingBlockRect) {
        resetGame()
        return
      }
    }
  }
  
  func pointInsideField(_ p: CGPoint) -> Bool {
    guard let path = gameFieldPath else { return false }
    return path.contains(p, using: .evenOdd, transform: .identity)
  }
  
  private func thickSegmentPolygon(from a: CGPoint, to b: CGPoint, thickness: CGFloat) -> [CGPoint] {
    let dx = b.x - a.x, dy = b.y - a.y
    let len = max(hypot(dx, dy), 0.0001)
    
    let nx = -dy / len, ny = dx / len
    let ox = nx * thickness * 0.5
    let oy = ny * thickness * 0.5
    return [
      CGPoint(x: a.x + ox, y: a.y + oy),
      CGPoint(x: b.x + ox, y: b.y + oy),
      CGPoint(x: b.x - ox, y: b.y - oy),
      CGPoint(x: a.x - ox, y: a.y - oy)
    ]
  }
  
  func handleTap(at point: CGPoint) {
    guard pointInsideField(point) else { return }
    
    isRotationPaused = true
    rotationAngle = 0
    showSmall = false
    
    let dx = small.x - big.x
    let dy = small.y - big.y
    big = CGPoint(x: small.x + dx, y: small.y + dy)
    
    updateSmallPosition()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
      self?.isRotationPaused = false
      self?.showSmall = true
    }
  }
  
  private func rectInsideField(_ r: CGRect) -> Bool {
    let corners = [r.origin,
                   CGPoint(x: r.maxX, y: r.minY),
                   CGPoint(x: r.maxX, y: r.maxY),
                   CGPoint(x: r.minX, y: r.maxY)]
    return corners.allSatisfy { pointInsideField($0) }
  }
  
  
  func rotatedCrossPath() -> CGPath? {
    guard let base = crossBasePath else { return nil }
    var t = CGAffineTransform.identity
    t = t.translatedBy(x:  crossPivot.x, y:  crossPivot.y)
    t = t.rotated(by: crossAngle)
    t = t.translatedBy(x: -crossPivot.x, y: -crossPivot.y)
    return base.copy(using: &t)
  }
  
  func pointInsideCross(_ p: CGPoint) -> Bool {
    guard let path = rotatedCrossPath() else { return false }
    return path.contains(p) // filled cross
  }
  
  private func intersectsRotatingCross(center: CGPoint, radius: CGFloat) -> Bool {
    guard let cross = rotatedCrossPath() else { return false }
    if cross.contains(center) { return true }
    
    let halo = cross.copy(strokingWithWidth: radius * 2,
                          lineCap: .round, lineJoin: .round, miterLimit: 10)
    return halo.contains(center)
  }
  
  // MARK: Route
  func hideSplash() {
    route = .mainScreen
  }
  
  // MARK: - Layout
  var h: CGFloat {
    size.height
  }
  
  var w: CGFloat {
    size.width
  }
  
  var header: CGFloat {
    isSEight ? -size.height * 0.4 + 52 : -size.height * 0.4
  }
  
  var footer: CGFloat {
    isSEight ? size.height*0.41 - 60 : size.height*0.41
  }
  
  var isEightPlus: Bool {
    return size.width > 405 && size.height < 910 && size.height > 880
    && UIDevice.current.name != "iPhone 11 Pro Max"
  }
  
  var isElevenProMax: Bool {
    UIDevice.current.name == "iPhone 11 Pro Max"
  }
  
  var isIpad: Bool {
    UIDevice.current.name.contains("iPad")
  }
  
  var isSE: Bool {
    return size.width < 380
  }
  
  var isSEight: Bool {
    return isSE || isEightPlus
  }
}

extension CGPoint {
  func distance(to point: CGPoint) -> CGFloat {
    let dx = point.x - x
    let dy = point.y - y
    return sqrt(dx*dx + dy*dy)
  }
}

extension CGMutablePath {
  func addArcBetween(start: CGPoint, end: CGPoint, radius: CGFloat, clockwise: Bool = true) {
      let dx = end.x - start.x
      let dy = end.y - start.y
      let d = sqrt(dx*dx + dy*dy)

      guard d <= 2 * radius else {
          self.move(to: start)
          self.addLine(to: end)
          return
      }

      let mid = CGPoint(x: (start.x + end.x)/2, y: (start.y + end.y)/2)
      let h = sqrt(max(0, radius*radius - (d/2)*(d/2)))

      let ux = dx / d
      let uy = dy / d

      let px = -uy
      let py = ux

      let c1 = CGPoint(x: mid.x + h * px, y: mid.y + h * py)
      let c2 = CGPoint(x: mid.x - h * px, y: mid.y - h * py)

      let center: CGPoint
      let angle1 = atan2(start.y - c1.y, start.x - c1.x)
      let angle2 = atan2(end.y - c1.y, end.x - c1.x)
      let delta = angle2 - angle1

      let normalizedDelta = atan2(sin(delta), cos(delta))
      let isClockwiseFromC1 = normalizedDelta < 0

      if clockwise == isClockwiseFromC1 {
          center = c1
      } else {
          center = c2
      }

      let startAngle =  Double(atan2(start.y - center.y, start.x - center.x))
      let endAngle   =  Double(atan2(end.y - center.y, end.x - center.x))

      self.move(to: start)
      self.addArc(center: center,
                  radius: radius,
                  startAngle: startAngle,
                  endAngle: endAngle,
                  clockwise: clockwise)
  }
  
  func circleCenter(start: CGPoint, end: CGPoint, radius: CGFloat, clockwise: Bool = true) -> CGPoint {
      let dx = end.x - start.x
      let dy = end.y - start.y
      let d = sqrt(dx*dx + dy*dy)

    if d > 2 * radius { return CGPoint(x: 0, y: 0) }
      let mid = CGPoint(x: (start.x + end.x)/2, y: (start.y + end.y)/2)
      let h = sqrt(radius*radius - (d/2)*(d/2))

      let ux = -dy / d
      let uy = dx / d

      let cx1 = mid.x + h * ux
      let cy1 = mid.y + h * uy

      let cx2 = mid.x - h * ux
      let cy2 = mid.y - h * uy

      return clockwise ? CGPoint(x: cx1, y: cy1) : CGPoint(x: cx2, y: cy2)
  }
}

private extension CGRect { var center: CGPoint { .init(x: midX, y: midY) } }

extension GameViewModel {
  func circleInsideField(center: CGPoint, radius: CGFloat) -> Bool {
      guard let path = gameFieldPath else { return false }
      guard path.contains(center, using: .evenOdd) else { return false }

      let halo = path.copy(strokingWithWidth: radius * 2,
                           lineCap: .round, lineJoin: .round, miterLimit: 10)

      return !halo.contains(center)
  }
}

// MENU SETUP
extension GameViewModel {
  func setMenuScene(size: CGSize) {
      mode = .menu
      screenRect = CGRect(origin: .zero, size: size)

      // pick a nice start, tweak as you like
      menuStartBig = CGPoint(x: size.width * 0.5, y: size.height * 0.5)

      rotationAngle = 0
      isRotationPaused = false
      hasWon = false
      prizeCount = 0

      big = menuStartBig
      updateSmallPosition()
  }

  // Only used by menu
  private func resetMenu() {
      big =  CGPoint(x: screenRect.midX, y: screenRect.midY)
      rotationAngle = 0
     loseAnimation = 0
      updateSmallPosition()
  }

  // Handle background tap in menu
  func handleMenuTap() {
      guard mode == .menu else { return }

      isRotationPaused = true
      rotationAngle = 0
      showSmall = false

      // same “teleport forward” logic
      let dx = small.x - big.x
      let dy = small.y - big.y
      big = CGPoint(x: small.x + dx, y: small.y + dy)
      updateSmallPosition()

  
    DispatchQueue.main.asyncAfter(deadline: .now() +  0.2) { [weak self] in
          self?.isRotationPaused = false
          self?.showSmall = true
      }
  }

  // Reuse your timer, but keep menu simple (no obstacles/field checks)
  private func tickMenu() {
      guard mode == .menu, !isRotationPaused else { return }
      rotationAngle += 0.05
      updateSmallPosition()
    checkLoseConditionMenu()
  }

  
  private func tickGame() {
    guard mode == .game, !hasWon, !isRotationPaused else { return }
    rotationAngle += 0.08
    crossAngle += 0.01
    updateSmallPosition()
    updateMovingBlock()
    checkLoseCondition()
    checkBonusCollision()
    checkWinCondition()
  }
  
  private func tick() {
    switch mode {
    case .menu: tickMenu()
    case .game: tickGame()
    }
  }
  
  private func circleInsideScreen(center: CGPoint, radius: CGFloat) -> Bool {
      screenRect.insetBy(dx: radius, dy: radius).contains(center)
  }

  private func checkLoseConditionMenu() {
      guard mode == .menu else { return }

      let bigOK   = circleInsideScreen(center: big,   radius: bigrad)   // e.g. 10
      let smallOK = circleInsideScreen(center: small, radius: smallrad) // e.g. 5

      guard bigOK && smallOK else {
        loseAnimation = 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
              self?.resetMenu()
          }
          return
      }
  }
}
