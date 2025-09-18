import SwiftUI
import MetalKit

struct MetalViewRepresentable: UIViewRepresentable {
  var effect: String
  var isTexture: Bool = false
  
  func makeUIView(context: Context) -> MTKView {
    let metalView = MagicMetalView(effect: effect, frame: .zero, isTexture: isTexture)
    return metalView
  }
  
  func updateUIView(_ uiView: MTKView, context: Context) {}
}
