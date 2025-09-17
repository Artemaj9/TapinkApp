import SwiftUI

// swiftlint:disable all
extension Text {
    static func markdownLike(_ input: String) -> Text {
        let parts = input.components(separatedBy: "**")
        var result = Text("")
        
        for (index, part) in parts.enumerated() {
            if index % 2 == 1 {
                result = result + Text(part).bold()
            } else {
                result = result + Text(part)
            }
        }
        
        return result
    }
}
