import SwiftUI

extension View {
  @inlinable nonisolated func animation<V>(_ animation: Animation? = .easeInOut, _ value: V) -> some View where V: Equatable {
    self.animation(animation, value: value)
  }
  
  @inlinable nonisolated func animation<V>(_ value: V, delay: Double = 0, _ animation: Animation? = .easeInOut) -> some View where V: Equatable {
    self.animation(animation?.delay(delay), value: value)
  }
  
  @inlinable nonisolated func springAnimation<V>( _ value: V, delay: Double = 0, _ s: Double = 20, _ d: Double =  9) -> some View where V: Equatable {
    let animation =  Animation.interpolatingSpring(stiffness: s, damping: d).delay(delay)
    return self.animation(animation, value: value)
  }
  
  @inlinable nonisolated func mask<Mask>(_ alignment: Alignment, @ViewBuilder _ mask: () -> Mask) -> some View where Mask: View {
    self.mask(alignment: alignment, mask)
  }
  
  func saturationIf(_ condition: Bool, _ initial: Double = 0, _ final: Double = 1) -> some View {
    self.saturation(condition ? final : initial)
  }
  
  func scrollMask(
    _ location1: Double = 0.09, _ location2: Double = 0.15, _ location3: Double = 0.9,
    _ location4: Double = 1
  ) -> some View {
    modifier(
      ScrollMask(
        location1: location1, location2: location2, location3: location3, location4: location4))
  }
  
  func scrollMask(_ location2: Double = 0.15, _ location3: Double = 0.9) -> some View {
    modifier(ScrollMask(location1: 0, location2: location2, location3: location3, location4: 1.0))
  }
  
  func readSize(_ size: Binding<CGSize>) -> some View {
    modifier(SizeReader(size: size))
  }
  
  func tappableBg() -> some View {
    background(Color.black.opacity(0.001))
  }
  
  func overlayMask(@ViewBuilder content: () -> some View) -> some View {
    overlay { content().mask { self } }
  }
  func superOverlay(@ViewBuilder content: () -> some View) -> some View {
    overlay {
      content().mask { self }
        .overlay(self.opacity(0.7))
        .blendMode(.lighten)
    }
  }
  
  func asButton(action: @escaping () -> Void) -> some View {
    Button {
      action()
    } label: {
      self
    }
  }
  
  func tapinkFont(size: CGFloat, style: CustomFont, color: Color) -> some View {
    return font(.custom(style, size: size))
      .foregroundStyle(color)
  }
  
  func tapinkFont(size: CGFloat, style: CustomFont, color: String) -> some View {
    return font(.custom(style, size: size))
      .foregroundStyle(Color(color))
  }
  
  func customStroke(color: Color, width: CGFloat) -> some View {
    modifier(StrokeText(strokeSize: width, color: color))
  }
  
  func env<T: ObservableObject>(_ object: T) -> some View {
    environmentObject(object)
  }
  
  func env<T: ObservableObject, U: ObservableObject>(_ object: T, _ object2: U) -> some View {
    self
      .environmentObject(object)
      .environmentObject(object2)
  }
  
  // For previews:
  var vm: some View {
    environmentObject(GameViewModel())
  }
  
  var nm: some View {
    environmentObject(NavigationState())
  }
}

extension View {
  func width(_ width: CGFloat, _ alignment: Alignment = .center) -> some View {
    frame(width: width, alignment: alignment)
  }
  
  func height(_ height: CGFloat, _ alignment: Alignment = .center) -> some View {
    frame(height: height, alignment: alignment)
  }
  
  func frame(_ width: CGFloat, _ height: CGFloat, _ alignment: Alignment = .center)
  -> some View {
    frame(width: width, height: height, alignment: alignment)
  }
  
  func hPadding() -> some View {
    padding(.horizontal)
  }
  
  func vPadding() -> some View {
    padding(.vertical)
  }
  
  func hPadding(_ horizontalPadding: CGFloat) -> some View {
    padding(.horizontal, horizontalPadding)
  }
  
  func vPadding(_ verticalPadding: CGFloat) -> some View {
    padding(.vertical, verticalPadding)
  }
  
  func lPadding() -> some View {
    padding(.leading)
  }
  
  func trPadding() -> some View {
    padding(.trailing)
  }
  
  func lPadding(_ lpadding: CGFloat) -> some View {
    padding(.leading, lpadding)
  }
  
  func trPadding(_ trailingPadding: CGFloat) -> some View {
    padding(.trailing, trailingPadding)
  }
  
  func xOffset(_ x: CGFloat) -> some View {
    offset(x: x)
  }
  
  func yOffset(_ y: CGFloat) -> some View {
    offset(y: y)
  }
  
  func xOffsetIf(_ condition: Bool, _ xOffset: CGFloat) -> some View {
    self.xOffset(condition ? xOffset : 0)
  }
  
  func yOffsetIf(_ condition: Bool, _ yOffset: CGFloat) -> some View {
    self.yOffset(condition ? yOffset : 0)
  }
  
  func xOffsetIfNot(_ condition: Bool, _ xOffset: CGFloat) -> some View {
    xOffsetIf(!condition, xOffset)
  }
  
  func yOffsetIfNot(_ condition: Bool, _ yOffset: CGFloat) -> some View {
    yOffsetIf(!condition, yOffset)
  }
  
  func offset(_ x: CGFloat, _ y: CGFloat) -> some View {
    offset(x: x, y: y)
  }
  func offset(_ s: CGVector) -> some View {
    offset(x: s.dx, y: s.dy)
  }
  
  func overlay(_ alignment: Alignment, @ViewBuilder content: () -> some View) -> some View {
    overlay(content(), alignment: alignment)
  }
  
  func background(_ alignment: Alignment, @ViewBuilder content: () -> some View) -> some View {
    background(alignment: alignment, content: content)
  }
  
  func transparentIf(_ condition: Bool) -> some View {
    opacity(condition ? 0 : 1)
  }
  
  func transparentIfNot(_ condition: Bool) -> some View {
    opacity(condition ? 1 : 0)
  }
}
