import SwiftUI

extension GameViewModel {
  func level1PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.minY))
    p.closeSubpath()
    return p
  }
  
  func level2PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.maxX*0.6, y: inner.maxY - (inner.maxY - inner.minY)*0.75))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY - (inner.maxY - inner.minY)*0.75))
    p.addLine(to: CGPoint(x: inner.minX , y: inner.minY))
    p.closeSubpath()
    return p
  }
  
  func level3PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
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
  
  func level4PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
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
    
    
     p.move(to: p1)
     p.addLine(to: p1)
    p.addArc(center: center1, radius: radius1, startAngle:  atan2(p1.y - center1.y, p1.x - center1.x), endAngle: -.pi/2, clockwise: false)
    p.addArcBetween(start: p2, end: p3, radius: radius2, clockwise: false)
    p.addLine(to: p4)
    p.addArcBetween(start: p4, end: p5, radius: radius2, clockwise: false)
    p.addArcBetween(start: p5, end: p6, radius: radius1, clockwise: false)
    p.move(to: p6)
    p.addLine(to: p1)
    p.closeSubpath()
    
    return p
  }
  
  func level5PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.minY))
    p.closeSubpath()
    return p
  }
  
  func level6PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
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
  
  func level7PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    let height = inner.maxY - inner.minY
    let width = inner.maxX - inner.minX
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY + height*0.4))
    p.addLine(to: CGPoint(x: inner.minX + width*0.4, y: inner.minY + height*0.6))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY + height*0.55))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.midX, y: inner.maxY - height*0.05))
    p.addLine(to: CGPoint(x: inner.minX , y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX , y: inner.minY))
    
    p.closeSubpath()
    return p
  }
  
  func level9PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
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
    
    return scaledCopy(of:path, expandBy: 5)
  }
  
  func level8PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    p.move(to: CGPoint(x: inner.minX , y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.minY))
    p.closeSubpath()
    return p
  }
  
  func level10PlayablePath(in rect: CGRect, wallWidth: CGFloat) -> CGPath {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let p = CGMutablePath()
    let height = inner.maxY - inner.minY
    let width = inner.maxX - inner.minX
    
    p.move(to: CGPoint(x: inner.minX  , y: inner.minY + height*0.3))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.minY))
    p.addLine(to: CGPoint(x: inner.maxX, y: inner.maxY - height*0.2))
    p.addLine(to: CGPoint(x: inner.minX , y: inner.maxY))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.maxY - height*0.35))
    p.addLine(to: CGPoint(x: inner.minX + width*0.3, y: inner.minY + height*0.5))
    p.addLine(to: CGPoint(x: inner.minX, y: inner.minY + height*0.53))
    p.addLine(to: CGPoint(x: inner.minX  , y: inner.minY + height*0.3))
    
    p.closeSubpath()
    return p
  }
  
  func crossShapeLevel10(in rect: CGRect, wallWidth: CGFloat) -> (path: CGPath, pivot: CGPoint) {
    let inner = rect.insetBy(dx: wallWidth, dy: wallWidth)
    let height = inner.height
    let width  = inner.width
    let cl = width * 0.07
    let ch = height * 0.17
    
    let sx = inner.minX + width * 0.68
    let sy = inner.minY + height * 0.25
    
    let p = CGMutablePath()
    p.move(to: CGPoint(x: sx,            y: sy))
    p.addLine(to: CGPoint(x: sx + cl,    y: sy))
    p.addLine(to: CGPoint(x: sx + cl,    y: sy + ch))
    p.addLine(to: CGPoint(x: sx + cl + ch, y: sy + ch))
    p.addLine(to: CGPoint(x: sx + cl + ch, y: sy + ch + cl))
    p.addLine(to: CGPoint(x: sx + cl,    y: sy + ch + cl))
    p.addLine(to: CGPoint(x: sx + cl,    y: sy + ch + ch + cl))
    p.addLine(to: CGPoint(x: sx,         y: sy + ch + ch + cl))
    p.addLine(to: CGPoint(x: sx,         y: sy + ch + cl))
    p.addLine(to: CGPoint(x: sx - ch,    y: sy + ch + cl))
    p.addLine(to: CGPoint(x: sx - ch,    y: sy + ch))
    p.addLine(to: CGPoint(x: sx,         y: sy + ch))
    p.addLine(to: CGPoint(x: sx,         y: sy))
    p.closeSubpath()
    
    let pivot = CGPoint(x: sx + cl * 0.5, y: sy + ch + cl * 0.5)
    return (p, pivot)
  }
  
  
  func scaledCopy(of path: CGPath, expandBy delta: CGFloat) -> CGPath {
      let bb = path.boundingBoxOfPath
      guard bb.width > 0, bb.height > 0 else { return path }
      // scale so the bbox grows by ±delta on each side
      let sx = (bb.width  + 2*delta) / bb.width
      let sy = (bb.height + 2*delta) / bb.height

      var t = CGAffineTransform(translationX: -bb.midX, y: -bb.midY)
          .scaledBy(x: sx, y: sy)
          .translatedBy(x: bb.midX, y: bb.midY)
      return path.copy(using: &t) ?? path
  }
  
  func unionBaseAndScaled(base: CGPath, delta: CGFloat) -> (CGPath, CGPathFillRule) {
      let outer = scaledCopy(of: base, expandBy: delta)
      let u = CGMutablePath()
      u.addPath(base)
      u.addPath(outer)
      // use .winding so both subpaths are filled (no hole)
      return (u, .winding)
  }
}


