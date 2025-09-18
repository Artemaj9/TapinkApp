import SwiftUI

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

extension CGRect { var center: CGPoint { .init(x: midX, y: midY) } }
