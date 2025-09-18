import SwiftUI

struct SizeReader: ViewModifier {
  @Binding var size: CGSize
  
  func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { geo in
          Color.clear
            .onAppear {
              size = geo.size
              print("\(size)")
            }
        }
      )
  }
}
