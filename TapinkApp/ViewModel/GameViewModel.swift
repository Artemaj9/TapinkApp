import Combine
import SwiftUI

final class GameViewModel: ObservableObject {
  @Published var size: CGSize = .init(width: 393, height: 851)
  @Published var route: Route = .splash
  private var cancellables = Set<AnyCancellable>()
  private var freezecancellables = Set<AnyCancellable>()

  
  // MARK: - Modes
  enum SceneMode { case menu, game }
  @Published var mode: SceneMode = .menu
  private(set) var screenRect: CGRect = .zero
  private var menuStartBig: CGPoint = .zero
  @Published var openLevels = Array(repeating: false, count: 10)
  //Array(repeating: true, count: 3) + Array(repeating: false, count: 7)
  @Published var openSkins = Array(repeating: false, count: 10)
  @Published var currentLevel = 1
  @Published var currentSkin = 1
  @Published var balance = 0
  @Published var freezeTime: Double = 10
  
  @Published var isFreeze = false
  @Published var isImmortal = false
  
  @Published var isWin = false
  
  // GAMESTATS
  @Published var moves = 30
  @Published var time = 300
  @Published var isArtifact = false
  @Published var artifactScreenShown = false

  
  @Published var big: CGPoint = .zero
  @Published var small: CGPoint = .zero
  @Published var prizeCount = 0
  @Published var hasWon = false
  @Published var showSmall = true
  @Published var animationProgress: CGFloat = 0
  @Published var oldBig: CGPoint = .zero
  private var startBigPoint: CGPoint = .zero
  @Published var loseAnimation: CGFloat = 0
  
//  @Published var radius: CGFloat = 490
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
  
  // RECT MOVINGBLOCK
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
  var wallWidth: CGFloat = 4
  @Published var portalRect: CGRect = .zero
  @Published var bonusRect: CGRect = .zero
  
