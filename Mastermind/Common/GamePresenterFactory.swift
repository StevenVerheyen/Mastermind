import Foundation

struct GamePresenterFactory {
    func createPresenter(
        state: GameFeatureState,
        engine: MastermindEngineProtocol = MastermindEngine()
    ) -> GamePresenter {
        let interactor = GameInteractor(engine: engine)
        let presenter = GamePresenter(interactor: interactor, state: state)
        interactor.output = presenter
        presenter.initializeGame()
        return presenter
    }
}
