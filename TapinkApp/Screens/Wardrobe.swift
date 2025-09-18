import SwiftUI

struct Wardrobe: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationState
  @State private var startAnimation = false
  
  var body: some View {
    ZStack {
      Image(.bg)
        .backgroundFill()
      Smoke()
        .opacity(startAnimation ? 0.9 : 0)
        .animation(.easeInOut(duration: 1), startAnimation)
      Image(.bg)
        .backgroundFill()
        .opacity(startAnimation ? 0.75 : 0)
        .animation(.easeInOut(duration: 2), startAnimation)
    }
    .navigationBarBackButtonHidden()
    .onAppear {
      startAnimation = true
    }
  }
}

#Preview {
    Wardrobe()
    .vm
    .nm
}