  func getLevelPath() -> CGPath {
    switch currentLevel {
    case 1: return  level1PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    case 2: return  level2PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    case 3: return  level3PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    case 4: return  level4PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    case 5: return  level5PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    case 6: return  level6PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    case 7: return  level7PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    case 8: return  level8PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    case 9: return  level9PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    case 10: return  level10PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    default: return  level1PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)
    }
  }
  func getPortalRect()  -> CGRect {
    let inner = gameFieldBounds.insetBy(dx: wallWidth, dy: wallWidth)
    let portalSize = CGSize(width: 50, height: 50)
    let portalMargin: CGFloat = 24
    switch currentLevel {
    case 1:
      return  CGRect(
        x: inner.minX + inner.width*0.7,
        y: inner.maxY - portalSize.height - inner.height*0.15,
        width: portalSize.width,
        height: portalSize.height
      )
    default:
      return  CGRect(
      x: inner.minX + inner.width*0.7,
      y: inner.maxY - portalSize.height - inner.height*0.3,
      width: portalSize.width,
      height: portalSize.height
    )
    }
  }
  
  func getBonusRect() -> CGRect {
    let bonusSize = CGSize(width: 40, height: 40)
    let inner = gameFieldBounds.insetBy(dx: wallWidth, dy: wallWidth)

    switch currentLevel {
    case 1: return CGRect(
      x: inner.midX - bonusSize.width / 2 + inner.width*0.2,
      y: inner.midY - bonusSize.height / 2 - inner.height*0.2,
      width: bonusSize.width,
      height: bonusSize.height
    )
      
    default: return CGRect(
      x: inner.midX - bonusSize.width / 2,
      y: inner.midY - bonusSize.height / 2,
      width: bonusSize.width,
      height: bonusSize.height
    )
    }
  }
  
  func setGameField(size: CGSize) {
    let fieldWidth = size.width //size.width * 0.9 // level 4
    let fieldHeight = size.height * 0.7
    let center = CGPoint(x: size.width / 2, y: size.height / 2)
    mode = .game
    gameFieldBounds = CGRect(
      x: center.x - fieldWidth / 2,
      y: center.y - fieldHeight / 2,
      width: fieldWidth,
      height: fieldHeight
    )
    
    gameFieldPath =  getLevelPath()
    if currentLevel == 10 {
      let cross = crossShapeLevel10(in: gameFieldBounds, wallWidth: wallWidth)
      crossBasePath = cross.path
      crossPivot    = cross.pivot
    }
    
    if currentLevel == 6 {
      let inner = gameFieldBounds.insetBy(dx: wallWidth, dy: wallWidth)
      // fixed X near top-right (like your screenshot); change if you want
      let x = inner.minX + inner.width * 0.78
      
      // compute top/bottom Y available along that X inside the path
      let span = verticalSpan(atX: x) ?? (inner.minY, inner.maxY)
      
      movingBlockTopY = span.minY + movingBlockSize / 2
      movingBlockBottomY = span.maxY - movingBlockSize / 2
      movingBlockDirection = 1
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
    startBigPoint = getBigPoint()
    
    // 2) Portal
    portalRect = getPortalRect()
    
    // 3) Bonus fixed at the center (no randomness)
    bonusRect = getBonusRect()
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
    while y <= b.maxY {
      if path.contains(CGPoint(x: x, y: y), using: .evenOdd) {
        first = first ?? y
        last = y
      } else if first != nil { break }
      y += 1
    }
    if let f = first, let l = last {
      return (f + margin, l - margin)
    }
    return nil
  }
  
  func getBigPoint() -> CGPoint {
    switch currentLevel {
    case 1: return CGPoint(x: gameFieldBounds.minX + gameFieldBounds.width*0.18, y: gameFieldBounds.minY + gameFieldBounds.height*0.2)
    default: return CGPoint(x: gameFieldBounds.minX, y: gameFieldBounds.minY)
    }
  }
  
  
  func resetGame() {
    hasWon = false
    isArtifact = false
    artifactScreenShown = false
    rotationAngle = 0
    loseAnimation = 0
    big = getBigPoint()
    updateSmallPosition()
    freezeTime = 10

 //   big = CGPoint(x: gameFieldBounds.midX + gameFieldBounds.width*0.3, y: gameFieldBounds.minY + 40)
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
    if portalRect.contains(small) || portalRect.contains(big) {
  
      withAnimation {
        big = CGPoint(x: portalRect.midX, y: portalRect.midY)
        small = big
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
        if let self {
          hasWon = true
          self.artifactScreenShown = self.isArtifact
        }
      }
    }
  }
  
  private func checkBonusCollision() {
    if bonusRect.contains(small) || bonusRect.contains(big) {
      isArtifact = true
    }
  }
  
  private func checkLoseCondition() {
    // circles must stay strictly inside the field
   //    let bigInside = gameField.contains(big)
     //let smallInside = gameField.contains(small)
    let bigInside = pointInsideField(big)
    let smallInside = pointInsideField(small) || currentLevel == 9
//    if !bigInside || !smallInside {
//      resetGame()
//    }
    
//    let bigInside   = circleInsideField(center: big, radius: bigrad)
//      let smallInside = (currentLevel == 9)
//            ? true
//    : circleInsideField(center: small, radius: smallrad)

        if !bigInside || !smallInside {
          loseAnimation = 1
          DispatchQueue.main.asyncAfter(deadline: .now() +  0.2) { [weak self] in
            self?.resetGame()
          }
          return
        }

    if (intersectsRotatingCross(center: big, radius: 10) ||
        intersectsRotatingCross(center: small, radius: 5)) && currentLevel == 10 {
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
  
  // MARK: CROSS
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
    return path.contains(p)
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

  private func tickGame() {
    guard mode == .game, !hasWon, !isRotationPaused, !artifactScreenShown else { return }
    rotationAngle += isFreeze ? 0.04 : 0.08
    crossAngle += 0.01
    updateSmallPosition()
    updateMovingBlock()
    checkLoseCondition()
    if !openSkins[currentLevel - 1] && !isArtifact {
      checkBonusCollision()
    }
    if isFreeze {
      freezeTime -= 0.016
      if freezeTime <= 0 {
        isFreeze = false
        freezeTime = 10
      }
    }
    
    checkWinCondition()
  }
  
  private func tick() {
    switch mode {
    case .menu: tickMenu()
    case .game: tickGame()
    }
  }
}


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
 func resetMenu() {
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

  

  
func circleInsideScreen(center: CGPoint, radius: CGFloat) -> Bool {
      screenRect.insetBy(dx: radius, dy: radius).contains(center)
  }

func checkLoseConditionMenu() {
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

let timings = [20, 20, 30, 30, 30, 45, 45, 45, 45, 45]
let taps = [10, 10, 15, 15, 15, 15, 15, 10, 20, 20, 20]
