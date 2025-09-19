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
func circleThrough(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint,
                   epsilon: CGFloat = 1e-9) -> (center: CGPoint, radius: CGFloat) {
    let x1 = a.x, y1 = a.y
    let x2 = b.x, y2 = b.y
    let x3 = c.x, y3 = c.y

    // Determinant (twice the oriented area of triangle ABC)
    let d = 2 * (x1*(y2 - y3) + x2*(y3 - y1) + x3*(y1 - y2))
  if abs(d) < epsilon { return (.zero, .zero) } // collinear or too close

    // Squared lengths
    let s1 = x1*x1 + y1*y1
    let s2 = x2*x2 + y2*y2
    let s3 = x3*x3 + y3*y3

    // Circumcenter formulas
    let ux = (s1*(y2 - y3) + s2*(y3 - y1) + s3*(y1 - y2)) / d
    let uy = (s1*(x3 - x2) + s2*(x1 - x3) + s3*(x2 - x1)) / d
    let center = CGPoint(x: ux, y: uy)

    // Radius = distance center→any point
    let dx = x1 - ux, dy = y1 - uy
    let r = CGFloat(hypot(dx, dy))

    return (center, r)
}
