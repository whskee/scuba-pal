import SwiftUI

enum ScubaTheme {
    static let background = Color(red: 0.021, green: 0.056, blue: 0.108)
    static let background2 = Color(red: 0.035, green: 0.102, blue: 0.158)
    static let surface = Color(red: 0.055, green: 0.137, blue: 0.211)
    static let surface2 = Color(red: 0.071, green: 0.211, blue: 0.307)
    static let lagoon = Color(red: 0.033, green: 0.588, blue: 0.651)
    static let reef = Color(red: 0.753, green: 0.949, blue: 0.925)
    static let ink = Color(red: 0.965, green: 0.984, blue: 1.0)
    static let muted = Color(red: 0.66, green: 0.73, blue: 0.79)
    static let primary = Color(red: 0.082, green: 0.82, blue: 0.761)
    static let secondary = Color(red: 0.471, green: 0.651, blue: 1.0)
    static let accent = Color(red: 1.0, green: 0.419, blue: 0.506)
    static let sand = Color(red: 1.0, green: 0.863, blue: 0.659)
    static let danger = Color(red: 1.0, green: 0.42, blue: 0.42)
    static let border = Color.white.opacity(0.12)
    static let darkText = Color(red: 0.063, green: 0.126, blue: 0.2)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                background,
                Color(red: 0.041, green: 0.122, blue: 0.175),
                Color(red: 0.02, green: 0.077, blue: 0.137)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var reefGradient: LinearGradient {
        LinearGradient(
            colors: [primary, reef, secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
