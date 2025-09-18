import SwiftUI

struct CircleWave: View {
  var effect: String = "circleShader"
  
  var body: some View {
    ZStack {
      MetalViewRepresentable(effect: effect)
        .edgesIgnoringSafeArea(.all)
    }
  }
}

#Preview {
  CircleWave()
}
