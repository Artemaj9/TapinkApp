import Combine
import SwiftUI
import func AVFoundation.AVMakeRect

final class GameViewModel: ObservableObject {
  @Published var size: CGSize = .init(width: 393, height: 851)
  @Published var route: Route = .splash
  @AppStorage("isWelcome") var isWelcome = true
  private var cancellables = Set<AnyCancellable>()
  
      @Published var big: CGPoint = .zero
      @Published var small: CGPoint = .zero
      @Published var prizeCount = 0
      @Published var hasWon = false
  @Published var showSmall = true
  @Published var animationProgress: CGFloat = 0
  @Published var oldBig: CGPoint = .zero
  private var startBigPoint: CGPoint = .zero
  
  var radius: CGFloat = 50
  @Published var currentLevel = 9
      
      let orbitRadius: CGFloat = 30
      private var rotationAngle: CGFloat = 0
      private var timerCancellable: AnyCancellable?
      private var isRotationPaused = false
      
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
    gameFieldPath = level9PlayablePath(in: gameFieldBounds, wallWidth: wallWidth)//level4PlayablePath

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
          
        big = CGPoint(x: gameFieldBounds.midX + gameFieldBounds.width*0.3, y: gameFieldBounds.minY + 40)
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
      
      private func tick() {
          guard !hasWon, !isRotationPaused else { return }
        
          rotationAngle += 0.08
          updateSmallPosition()
          
          checkLoseCondition()
          checkBonusCollision()
          checkWinCondition()
      }
      
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
        let bigInside = pointInsideField(big)
         let smallInside = pointInsideField(small) || currentLevel == 9
         if !bigInside || !smallInside {
             resetGame()
         }
//          if !bigInside || !smallInside {
//              resetGame()
//          }
      }
  
  private func level1PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
      // 1) Start with the inner rectangle (inside the outer frame)
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.closeSubpath()
      return p
  }

  private func level2PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
      // 1) Start with the inner rectangle (inside the outer frame)
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.maxX*0.7, y: inner.maxY - (inner.maxY - inner.minY)*0.8))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY - (inner.maxY - inner.minY)*0.8))
    p.addLine(to: CGPoint(x: inner.minX , y: inner.minY))
    p.closeSubpath()
      return p
  }
  
  private func level3PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
      // 1) Start with the inner rectangle (inside the outer frame)
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY + 0.25*(inner.maxY - inner.minY)))
    p.addLine(to: CGPoint(x: inner.minX + 0.4*(inner.maxX - inner.minX), y: inner.minY + 0.25*(inner.maxY - inner.minY)))
    p.addLine(to: CGPoint(x: inner.minX + 0.4*(inner.maxX - inner.minX), y: inner.minY + 0.5*(inner.maxY - inner.minY)))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY + 0.5*(inner.maxY - inner.minY)))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX + 0.6*(inner.maxX - inner.minX), y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX + 0.6*(inner.maxX - inner.minX), y: inner.minY + 0.75*(inner.maxY - inner.minY)))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.minY + 0.75*(inner.maxY - inner.minY)))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.minY))
    p.closeSubpath()
      return p
  }
  
  private func level4PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
      // 1) Start with the inner rectangle (inside the outer frame)
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()

    let center1 = CGPoint(x: inner.minX + 0.25*(inner.maxX - inner.minX), y: inner.minY + 0.7*(inner.maxY - inner.minY))
    let radius1 = 0.4*(inner.maxX - inner.minX)
    let p1 = CGPoint(x: inner.minX, y: inner.minY + (inner.maxY - inner.minY)*0.6)
    let p2 = CGPoint(x: center1.x, y: center1.y - radius1)
    let p3 = CGPoint(x: inner.maxX, y: inner.minY + 0.04*(inner.maxY - inner.minY))
    let center2 = CGPoint(x: inner.minX + 0.6*(inner.maxX - inner.minX), y: inner.minY + 0.2*(inner.maxY - inner.minY))
    let radius2 = inner.maxX*0.5
    let realcenter = p.circleCenter(start: p2, end: p3, radius: radius2, clockwise: true)
    let p4 = CGPoint(x: inner.maxX, y: sqrt(radius2*radius2 - (realcenter.x-inner.maxX)*(realcenter.x-inner.maxX)) + realcenter.y)
    let p5 = CGPoint(x: realcenter.x - radius2*sin(.pi/8) , y: realcenter.y + radius2*cos(.pi/8) )
    let p6 = CGPoint(x: inner.minX, y: inner.maxY)

 
   // p.move(to: CGPoint(x: inner.minX, y: inner.minY))
  //  p.addLine(to: p1)
    p.addArc(center: center1, radius: radius1, startAngle:  atan2(p1.y - center1.y, p1.x - center1.x), endAngle: -.pi/2, clockwise: false)
    p.addArcBetween(start: p2, end: p3, radius: radius2, clockwise: false)
    p.addLine(to: p4)
    p.addArcBetween(start: p4, end: p5, radius: radius2, clockwise: false)
    p.addArcBetween(start: p5, end: p6, radius: radius1, clockwise: false)
    p.addLine(to: p1)

      return p
  }
  
  
  private func level5PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.closeSubpath()
      return p
  }
  
  
  private func level6PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    let height = inner.maxY - inner.minY
    let width = inner.maxX - inner.minX
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.midY + height*0.2))
    p.addLine(to: CGPoint(x: inner.minX + width*0.65, y: inner.midY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.midY - height*0.2))
    p.addLine(to: CGPoint(x: inner.minX , y: inner.minY))
    p.closeSubpath()
      return p
  }
  
  private func level7PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    let height = inner.maxY - inner.minY
    let width = inner.maxX - inner.minX
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY + height*0.4))
    p.addLine(to: CGPoint(x: inner.minX + width*0.35, y: inner.minY + height*0.6))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY + height*0.55))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.midX, y: inner.maxY - height*0.05))
    p.addLine(to: CGPoint(x: inner.minX , y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX , y: inner.minY))
    
    p.closeSubpath()
      return p
  }
  
  private func level9PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let height = inner.maxY - inner.minY
    let width = inner.maxX - inner.minX
    let path = CGMutablePath()
    path.move(to: CGPoint(x: 0.44249*width, y:inner.minY + 0.44811*height))
    path.addLine(to: CGPoint(x: 0.6246*width, y:inner.minY + 0.34906*height))
    path.addLine(to: CGPoint(x: 0.65176*width, y:inner.minY + 0.22759*height))
    path.addLine(to: CGPoint(x: 0.65176*width, y:inner.minY + 0.15684*height))
    path.addLine(to: CGPoint(x: 0.65176*width, y:inner.minY + 0.09316*height))
    path.addLine(to: CGPoint(x: 0.73962*width, y:inner.minY + 0.00118*height))
    path.addLine(to: CGPoint(x: 0.89297*width, y:inner.minY + 0.01533*height))
    path.addLine(to: CGPoint(x: 0.9984*width, y:inner.minY + 0.10731*height))
    path.addLine(to: CGPoint(x: 0.95208*width, y:inner.minY + 0.20637*height))
    path.addLine(to: CGPoint(x: 0.8147*width, y:inner.minY + 0.24764*height))
    path.addLine(to: CGPoint(x: 0.73962*width, y:inner.minY + 0.31722*height))
    path.addLine(to: CGPoint(x: 0.73962*width, y:inner.minY + 0.40684*height))
    path.addLine(to: CGPoint(x: 0.65176*width, y:inner.minY + 0.43632*height))
    path.addLine(to: CGPoint(x: 0.54952*width, y:inner.minY + 0.47642*height))
    path.addLine(to: CGPoint(x: 0.4984*width, y:inner.minY + 0.58373*height))
    path.addLine(to: CGPoint(x: 0.44249*width, y:inner.minY + 0.7158*height))
    path.addLine(to: CGPoint(x: 0.377*width, y:inner.minY + 0.81486*height))
    path.addLine(to: CGPoint(x: 0.29872*width, y:inner.minY + 0.93042*height))
    path.addLine(to: CGPoint(x: 0, y:inner.minY + 0.99882*height))
    path.addLine(to: CGPoint(x: 0, y:inner.minY + 0.87736*height))
    path.addLine(to: CGPoint(x: 0.19968*width, y:inner.minY + 0.83726*height))
    path.addLine(to: CGPoint(x: 0.29872*width, y:inner.minY + 0.7158*height))
    path.addLine(to: CGPoint(x: 0.377*width, y:inner.minY + 0.58373*height))
    path.addLine(to: CGPoint(x: 0.44249*width, y:inner.minY + 0.44811*height))
            path.closeSubpath()
            path.move(to: CGPoint(x: 0.44249*width, y:inner.minY + 0.44811*height))

            return path
  }
  
  func pointInsideField(_ p: CGPoint) -> Bool {
      guard let path = gameFieldPath else { return false }
      return path.contains(p, using: .evenOdd, transform: .identity)
  }
  
  private func thickSegmentPolygon(from a: CGPoint, to b: CGPoint, thickness: CGFloat) -> [CGPoint] {
      let dx = b.x - a.x, dy = b.y - a.y
      let len = max(hypot(dx, dy), 0.0001)
      // outward unit normal
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
  
  private func level8PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.closeSubpath()
      return p
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
      // quick conservative test: check corners
      let corners = [r.origin,
                     CGPoint(x: r.maxX, y: r.minY),
                     CGPoint(x: r.maxX, y: r.maxY),
                     CGPoint(x: r.minX, y: r.maxY)]
      return corners.allSatisfy { pointInsideField($0) }
  }
  
  // GAME
