import SwiftUI

struct Levels: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationState
  @State private var startAnimation = false
  
  var body: some View {
    ZStack {
      Image(.bg)
        .backgroundFill()
      Smoke()
        .opacity(startAnimation ? 0.9 : 0)
        .animation(.easeInOut(duration: 1), startAnimation)
      Image(.bg)
        .backgroundFill()
        .opacity(startAnimation ? 0.75 : 0)
        .animation(.easeInOut(duration: 2), startAnimation)
       
      
      HStack {
        Text("LEVELS")
          .tapinkFont(size: 21, style: .blackHanSansRegular, color: .white)
        Spacer()
        Button {
          nm.goback()
        } label: {
          Image(.xbtn)
            .resizableToFit(height: 38)
        }
      }
      .hPadding()
      .yOffset(vm.header)
      
      VStack(spacing: 50) {
        ForEach(0..<5) { i in
          HStack(spacing: 30) {
            ForEach(0..<2) { j in
              Image(.levelbtnbg)
                .resizableToFit(height: 60)
                .overlay {
                  LinearGradient(colors: [.white, Color("C6B6FF")], startPoint: .top, endPoint: .bottom)
                    .height(25)
                    .mask {
                      Group {
                        Text("LEVEL ")
                          .font(.custom(.blackHanSansRegular, size: 18))
                        + Text("\(2*i + j + 1)")
                          .font(.custom(.blackHanSansRegular, size: 21))
                      }
                      .foregroundColor(.white)
                      .shadow(color: .black.opacity(0.32), radius: 2, x: 0, y: 2)
                    }
                    .yOffset(-8)
                }
                .overlay(.bottom) {
                  Button {
                    vm.currentLevel = 2*i + j + 1
                    nm.path = [.game]
                    print("UUU")
                  } label: {
                    ZStack {
                      Image(.levellock)
                        .resizableToFit(height: 42)
                      Image(.lvlplay)
                        .resizableToFit(height: 42)
                        .transparentIfNot(vm.openLevels[2*i + j])
                    }
                  }
                  .disabled(!vm.openLevels[2*i + j])
                  .yOffset(20)
                }
            }
          }
        }
      }
      .yOffset(vm.h*0.02)
    }
    .onAppear {
      startAnimation = true
    }
    .navigationBarBackButtonHidden()

  }
}

#Preview {
  Levels()
    .nm
    .vm
}
