import SwiftUI

extension Image {
  func resizableToFit() -> some View {
    resizable()
      .scaledToFit()
  }

  func resizableToFill() -> some View {
    resizable()
      .scaledToFill()
  }

  func backgroundFill() -> some View {
    resizableToFill()
      .ignoresSafeArea()
  }

  func resizableToFill(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
    resizable()
      .scaledToFill()
      .frame(width: width, height: height)
  }

  func resizableToFit(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
    resizable()
      .scaledToFit()
      .frame(width: width, height: height)
  }

  func resizableToFit(height: CGFloat) -> some View {
    resizable()
      .scaledToFit()
      .frame(height: height)
  }
}
