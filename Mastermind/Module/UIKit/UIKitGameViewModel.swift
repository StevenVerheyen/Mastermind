import Foundation

final class UIKitGameViewModel {
    private let viewFactory: UIKitGameViewFactory

    init(viewFactory: UIKitGameViewFactory) {
        self.viewFactory = viewFactory
    }

    func openFeature() -> UIKitGameViewWrapper {
        viewFactory.makeView()
    }
}
