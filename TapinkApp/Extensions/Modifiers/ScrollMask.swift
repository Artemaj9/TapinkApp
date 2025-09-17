import SwiftUI

struct ScrollMask: ViewModifier {
  var location1: Double
  var location2: Double
  var location3: Double
  var location4: Double
  
  func body(content: Content) -> some View {
    content
      .mask(
        RoundedRectangle(cornerRadius: 25)
          .fill(
            LinearGradient(
              stops: [
                .init(color: .white.opacity(0.0), location: location1),
                .init(color: .white.opacity(1.0), location: location2),
                .init(color: .white.opacity(1.0), location: location3),
                .init(color: .white.opacity(0.0), location: location4)
              ],
              startPoint: .top,
              endPoint: .bottom
            )
          )
      )
  }
}
