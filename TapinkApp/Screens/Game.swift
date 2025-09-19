@preconcurrency import SwiftUI

struct Game: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationState
  
  var body: some View {
    ZStack {
     Color("#35084E").ignoresSafeArea()
    
      HStack {
        Image(.balancebggame)
          .resizableToFit(height: 28)
          .overlay(.leading) {
            Image(.coin)
              .resizableToFit(height: 32)
          }
          .overlay {
            Text("\(vm.balance)")
              .tapinkFont(size: 15, style: .blackHanSansRegular, color: .white)
            
          }
        Spacer()
        Button {
          nm.path = []
          vm.resetGame()
        } label: {
          Image(.xbtn)
            .resizableToFit(height: 40)
        }
      }
      .yOffset(vm.header)
      .hPadding(30)
      if vm.currentLevel == 9 {
        Image(.coolbg)
          .resizableToFit()
          .scaleEffect(1.3)
          .yOffset(vm.h*0.1)
      }
      
      Group {
        if let path = vm.gameFieldPath {
            FieldShape(path: path)
              .fill( ImagePaint(image: .init(.gamefieldbg)), style: FillStyle(eoFill: true))
       //   }
          
          FieldShape(path: path)
            .stroke(.purple, lineWidth: vm.wallWidth)       // walls outline (optional)
        }
      }
       
      
      if let cross = vm.rotatedCrossPath() {
        FieldShape(path: cross)
          .fill(.red.opacity(0.4))
      }
      
      ForEach(Array(vm.movingRects5Frames.enumerated()), id: \.offset) { _, r in
        Image(.redobst)
          .resizableToFit(width: r.height*1.3)
              .frame(width: r.width, height: r.height)
              .position(x: r.midX, y: r.midY)
      }
      
      // Level 4: diagonal mover
      Image(.redobst)
        .resizableToFit(width: vm.movingRect4Frame.height*1.3)
         // .frame(width: vm.movingRect4Frame.width, height: vm.movingRect4Frame.height)
          .position(x: vm.movingRect4Frame.midX, y: vm.movingRect4Frame.midY)
      
      // Level 7: vertical + horizontal movers
      ForEach(Array(vm.movingRects7Frames.enumerated()), id: \.offset) { _, r in
        Image(.redobst)
          .resizableToFit(width: r.height*1.3)
              .frame(width: r.width, height: r.height)
              .position(x: r.midX, y: r.midY)
      }
      
      ForEach(Array(vm.level8Bands.enumerated()), id: \.offset) { _, r in
          Rectangle()
              .fill(Color("701014").opacity(0.85))
              .frame(width: r.width, height: r.height)
              .position(x: r.midX, y: r.midY)
      }
      
      // Portal
      ZStack {
            Image(.wirl)
          .resizableToFit(height: 1.7*vm.portalRect.height)
      }
        .position(x: vm.portalRect.midX, y: vm.portalRect.midY)
      
      // Bonus
   
        Image(.prizebox)
        .resizableToFit(height: vm.currentLevel == 9 ? vm.bonusRect.height*1.8 : vm.bonusRect.height*2)
        .position(x: vm.bonusRect.midX, y: vm.bonusRect.midY)
        .transparentIf(vm.openSkins[vm.currentLevel - 1] || vm.isArtifact)
        .animation(vm.isArtifact)
      
      Image(.redobst)
        .resizableToFit(width: vm.movingBlockRect.height*1.3)
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
        .resizableToFit(height: 25)
        .animation(vm.showSmall)
        .transparentIf(vm.hasWon)
        .position(vm.small)
        .transparentIf(vm.hideSmall)
        .animation(.linear(duration: 0.1), vm.hideSmall)
     
      
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
        .disabled(vm.balance < 100)
        .opacity(vm.balance < 100 && !vm.isFreeze ? 0.6 : 1)
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
        .disabled(vm.balance < 200)
        .opacity(vm.balance < 200 && !vm.isImmortal ? 0.6 : 1)
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
