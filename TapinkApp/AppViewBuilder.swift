import SwiftUI

struct AppViewBuilder<Splash: View, MainView: View>: View {
  @Binding var route: Route
  @ViewBuilder let splash: Splash
  @ViewBuilder let mainScreen: MainView
  
  var body: some View {
    ZStack {
      switch route {
      case .splash:
        splash.transition(.opacity)
      case .mainScreen:
        mainScreen.transition(.opacity)
      }
    }
    .animation(.smooth, value: route)
    .ignoresSafeArea()
  }
}
