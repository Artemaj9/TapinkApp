import SwiftUI

struct StrokeText: ViewModifier {
  private let id = UUID()
  var strokeSize: CGFloat = 1
  var color: Color = .green

  func body(content: Content) -> some View {
    content
      .padding(strokeSize * 2)
      .background(
        Rectangle()
          .foregroundStyle(color)
          .mask {
            outline(content: content)
          }
      )
  }

  func outline(content: Content) -> some View {
    Canvas { content, size in
      content.addFilter(.alphaThreshold(min: 0.01))
      content.drawLayer { layer in
        if let text = content.resolveSymbol(id: id) {
          layer.draw(text, at: .init(x: size.width / 2, y: size.height / 2))
        }
      }
    } symbols: {
      content.tag(id)
        .blur(radius: strokeSize)
    }
  }
}
