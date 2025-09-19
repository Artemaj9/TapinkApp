import SwiftUI

struct SplashView: View {
  @EnvironmentObject var vm: GameViewModel
 
  let orbitRadius: CGFloat = 75

  var body: some View {
    ZStack {
      bg
      ballsAnimation
      animTxt
    }
    .ignoresSafeArea()
  }
  
  private var bg: some View {
    Color("35084E")
      .ignoresSafeArea()
  }
  
  @ViewBuilder private var ballsAnimation: some View {
    Circle()
      .stroke(lineWidth: 0.2)
      .fill(.white.opacity(0.3))
      .height(2*orbitRadius)
    
    Image(.ball1)
      .resizableToFit(height: 50)
    
    Image(.moon)
      .resizableToFit(height: 2*vm.smallrad)
      .offset(orbitRadius*Double(cos(4*vm.splashTime)), orbitRadius*Double(sin(4*vm.splashTime)))
  }
  
  private var animTxt: some View {
    HStack(spacing: 0) {
      ForEach(loading.indices, id: \.self) { ind in
        Text(loading[ind])
          .offset(y: vm.movingLetter == ind ? -6 : 0)
          .springAnimation(vm.movingLetter)
        }
    }
    .yOffset(vm.h*0.3)
    .font(.custom(.blackHanSansRegular, size: 23))
    .foregroundColor(.white)
  }
}

let loading = ["L", "O", "A", "D", "I", "N", "G", ".", ".", "."]

#Preview {
  SplashView()
    .vm
}
