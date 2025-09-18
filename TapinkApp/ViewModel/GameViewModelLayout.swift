import SwiftUI

extension GameViewModel {
  
  // MARK: - Layout
  var h: CGFloat {
    size.height
  }
  
  var w: CGFloat {
    size.width
  }
  
  var header: CGFloat {
    isSEight ? -size.height * 0.4 + 52 : -size.height * 0.4
  }
  
  var footer: CGFloat {
    isSEight ? size.height*0.41 - 60 : size.height*0.41
  }
  
  var isEightPlus: Bool {
    return size.width > 405 && size.height < 910 && size.height > 880
    && UIDevice.current.name != "iPhone 11 Pro Max"
  }
  
  var isElevenProMax: Bool {
    UIDevice.current.name == "iPhone 11 Pro Max"
  }
  
  var isIpad: Bool {
    UIDevice.current.name.contains("iPad")
  }
  
  var isSE: Bool {
    return size.width < 380
  }
  
  var isSEight: Bool {
    return isSE || isEightPlus
  }
}