//  @Published var currentLevel = 1
//  @Published var big: CGPoint = .zero
//   @Published var small: CGPoint = .zero
//   @Published var prizeCount = 0
//   @Published var hasWon = false
//   
//   // MARK: - Config
//   let orbitRadius: CGFloat = 30
//   private var rotationAngle: CGFloat = 0
//   
//   // Level bounds and objects
//   private(set) var gameBounds: CGRect = .zero
//   var portalRect: CGRect = .zero
//   var bonusRect: CGRect = .zero
//   
//   // Timer
//   private var timerCancellable: AnyCancellable?
//  private var isRotationPaused = false   // 👈 new flag
//   // MARK: - Setup
//  
//  func setGameField(center: CGPoint, size: CGSize) {
//         gameField = CGRect(
//             x: center.x - size.width / 2,
//             y: center.y - size.height / 2,
//             width: size.width,
//             height: size.height
//         )
//         
//         portalRect = CGRect(
//             x: gameField.midX - 25,
//             y: gameField.maxY - 80,
//             width: 50,
//             height: 50
//         )
//         
//         bonusRect = CGRect(
//             x: gameField.midX - 20,
//             y: gameField.midY - 20,
//             width: 40,
//             height: 40
//         )
//         
//         resetGame()
//     }
//  
//  
//  
//  
//   func setGameBounds(_ bounds: CGRect) {
//       guard bounds != gameBounds else { return }
//       
//       gameBounds = bounds
//       
//       portalRect = CGRect(
//           x: bounds.midX - 25,
//           y: bounds.maxY - 80,
//           width: 50,
//           height: 50
//       )
//       
//       bonusRect = CGRect(
//           x: bounds.midX - 20,
//           y: bounds.midY - 20,
//           width: 40,
//           height: 40
//       )
//       
//       resetGame()
//   }
//   
//   func resetGame() {
//       hasWon = false
//       prizeCount = 0
//       rotationAngle = 0
//       
//       big = CGPoint(x: gameBounds.midX,
//                     y: gameBounds.midY - 150)
//       updateSmallPosition()
//   }
//   
//   // MARK: - Game loop
//   func startGameLoop() {
//       stopGameLoop()
//       timerCancellable = Timer
//           .publish(every: 0.016, on: .main, in: .common) // ~60fps
//           .autoconnect()
//           .sink { [weak self] _ in
//               self?.tick()
//           }
//   }
//   
//   func stopGameLoop() {
//       timerCancellable?.cancel()
//       timerCancellable = nil
//   }
//   
//   private func tick() {
//     guard !hasWon, !isRotationPaused else { return } // 👈 skip if paused
//       
//       rotationAngle += 0.05
//       updateSmallPosition()
//       
//       checkLoseCondition()
//       checkBonusCollision()
//       checkWinCondition()
//   }
//   
//   // MARK: - Tap handling
//   func handleTap() {
//     isRotationPaused = true
//       let dx = small.x - big.x
//       let dy = small.y - big.y
//       big = CGPoint(x: small.x + dx,
//                     y: small.y + dy)
//       updateSmallPosition()
//     DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//              self?.isRotationPaused = false
//          }
//   }
//   
//   // MARK: - Helpers
//   private func updateSmallPosition() {
//       small = CGPoint(
//           x: big.x + cos(rotationAngle) * orbitRadius,
//           y: big.y + sin(rotationAngle) * orbitRadius
//       )
//   }
//   
//   private func checkWinCondition() {
//       if portalRect.contains(small) {
//           hasWon = true
//           big = CGPoint(x: portalRect.midX, y: portalRect.midY)
//           small = big
//       }
//   }
//   
//   private func checkBonusCollision() {
//       if bonusRect.contains(small) || bonusRect.contains(big) {
//           prizeCount += 1
//           // Example: respawn bonus randomly
//           bonusRect.origin = CGPoint(
//               x: CGFloat.random(in: gameBounds.minX...(gameBounds.maxX - bonusRect.width)),
//               y: CGFloat.random(in: gameBounds.minY...(gameBounds.maxY - bonusRect.height))
//           )
//       }
//   }
//   
//   private func checkLoseCondition() {
//       if !gameBounds.contains(big) || !gameBounds.contains(small) {
//           resetGame()
//       }
//   }
//

  
  ///////////////////
