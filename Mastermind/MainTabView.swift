import SwiftUI

struct MainTabView: View {

    let themeManager: ThemeManager
    private let swiftUIViewModel: SwiftUIGameViewModel
    private let uiKitViewModel: UIKitGameViewModel
    private let infoViewModel: InfoViewModel

    init(themeManager: ThemeManager) {
        self.themeManager = themeManager
        self.swiftUIViewModel = SwiftUIGameModuleFactory().createModule().viewModel
        self.uiKitViewModel = UIKitGameModuleFactory(themeManager: themeManager).createModule().viewModel
        self.infoViewModel = InfoModuleFactory().createModule().viewModel
    }

    var body: some View {
        TabView {
            Tab("SwiftUI", systemImage: "swift") {
                NavigationStack {
                    swiftUIViewModel.openFeature()
                        .toolbar { themeToolbarButton }
                        .navigationTitle("SwiftUI")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }

            Tab("UIKit", systemImage: "hammer.fill") {
                NavigationStack {
                    uiKitViewModel.openFeature()
                    .toolbar { themeToolbarButton }
                    .navigationTitle("UIKit")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }

            Tab("Info", systemImage: "info.circle.fill") {
                NavigationStack {
                    infoViewModel.openFeature()
                        .toolbar { themeToolbarButton }
                        .navigationTitle("Info")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .tint(AppColors.primary)
        .preferredColorScheme(themeManager.colorScheme)
    }

    private var themeToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button {
                withAnimation(.spring(
                    response: 0.4,
                    dampingFraction: 0.7,
                    blendDuration: 0
                )) {
                    themeManager.isDarkMode.toggle()
                }
            } label: {
                Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                    .foregroundStyle(AppColors.primary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .accessibilityLabel(themeManager.isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode")
        }
    }
}
