

import SwiftUI

struct Splash: View {
  @EnvironmentObject var vm: GameViewModel
  
  var body: some View {
    ZStack {
      Image(.splash)
        .backgroundFill()
        .readSize($vm.size) // эта штука нужна!
      
      SplashView()
    }
    .task {
      try? await Task.sleep(nanoseconds: NSEC_PER_SEC*5) // 0.1 секунды
      withAnimation { vm.hideSplash() } // можно вызвать из любого места, чтобы спрятать Splash
    }
  }
}

#Preview {
    Splash()
    .vm
}
