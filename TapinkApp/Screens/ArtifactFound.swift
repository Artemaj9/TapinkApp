import SwiftUI

struct ArtifactFound: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationState
  
  @State private var startAnimation = false
  
    var body: some View {
      ZStack {
        Color("26013B")
          .opacity(0.8)
        Smoke()
          .opacity(startAnimation ? 0.4 : 0)
        
        Image(.starlight)
          .resizableToFit()
          .scaleEffect(vm.isSEight ? 1.4 : 1)
          .opacity(0.8)
        
        Image(.congrat)
          .resizableToFit()
          .yOffset(-vm.h*0.25)
          .hPadding(10)
        Image(.newballfound)
          .resizableToFit(height: 60)
          .yOffset(-vm.h*0.2)
        
        Image("ball\(vm.currentLevel)")
          .resizableToFit()
        
        Image(.artifactwin)
          .resizableToFit()
          .hPadding(40)
          .blendMode(.normal)
        
        Button {
          vm.openSkins[vm.currentLevel - 1] = true
          vm.artifactScreenShown = false
        } label: {
          Image(.artcontbtn)
            .resizableToFit(height: 64)
        }
        .yOffset(vm.h*0.33)
        .xOffsetIfNot(startAnimation, -vm.w)
        .springAnimation(startAnimation)
      }
      .ignoresSafeArea()
      .onAppear {
        startAnimation = true
      }
    }
}

#Preview {
    ArtifactFound()
    .vm
    .vm
}
