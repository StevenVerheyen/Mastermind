import Foundation

struct SwiftUIGameModule {
    let state: GameFeatureState
    let presenter: GamePresentationLogic
    let viewModel: SwiftUIGameViewModel
    let viewFactory: SwiftUIGameViewFactory
}

struct SwiftUIGameModuleFactory {
    private let presenterFactory = GamePresenterFactory()

    func createModule(
        engine: MastermindEngineProtocol = MastermindEngine()
    ) -> SwiftUIGameModule {
        let state = GameFeatureState()
        let presenter = presenterFactory.createPresenter(state: state, engine: engine)
        let viewFactory = SwiftUIGameViewFactory(state: state, presenter: presenter)
        let viewModel = SwiftUIGameViewModel(viewFactory: viewFactory)

        return SwiftUIGameModule(
            state: state,
            presenter: presenter,
            viewModel: viewModel,
            viewFactory: viewFactory
        )
    }

    func createViewFactory(
        engine: MastermindEngineProtocol = MastermindEngine()
    ) -> SwiftUIGameViewFactory {
        createModule(engine: engine).viewFactory
    }
}
