import Foundation

final class SwiftUIGameViewModel {
    private let viewFactory: SwiftUIGameViewFactory

    init(viewFactory: SwiftUIGameViewFactory) {
        self.viewFactory = viewFactory
    }

    func openFeature() -> SwiftUIGameView {
        viewFactory.makeView()
    }
}
