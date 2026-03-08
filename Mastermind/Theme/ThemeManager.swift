import SwiftUI
import UIKit

@Observable
final class ThemeManager {

    private let userDefaults: UserDefaults
    private let isDarkModeKey: String

    var isDarkMode: Bool {
        didSet {
            userDefaults.set(isDarkMode, forKey: isDarkModeKey)
        }
    }

    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }

    init(
        userDefaults: UserDefaults = .standard,
        isDarkModeKey: String = "isDarkMode"
    ) {
        self.userDefaults = userDefaults
        self.isDarkModeKey = isDarkModeKey
        self.isDarkMode = userDefaults.bool(forKey: isDarkModeKey)
    }
}

enum AppColors {
    static let primary = color(red: 0, green: 171, blue: 239)
    static let secondary = color(red: 0, green: 55, blue: 104)

    static func adaptiveAccent(for scheme: ColorScheme) -> Color {
        scheme == .dark ? primary : secondary
    }

    static func color(for status: LetterStatus) -> Color {
        switch status {
        case .correct:   .green
        case .misplaced: .orange
        case .wrong:     .red
        case .unknown:   .clear
        }
    }

    static let primaryUI = uiColor(red: 0, green: 171, blue: 239)
    static let secondaryUI = uiColor(red: 0, green: 55, blue: 104)

    static func adaptiveAccentUI(isDarkMode: Bool) -> UIColor {
        isDarkMode ? primaryUI : secondaryUI
    }

    static func uiColor(for status: LetterStatus) -> UIColor {
        switch status {
        case .correct:   .systemGreen
        case .misplaced: .systemOrange
        case .wrong:     .systemRed
        case .unknown:   .clear
        }
    }

    private static func color(red: Double, green: Double, blue: Double) -> Color {
        Color(red: red / 255.0, green: green / 255.0, blue: blue / 255.0)
    }

    private static func uiColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
    }
}