//  func cancelLoadingTimer() {
//    for item in cancellables {
//      item.cancel()
//    }
//  }

//  func resetGame() {
//    cancelLoadingTimer()
//  }
  
//  @Published var big: CGPoint = .zero
//  @Published var small: CGPoint = .zero
//  @Published var prizeCount = 0
//  @Published var hasWon = false
//  
//  private var rotationAngle: CGFloat = 0
//  private var timerCancellable: AnyCancellable?
//  
//  var orbitRadius: CGFloat = 30
//  var gameBounds: CGRect = .zero
//  var portalRect: CGRect = .zero
//  var bonusRect: CGRect = .zero
//  
//  
//  func setGameBounds(_ bounds: CGRect) {
//         guard bounds != gameBounds else { return }
//         gameBounds = bounds
//         portalRect = CGRect(
//             x: bounds.midX - 25, y: bounds.maxY - 80,
//             width: 50, height: 50
//         )
//         bonusRect = CGRect(
//             x: bounds.midX - 20, y: bounds.midY - 20,
//             width: 40, height: 40
//         )
//         resetGame()
//     }
//  
//  // MARK: - Timer
//  func startGameLoop() {
//      stopGameLoop()
//      timerCancellable = Timer
//          .publish(every: 0.016, on: .main, in: .common) // ~60fps
//          .autoconnect()
//          .sink { [unowned self] _ in
//              tick()
//          }
//  }
//  
//  func stopGameLoop() {
//      timerCancellable?.cancel()
//      timerCancellable = nil
//  }
//  
//  // MARK: - Game Updates
//  private func tick() {
//      guard !hasWon else { return }
//      
//      rotationAngle += 0.05
//      updateSmallPosition()
//      
//      checkLoseCondition()
//      checkBonusCollision()
//      checkWinCondition()
//  }
//  
//  private func updateSmallPosition() {
//      small = CGPoint(
//          x: big.x + cos(rotationAngle) * orbitRadius,
//          y: big.y + sin(rotationAngle) * orbitRadius
//      )
//  }
//  
//  // MARK: - Tap
//  func handleTap() {
//      let dx = small.x - big.x
//      let dy = small.y - big.y
//      big = CGPoint(x: small.x + dx, y: small.y + dy)
//      updateSmallPosition()
//  }
//  
//  // MARK: - Conditions
//  private func checkWinCondition() {
//      if portalRect.contains(small) {
//          hasWon = true
//          big = CGPoint(x: portalRect.midX, y: portalRect.midY)
//          small = big
//      }
//  }
//  
//  private func checkBonusCollision() {
//      if bonusRect.contains(small) || bonusRect.contains(big) {
//          prizeCount += 1
//          // move bonus away after collected
//          // (example: move off-screen)
//          // Or you can randomize inside bounds
//      }
//  }
//  
//  private func checkLoseCondition() {
//      if !gameBounds.contains(big) || !gameBounds.contains(small) {
//          resetGame()
//      }
//  }
//  
//  func resetGame() {
//      hasWon = false
//      prizeCount = 0
//      big = CGPoint(x: gameBounds.midX, y: gameBounds.midY - 150)
//      rotationAngle = 0
//      updateSmallPosition()
//  }
  
  
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
    /// Adds an arc from `start` to `end` with a given `radius` and clockwise flag
