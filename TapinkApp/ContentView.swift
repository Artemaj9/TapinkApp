import SwiftUI

struct ContentView: View {
  
  @StateObject var vm = GameViewModel()
  @StateObject var nm = NavigationState()
  
    var body: some View {
      MainView()
        .env(vm, nm)
    }
}

#Preview {
    ContentView()
}
