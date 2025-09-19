import SwiftUI

struct ContentView: View {
  
  @StateObject var vm = GameViewModel()
  @StateObject var nm = NavigationState()
  
    var body: some View {
      AppViewBuilder(
        route: $vm.route,
        splash: { Splash() },
        mainScreen: { MainView() }
      )
      .env(vm, nm)
    }
}

#Preview {
    ContentView()
}
