import ConfettiSwiftUI
import SwiftUI

struct UIKitGameViewWrapper: View {

    let state: GameFeatureState
    let presenter: GamePresentationLogic
    let themeManager: ThemeManager
    @State private var confettiTrigger = 0

    var body: some View {
        UIKitGameViewControllerContainer(
            state: state,
            presenter: presenter,
            themeManager: themeManager
        )
        .onChange(of: state.isGameWon) { oldValue, isGameWon in
            guard isGameWon && !oldValue else { return }
            confettiTrigger += 1
        }
        .confettiCannon(trigger: $confettiTrigger)
    }
}

private struct UIKitGameViewControllerContainer: UIViewControllerRepresentable {

    let state: GameFeatureState
    let presenter: GamePresentationLogic
    let themeManager: ThemeManager

    func makeUIViewController(context: Context) -> UIKitGameViewController {
        UIKitGameViewController(
            state: state,
            presenter: presenter,
            themeManager: themeManager
        )
    }

    func updateUIViewController(_ uiViewController: UIKitGameViewController, context: Context) {
        uiViewController.refreshTheme()
    }
}
