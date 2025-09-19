import SwiftUI

struct Wardrobe: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationState
  @State private var startAnimation = false
  
  var body: some View {
    ZStack {
      bg
    
      Image(.light)
        .resizableToFit()
        .scaleEffect(1.1)
        .yOffset(-vm.h*0.28)
        .blendMode(.luminosity)
      Image("b\(vm.currentSkin)")
        .resizableToFit(height: 150)
        .animation(vm.currentSkin)
        .yOffset(-vm.h*0.28)
      
      
      grads[vm.currentSkin - 1]
        .height(28)
        .yOffset(-8)
      
        .mask {
          Text("CHANGE YOUR APPEARANCE!")
            .tapinkFont(size: 21, style: .blackHanSansRegular, color: .white)
        }
        .animation(vm.currentSkin)
        .overlayMask {
          Smoke(effect: "flickerShader")
            .opacity(0.2)
        }
        .yOffset(-vm.h*0.15)
      
      
      Image(.wmoon)
        .resizableToFit(height: 80)
        .offset(-vm.w*0.3, -vm.h*0.35)
      Text("Find mysterious boxes on the level\n and open new balls")
        .multilineTextAlignment(.center)
        .tapinkFont(size: 14, style: .blackHanSansRegular, color: .white)
      
        .yOffset(-vm.h*0.1)
      
      xbtn
      
      
      VStack(spacing: 20) {
        ForEach(0..<3) { i in
          HStack {
            ForEach(0..<3) { j in
              Button {
                vm.currentSkin = j + 3*i + 1
              } label: {
                ZStack {
                  Image(.nselbg)
                    .resizableToFit(height: 75)
                    .transparentIf(vm.currentSkin == j + 3*i + 1)
                    .animation(vm.currentSkin)
                  
                  Image(.selbg)
                    .resizableToFit(height: 76)
                    .transparentIfNot(vm.currentSkin == j + 3*i + 1)
                    .animation(vm.currentSkin)
                  Image("b\(j + 3*i + 1)")
                    .resizableToFit(height: 48)
                    .opacity(vm.openSkins[j + 3*i] ? 1 : 0.6)
                  
                  Image(.lock)
                    .resizableToFit(height: 38)
                    .transparentIf(vm.openSkins[j + 3*i])
                }
                .frame(width: vm.w*0.3)
              }
              .disabled(!vm.openSkins[j + 3*i])
              
            }
          }
        }
        Button {
          vm.currentSkin = 10
        } label: {
          ZStack {
            Image(.nselbg)
              .resizableToFit(height: 75)
              .transparentIf(vm.currentSkin == 10)
              .animation(vm.currentSkin)
            
            Image(.selbg)
              .resizableToFit(height: 76)
              .transparentIfNot(vm.currentSkin == 10)
              .animation(vm.currentSkin)
            Image("b10")
              .resizableToFit(height: 48)
              .opacity(vm.openSkins[9] ? 1 : 0.6)
            
            Image(.lock)
              .resizableToFit(height: 38)
              .transparentIf(vm.openSkins[9])
          }
          .frame(width: vm.w*0.3)
          
        }
        .disabled(!vm.openSkins[9])
        
      }
      .yOffset(vm.h*0.2)
      .yOffsetIf(vm.isSEight, -24)
    }
    .navigationBarBackButtonHidden()
    .onAppear {
      startAnimation = true
    }
  }
  
  @ViewBuilder private var bg: some View {
    Image(.bg)
      .backgroundFill()
    Smoke()
      .opacity(startAnimation ? 0.9 : 0)
      .animation(.easeInOut(duration: 1), startAnimation)
    Image(.bg)
      .backgroundFill()
      .opacity(startAnimation ? 0.7 : 0)
      .animation(.easeInOut(duration: 2), startAnimation)
  }
  
  private var xbtn: some View {
    Button {
      nm.path = []
    } label: {
      Image(.xbtn)
        .resizableToFit(height: 38)
    }
    .yOffset(vm.header)
    .xOffset(vm.w*0.4)
  }
}

#Preview {
  Wardrobe()
    .vm
    .nm
}

let grads:[LinearGradient] = [
  LinearGradient(colors: [Color("FAC9FF"), Color("EC42FF")], startPoint: .top, endPoint: .bottom),
  LinearGradient(colors: [Color("70FF60"), Color("009400")], startPoint: .top, endPoint: .bottom),
  LinearGradient(colors: [Color("FF6082"), Color("940028")], startPoint: .top, endPoint: .bottom),
  LinearGradient(colors: [Color("FF9060"), Color("940000")], startPoint: .top, endPoint: .bottom),
  LinearGradient(colors: [Color("60FFE7"), Color("008F94")], startPoint: .top, endPoint: .bottom),
  LinearGradient(colors: [Color("FF60BA"), Color("94004F")], startPoint: .top, endPoint: .bottom),
  LinearGradient(colors: [Color("A260FF"), Color("5E0094")], startPoint: .top, endPoint: .bottom),
  LinearGradient(colors: [Color("FFE760"), Color("948600")], startPoint: .top, endPoint: .bottom),
  LinearGradient(colors: [Color("6085FF"), Color("070094")], startPoint: .top, endPoint: .bottom),
  LinearGradient(colors: [Color("FF9060"), Color("60FFE7")], startPoint: .top, endPoint: .bottom),
]
