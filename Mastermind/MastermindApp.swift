import SwiftUI

@main
struct MastermindApp: App {
    @State private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            MainTabView(themeManager: themeManager)
        }
    }
}
