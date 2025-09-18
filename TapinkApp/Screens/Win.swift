import SwiftUI

struct Win: View {
  @EnvironmentObject var vm: GameViewModel
  @EnvironmentObject var nm: NavigationState
  
  var body: some View {
    ZStack {
      Color("26013B").opacity(0.8)
      
      
      Image(.levelcomplete)
        .resizableToFit()
        .overlay {
          VStack(spacing: 16) {
            Text("CONGRATULATIONS")
              .tapinkFont(size: 21, style: .blackHanSansRegular, color: .white)
              .padding(.bottom, 24)
            HStack {
              Text("Moves Left:")
                .tapinkFont(size: 15, style: .blackHanSansRegular, color: .white)
              Spacer()
              Text("")
            }
            .width(vm.w*0.7)
            HStack {
              Text("Time:")
                .tapinkFont(size: 15, style: .blackHanSansRegular, color: .white)
              Spacer()
              Text("")
            }
            .width(vm.w*0.7)
            
            HStack {
              Text("Artifact:")
                .tapinkFont(size: 15, style: .blackHanSansRegular, color: .white)
              Spacer()
              Text("")
            }
            .width(vm.w*0.7)
            HStack {
              Text("Total Score:")
                .tapinkFont(size: 15, style: .blackHanSansRegular, color: .white)
              Spacer()
              Text("")
            }
            .width(vm.w*0.7)
          }
        }
        .hPadding()
        .yOffset(-vm.h*0.07)
      
      Button  {
        if vm.currentLevel < 10 {
          vm.openLevels[vm.currentLevel] = true
          vm.currentLevel += 1
        } else {
          vm.openLevels[9] = true
          vm.currentLevel = 10
        }
        vm.isWin = false
      } label: {
        VStack(spacing: 20) {
          Image(.play)
            .resizableToFit(height: 100)
          
          Text("\(vm.currentLevel == 10 ? "RESTART" : "NEXT LEVEL")")
            .tapinkFont(size: 20, style: .blackHanSansRegular, color: .white)
        }
      }
      .yOffset(vm.h*0.29)
      
      HStack {
        Button {
          nm.path = []
        } label: {
          Image(.menubtn)
            .resizableToFit(height: 81)
        }
        
        Spacer()
        
        Button {
          nm.path = [.levels]
        } label: {
          Image(.levelsbtn)
            .resizableToFit(height: 81)
        }
        
      }
      .hPadding(30)
      .yOffset(vm.footer)
    }
    .ignoresSafeArea()

  }
}

#Preview {
  Win()
    .vm
    .nm
}
