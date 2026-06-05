import SwiftUI

enum ScubaTheme {
    static let background = Color(red: 0.011, green: 0.016, blue: 0.024)
    static let background2 = Color(red: 0.027, green: 0.039, blue: 0.052)
    static let surface = Color(red: 0.057, green: 0.069, blue: 0.084)
    static let surface2 = Color(red: 0.078, green: 0.095, blue: 0.112)
    static let lagoon = Color(red: 0.025, green: 0.486, blue: 0.509)
    static let reef = Color(red: 0.733, green: 0.968, blue: 0.936)
    static let ink = Color(red: 0.963, green: 0.976, blue: 0.988)
    static let muted = Color(red: 0.625, green: 0.682, blue: 0.733)
    static let primary = Color(red: 0.098, green: 0.812, blue: 0.741)
    static let secondary = Color(red: 0.835, green: 0.706, blue: 0.451)
    static let accent = Color(red: 0.929, green: 0.345, blue: 0.525)
    static let sand = Color(red: 0.937, green: 0.804, blue: 0.545)
    static let danger = Color(red: 1.0, green: 0.42, blue: 0.42)
    static let border = Color.white.opacity(0.115)
    static let darkText = Color(red: 0.016, green: 0.026, blue: 0.039)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                background,
                Color(red: 0.041, green: 0.068, blue: 0.076),
                Color(red: 0.082, green: 0.049, blue: 0.074),
                Color(red: 0.015, green: 0.021, blue: 0.032)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var reefGradient: LinearGradient {
        LinearGradient(
            colors: [primary, reef, sand],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var luxurySurfaceGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.12),
                surface.opacity(0.92),
                background2.opacity(0.98)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
