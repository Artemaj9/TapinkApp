@preconcurrency import SwiftUI

struct Game: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationState
  
  var body: some View {
    ZStack {
      // Background
      Color.black.ignoresSafeArea()
      if let path = vm.gameFieldPath {
        FieldShape(path: path)
          .fill(.black, style: FillStyle(eoFill: true))      // playable area
        FieldShape(path: path)
          .stroke(.purple, lineWidth: vm.wallWidth)       // walls outline (optional)
      }
      
      if let cross = vm.rotatedCrossPath() {
        FieldShape(path: cross)
          .fill(.red.opacity(0.4))
      }
      // Portal
      Rectangle()
        .fill(Color.yellow.opacity(0.8))
        .frame(width: vm.portalRect.width, height: vm.portalRect.height)
        .position(x: vm.portalRect.midX, y: vm.portalRect.midY)
      
      // Bonus
      Rectangle()
        .fill(Color.purple.opacity(0.8))
        .frame(width: vm.bonusRect.width, height: vm.bonusRect.height)
        .position(x: vm.bonusRect.midX, y: vm.bonusRect.midY)
      
      Rectangle()
        .fill(Color.red.opacity(0.8))
        .frame(width: vm.movingBlockRect.width, height: vm.movingBlockRect.height)
        .position(x: vm.movingBlockRect.midX, y: vm.movingBlockRect.midY)
      
      // Big circle
      Circle()
        .fill(Color.blue)
        .frame(width: 20, height: 20)
        .position(vm.big)
      
      
      Circle()
        .fill(Color.red)
        .frame(width: 10, height: 10)
        .position(vm.small)
        .animation(vm.showSmall)
      
      // Score / Win overlay
      VStack {
        HStack {
          Text("🎁 \(vm.prizeCount)")
            .foregroundColor(.white)
            .padding()
          Spacer()
        }
        Spacer()
        if vm.hasWon {
          Text("YOU WIN!")
            .font(.largeTitle)
            .foregroundColor(.green)
            .padding()
        }
      }
    }
    .onAppear {
      let bounds = CGRect(origin: .zero, size: vm.size)
      vm.setGameField(size: vm.size)
      vm.startGameLoop()
    }
    .onDisappear {
      vm.stopGameLoop()
    }
    .contentShape(Rectangle())
    .coordinateSpace(name: "game")
    .gesture(DragGesture(minimumDistance: 0)
      .onEnded { value in
        vm.handleTap(at: value.location)
      }
    )
    .navigationBarBackButtonHidden()
  }
}


#Preview {
  Game()
    .vm
    .nm
}

struct FieldShape: Shape {
    let path: CGPath
    func path(in rect: CGRect) -> Path { Path(path) }
}
