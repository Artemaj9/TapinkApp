import SwiftUI

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
//          Rectangle()
//                      .strokeBorder(Color.purple, lineWidth: 4)
//                      .frame(width: 350, height: 700)
//                      .position(x: vm.size.width / 2, y: vm.size.height / 2)
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
            
            // Big circle
            Circle()
                .fill(Color.blue)
                .frame(width: 20, height: 20)
                .position(vm.big)

          
            Circle()
                .fill(Color.red)
                .frame(width: 10, height: 10)
                .position(vm.small)
                //.opacity(vm.showSmall ? 1 : 0)
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
        .contentShape(Rectangle()) // full screen tappable
        .coordinateSpace(name: "game")               // local coords
               .gesture(DragGesture(minimumDistance: 0)     // tap-with-location
                   .onEnded { value in
                       vm.handleTap(at: value.location)     // only fires if inside
                   }
               )
//        .onTapGesture {
//        //  withAnimation {
//            vm.handleTap()
//         // }
//           
//        }
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
