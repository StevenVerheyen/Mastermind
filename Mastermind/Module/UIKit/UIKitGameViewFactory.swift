import SwiftUI

struct UIKitGameViewFactory {
    let state: GameFeatureState
    let presenter: GamePresentationLogic
    let themeManager: ThemeManager

    func makeView() -> UIKitGameViewWrapper {
        UIKitGameViewWrapper(
            state: state,
            presenter: presenter,
            themeManager: themeManager
        )
    }

    func makeViewController() -> UIKitGameViewController {
        UIKitGameViewController(
            state: state,
            presenter: presenter,
            themeManager: themeManager
        )
    }
}
