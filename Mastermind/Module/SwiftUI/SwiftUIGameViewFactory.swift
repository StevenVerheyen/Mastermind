import SwiftUI

struct SwiftUIGameViewFactory {
    let state: GameFeatureState
    let presenter: GamePresentationLogic

    func makeView() -> SwiftUIGameView {
        SwiftUIGameView(state: state, presenter: presenter)
    }
}
