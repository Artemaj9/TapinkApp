import SwiftUI

enum CustomFont: String {
  case rubikBold = "Rubik-Bold"
  case rubikSemiBold = "Rubik-SemiBold"
  case rubikMedium = "Rubik-Medium"
  case rubikRegular = "Rubik-Regular"
  case rubikLight = "Rubik-Light"
}

extension Font {
  static func custom(_ font: CustomFont, size: CGFloat) -> Font {
    Font.custom(font.rawValue, size: size)
  }
}
