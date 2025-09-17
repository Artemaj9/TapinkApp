import SwiftUI

enum SelectionState: Hashable {
  case levels
  case wardrobe
  case game
}

class NavigationState: ObservableObject {
  @Published var path = [SelectionState]()
  
  func navigate(_ view: SelectionState) {
    path.append(view)
  }
  
  func goback() {
    if !path.isEmpty {
      path.removeLast()
    }
  }
  
  func popToRoot() {
    path = []
  }
}

extension View {
  func addNavigationRoutes(path: Binding<[SelectionState]>) -> some View {
    NavigationStack(path: path) {
      self.navigationDestination(for: SelectionState.self) { state in
        switch state {
        case .levels:
          Levels()
          
        case .wardrobe:
          Wardrobe()
          
        case .game:
          Game()
        }
      }
    }
  }
}
