import UIKit

extension UIImage {
  func fixedOrientation() -> UIImage {
    guard let cgImage = self.cgImage else { return self }
    if self.imageOrientation == .up {
      return self
    }
    
    var transform = CGAffineTransform.identity
    
    switch self.imageOrientation {
    case .down, .downMirrored:
      transform = transform.translatedBy(x: CGFloat(self.size.width), y: CGFloat(self.size.height))
      transform = transform.rotated(by: .pi)
    case .left, .leftMirrored:
      transform = transform.translatedBy(x: CGFloat(self.size.width), y: 0)
      transform = transform.rotated(by: .pi / 2)
    case .right, .rightMirrored:
      transform = transform.translatedBy(x: 0, y: CGFloat(self.size.height))
      transform = transform.rotated(by: -.pi / 2)
    default:
      break
    }
    
    switch self.imageOrientation {
    case .upMirrored, .downMirrored:
      transform = transform.translatedBy(x: CGFloat(self.size.width), y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    case .leftMirrored, .rightMirrored:
      transform = transform.translatedBy(x: CGFloat(self.size.height), y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    default:
      break
    }
    
    guard let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: cgImage.bitmapInfo.rawValue) else { return self }
    
    context.concatenate(transform)
    
    switch self.imageOrientation {
    case .left, .leftMirrored, .right, .rightMirrored:
      context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
    default:
      context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
    }
    
    guard let newCGImage = context.makeImage() else { return self }
    return UIImage(cgImage: newCGImage)
  }
}
