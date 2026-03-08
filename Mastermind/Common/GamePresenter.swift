import Foundation

protocol GamePresentationLogic: AnyObject {
    func initializeGame()
    func submitGuess(letterInputs: [String])
    func startNewGame()
    func clearEvaluationFeedback(currentInputs: [String])
}

final class GamePresenter {

    private let interactor: GameInteractorInputProtocol
    private let state: GameFeatureState

    private var gameState = GameState()
    private var hasInitialized = false

    init(
        interactor: GameInteractorInputProtocol,
        state: GameFeatureState
    ) {
        self.interactor = interactor
        self.state = state
    }
}

// MARK: - GamePresentationLogic

extension GamePresenter: GamePresentationLogic {

    func initializeGame() {
        guard !hasInitialized else { return }

        hasInitialized = true
        interactor.startNewGame()
    }

    func submitGuess(letterInputs: [String]) {
        let trimmed = letterInputs.map { $0.uppercased().trimmingCharacters(in: .whitespaces) }
        state.letterInputs = trimmed

        guard trimmed.allSatisfy({ $0.count == 1 && $0.first?.isLetter == true }) else {
            state.gameMessage = "Please enter a letter in each box"
            return
        }

        let guess = trimmed.compactMap { $0.first }
        interactor.evaluateGuess(guess)
    }

    func startNewGame() {
        interactor.startNewGame()
    }

    func clearEvaluationFeedback(currentInputs: [String]) {
        state.letterInputs = currentInputs
        state.letterStatuses = GameRules.initialStatuses
    }
}

// MARK: - GameInteractorOutputProtocol

extension GamePresenter: GameInteractorOutputProtocol {

    func didStartNewGame(state: GameState) {
        gameState = state
        self.state.letterInputs = GameRules.initialInputs
        self.state.letterStatuses = GameRules.initialStatuses
        self.state.gameMessage = GameRules.initialMessage
        self.state.isGameWon = state.isGameOver
        self.state.attempts = state.attempts
        self.state.guessHistory = state.history
    }

    func didEvaluateGuess(state: GameState, result: GuessResult) {
        gameState = state
        self.state.letterStatuses = result.statuses
        self.state.isGameWon = state.isGameOver
        self.state.attempts = state.attempts
        self.state.guessHistory = state.history
        self.state.gameMessage = state.isGameOver
            ? "🎉 You won in \(state.attempts) \("attempt".pluralized(for: state.attempts))!"
            : GameRules.initialMessage
    }
}
