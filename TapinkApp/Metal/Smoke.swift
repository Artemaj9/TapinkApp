import SwiftUI

struct Smoke: View {
  var effect: String = "gradShader"//"smokeShader"
  
  var body: some View {
    ZStack {
      MetalViewRepresentable(effect: effect)
        .edgesIgnoringSafeArea(.all)
    }
  }
}

#Preview {
    Smoke()
}
