import Foundation

protocol GameInteractorInputProtocol: AnyObject {
    var output: GameInteractorOutputProtocol? { get set }
    func startNewGame()
    func evaluateGuess(_ guess: [Character])
}

protocol GameInteractorOutputProtocol: AnyObject {
    func didStartNewGame(state: GameState)
    func didEvaluateGuess(state: GameState, result: GuessResult)
}

final class GameInteractor: GameInteractorInputProtocol {

    weak var output: GameInteractorOutputProtocol?

    private var gameState = GameState()
    private let engine: MastermindEngineProtocol

    init(engine: MastermindEngineProtocol) {
        self.engine = engine
    }

    func startNewGame() {
        gameState = GameState()
        gameState.secret = engine.generateSecret()
        output?.didStartNewGame(state: gameState)
    }

    func evaluateGuess(_ guess: [Character]) {
        guard !gameState.isGameOver else { return }
        guard guess.count == GameRules.codeLength else { return }

        let statuses = engine.evaluate(guess: guess, against: gameState.secret)
        guard statuses.count == guess.count else { return }

        let letterResults = guess.enumerated().map { index, char in
            LetterResult(id: index, character: char, status: statuses[index])
        }
        let result = GuessResult(letters: letterResults)

        gameState.history.append(result)

        if result.isWin {
            gameState.isGameOver = true
        }

        output?.didEvaluateGuess(state: gameState, result: result)
    }
}
