

import SwiftUI

struct Splash: View {
  @EnvironmentObject var vm: GameViewModel
  
  var body: some View {
    ZStack {
      Image(.splash)
        .backgroundFill()
        .readSize($vm.size)
      
     // SplashView()
    }
    .task {
      try? await Task.sleep(nanoseconds: NSEC_PER_SEC/10)
      withAnimation { vm.hideSplash() }
    }
  }
}

#Preview {
    Splash()
    .vm
}
