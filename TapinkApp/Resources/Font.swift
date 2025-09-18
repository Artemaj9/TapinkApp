import SwiftUI

enum CustomFont: String {
  case blackHanSansRegular = "Black Han Sans Regular"
}

extension Font {
  static func custom(_ font: CustomFont, size: CGFloat) -> Font {
    Font.custom(font.rawValue, size: size)
  }
}
