import SwiftUI

struct GenderUtils {
    
    static func genderBackgroundColor(gender: String) -> Color {
        switch gender.lowercased() {
        case "male":
            return ColorManager.primaryBlue.opacity(0.1)
        case "female":
            return ColorManager.primaryPink.opacity(0.1)
        default:
            return Color.green.opacity(0.1)
        }
    }

    static func genderTextColor(gender: String) -> Color {
        switch gender.lowercased() {
        case "male":
            return ColorManager.primaryBlue
        case "female":
            return ColorManager.primaryPink
        default:
            return Color.green
        }
    }
}
