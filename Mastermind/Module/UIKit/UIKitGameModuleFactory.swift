import Foundation

struct UIKitGameModule {
    let state: GameFeatureState
    let presenter: GamePresentationLogic
    let viewModel: UIKitGameViewModel
    let viewFactory: UIKitGameViewFactory
}

struct UIKitGameModuleFactory {
    let themeManager: ThemeManager
    private let presenterFactory = GamePresenterFactory()

    func createModule(
        engine: MastermindEngineProtocol = MastermindEngine()
    ) -> UIKitGameModule {
        let state = GameFeatureState()
        let presenter = presenterFactory.createPresenter(state: state, engine: engine)
        let viewFactory = UIKitGameViewFactory(
            state: state,
            presenter: presenter,
            themeManager: themeManager
        )
        let viewModel = UIKitGameViewModel(viewFactory: viewFactory)

        return UIKitGameModule(
            state: state,
            presenter: presenter,
            viewModel: viewModel,
            viewFactory: viewFactory
        )
    }

    func createViewFactory(
        engine: MastermindEngineProtocol = MastermindEngine()
    ) -> UIKitGameViewFactory {
        createModule(engine: engine).viewFactory
    }
}