//    func addArcBetween(start: CGPoint, end: CGPoint, radius: CGFloat, clockwise: Bool = true) {
//        // Compute the angle between points
//        let dx = end.x - start.x
//        let dy = end.y - start.y
//        let angle = atan2(dy, dx)
//
//        // Midpoint
//        let mid = CGPoint(x: (start.x + end.x)/2, y: (start.y + end.y)/2)
//
//        // Compute a perpendicular offset to create the "arc bulge"
//        let perpAngle = angle + (clockwise ? .pi/2 : -.pi/2)
//        let controlX = mid.x + radius * cos(perpAngle)
//        let controlY = mid.y + radius * sin(perpAngle)
//        let control = CGPoint(x: controlX, y: controlY)
//
//        // Add quadratic curve
//        self.move(to: start)
//        self.addQuadCurve(to: end, control: control)
//    }
  
  func addArcBetween(start: CGPoint, end: CGPoint, radius: CGFloat, clockwise: Bool = true) {
      let dx = end.x - start.x
      let dy = end.y - start.y
      let d = sqrt(dx*dx + dy*dy)

      // No circle possible if points are too far apart
      guard d <= 2 * radius else {
          self.move(to: start)
          self.addLine(to: end)
          return
      }

      // Midpoint
      let mid = CGPoint(x: (start.x + end.x)/2, y: (start.y + end.y)/2)

      // Distance from midpoint to center along perpendicular bisector
      let h = sqrt(max(0, radius*radius - (d/2)*(d/2)))

      // Unit vector from start→end
      let ux = dx / d
      let uy = dy / d

      // Perpendicular unit vector
      let px = -uy
      let py = ux

      // Two possible centers
      let c1 = CGPoint(x: mid.x + h * px, y: mid.y + h * py)
      let c2 = CGPoint(x: mid.x - h * px, y: mid.y - h * py)

      // Pick the correct center depending on clockwise
      let center: CGPoint
      let angle1 = atan2(start.y - c1.y, start.x - c1.x)
      let angle2 = atan2(end.y - c1.y, end.x - c1.x)
      let delta = angle2 - angle1

      // Normalize into (-π, π]
      let normalizedDelta = atan2(sin(delta), cos(delta))
      let isClockwiseFromC1 = normalizedDelta < 0

      if clockwise == isClockwiseFromC1 {
          center = c1
      } else {
          center = c2
      }

      // Start & end angles
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

      // No circle possible if distance too large
    if d > 2 * radius { return CGPoint(x: 0, y: 0) }

      // Midpoint between start and end
      let mid = CGPoint(x: (start.x + end.x)/2, y: (start.y + end.y)/2)

      // Distance from midpoint to center
      let h = sqrt(radius*radius - (d/2)*(d/2))

      // Direction perpendicular to AB
      let ux = -dy / d
      let uy = dx / d

      // Two possible centers
      let cx1 = mid.x + h * ux
      let cy1 = mid.y + h * uy

      let cx2 = mid.x - h * ux
      let cy2 = mid.y - h * uy

      return clockwise ? CGPoint(x: cx1, y: cy1) : CGPoint(x: cx2, y: cy2)
  }
}
