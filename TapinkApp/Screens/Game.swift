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
      ZStack {
//        Rectangle()
//          .fill(Color.yellow.opacity(0.8))
//          .frame(width: vm.portalRect.width, height: vm.portalRect.height)
            Image(.wirl)
          .resizableToFit(height: 1.7*vm.portalRect.height)
      }
        .position(x: vm.portalRect.midX, y: vm.portalRect.midY)
      
      // Bonus
   
        Image(.prizebox)
          .resizableToFit(height: vm.bonusRect.height*2.3)
        .position(x: vm.bonusRect.midX, y: vm.bonusRect.midY)
        .transparentIf(vm.openSkins[vm.currentLevel - 1] || vm.isArtifact)
        .animation(vm.isArtifact)
      
      Rectangle()
        .fill(Color.red.opacity(0.8))
        .frame(width: vm.movingBlockRect.width, height: vm.movingBlockRect.height)
        .position(x: vm.movingBlockRect.midX, y: vm.movingBlockRect.midY)
      
      // Big circle
      Image("ball\(vm.currentSkin)")
        .resizableToFit(height: 40)
        .scaleEffect(1 + 0.7*vm.loseAnimation)
        .position(vm.big)
        .brightness(vm.loseAnimation == 1 ? 1 : 0)
        .opacity(1 - Double(vm.loseAnimation))
        .animation(.linear(duration: 0.1), vm.loseAnimation)
        .animation(.linear(duration: 0.1), vm.big)
      
      
      Image(.moon)
        .resizableToFit(height: 30)
        .position(vm.small)
        .animation(vm.showSmall)
        .transparentIf(vm.hasWon)
      
      // Score / Win overlay
     
        
      
      
      HStack {
        Image(.timerdecor)
          .resizableToFit(height: 65)
          .overlay {
            Text("\(secondsToTimeString(Int(vm.gameTime.rounded(.up))))")
              .tapinkFont(size: 13, style: .blackHanSansRegular, color: .white)
              .yOffset(20)
          }
        Button {
          vm.isFreeze = true
          vm.freezeTime = 10
        } label: {
          Image(.freezebtn)
            .resizableToFit(height: 65)
        }
        .disabled(vm.isFreeze)
        .shadow(color: Color("#C8FFFC").opacity(vm.isFreeze ? 1 : 0), radius: 24)
        .animation(vm.isFreeze)
        
        
        Button {
          vm.isImmortal = true
          vm.immortalTime = 7
        } label: {
          Image(.shieldbtn)
            .resizableToFit(height: 65)
        }
        .disabled(vm.isImmortal)
        .shadow(color: Color("#C8FFFC").opacity(vm.isImmortal ? 1 : 0), radius: 20)
        .animation(vm.isImmortal)
        
        Image(.tapcountdecor)
          .resizableToFit(height: 65)
          .overlay {
            Text("\(vm.tapCount)")
              .tapinkFont(size: 13, style: .blackHanSansRegular, color: .white)
              .yOffset(20)
          }
      }
      .yOffset(vm.footer)
      
      ZStack {
        if vm.hasWon {
          Win()
        }
    }
      .transparentIfNot(vm.hasWon)
      .animation(vm.hasWon)
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

func secondsToTimeString(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let secs = seconds % 60
    return String(format: "%d:%02d", minutes, secs)
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
