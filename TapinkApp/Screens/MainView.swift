import SwiftUI

struct MainView: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationState
    var body: some View {
      ZStack {
       bg
        
        Image("ball\(vm.currentSkin)")
          .resizableToFit(height: 2*vm.bigrad)
          .scaleEffect(1 + 0.7*vm.loseAnimation)
          .brightness(vm.loseAnimation == 1 ? 1 : 0)
          .opacity(1 - Double(vm.loseAnimation))
          .animation(.linear(duration: 0.1), vm.loseAnimation)
          .position(vm.big)
          .animation(.linear(duration: 0.1), vm.big)
       
        //  .animation(vm.big)
        
        
        Image(.moon)
          .resizableToFit(height: 2*vm.smallrad)
          .position(vm.small)
        //.opacity(vm.showSmall ? 1 : 0)
        //  .animation(vm.showSmall)
          .animation(vm.showSmall)
        
       navPanel
        
        
        Image(.balancebg)
          .resizableToFit()
          .overlay {
            Text("\(vm.balance)")
              .tapinkFont(size: 16, style: .blackHanSansRegular, color: .white)
          }
          .overlay(.leading) {
            Image(.coin)
              .resizableToFit(height: 32)
          }
          .hPadding()
          .yOffset(vm.header - 10)
        
        Text("TAP TO MOVE")
          .tapinkFont(size: 21, style: .blackHanSansRegular, color: .white.opacity(0.5))
          .allowsHitTesting(false)
          .overlayMask {
            Smoke(effect: "flickerShader")
              .opacity(0.4)
          }          .yOffset(vm.h*0.12)
        playbtn
      }
      .onAppear {
                 vm.setMenuScene(size: vm.size)
                 vm.startGameLoop()      // reuses the same timer; tick routes to menu
             }
             .onDisappear {
                 vm.stopGameLoop()
             }
      .addNavigationRoutes(path: $nm.path)
    }
  
  private var bg: some View {
    Image(.bg)
      .backgroundFill()
      .contentShape(Rectangle())
                    .onTapGesture { vm.handleMenuTap() }
  }
  
  private var playbtn: some View {
    Button {
      nm.navigate(.game)
    } label: {
      Image(.playbtn)
        .resizableToFit(height: 135)
    }
    .yOffset(vm.h*0.3)
  }
  
  private var navPanel: some View {
    HStack {
      Button {
        nm.navigate(.wardrobe)
      } label: {
        Image(.wardrobebtn)
          .resizableToFit(height: 96)
      }
      
      Spacer()
      
      Button {
        nm.navigate(.levels)
      } label: {
        Image(.levelsbtn)
          .resizableToFit(height: 96)
      }
    }
    .hPadding()
    .yOffset(-vm.h*0.3)

  }
}

#Preview {
    MainView()
    .vm
    .nm
}
