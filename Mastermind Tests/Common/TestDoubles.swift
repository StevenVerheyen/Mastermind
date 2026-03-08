import Foundation
@testable import Mastermind

final class MockMastermindEngine: MastermindEngineProtocol {
    var stubbedSecret: [Character] = ["A", "B", "C", "D"]
    var stubbedStatuses: [LetterStatus] = []

    func generateSecret() -> [Character] {
        stubbedSecret
    }

    func evaluate(guess: [Character], against secret: [Character]) -> [LetterStatus] {
        stubbedStatuses
    }
}

final class SnapshotMastermindEngine: MastermindEngineProtocol {
    var stubbedSecret: [Character]
    var stubbedStatuses: [LetterStatus]

    init(
        stubbedSecret: [Character] = ["T", "E", "S", "T"],
        stubbedStatuses: [LetterStatus] = [.wrong, .wrong, .wrong, .wrong]
    ) {
        self.stubbedSecret = stubbedSecret
        self.stubbedStatuses = stubbedStatuses
    }

    func generateSecret() -> [Character] {
        stubbedSecret
    }

    func evaluate(guess: [Character], against secret: [Character]) -> [LetterStatus] {
        stubbedStatuses
    }
}

final class MockInteractorOutput: GameInteractorOutputProtocol {
    var didStartNewGameCalled = false
    var lastState: GameState?
    var lastResult: GuessResult?
    var evaluateCallCount = 0

    func didStartNewGame(state: GameState) {
        didStartNewGameCalled = true
        lastState = state
    }

    func didEvaluateGuess(state: GameState, result: GuessResult) {
        lastState = state
        lastResult = result
        evaluateCallCount += 1
    }
}

final class MockInteractorInput: GameInteractorInputProtocol {
    weak var output: GameInteractorOutputProtocol?
    var stubbedState = GameState(secret: ["T", "E", "S", "T"])
    var startNewGameCallCount = 0
    var lastGuess: [Character]?

    func startNewGame() {
        startNewGameCallCount += 1
        output?.didStartNewGame(state: stubbedState)
    }

    func evaluateGuess(_ guess: [Character]) {
        lastGuess = guess
    }
}

final class MockPresentationLogic: GamePresentationLogic {
    var initializeGameCallCount = 0
    var startNewGameCallCount = 0
    var clearEvaluationFeedbackCallCount = 0
    var lastSubmittedInputs: [String]?
    var lastClearedInputs: [String]?

    func initializeGame() {
        initializeGameCallCount += 1
    }

    func submitGuess(letterInputs: [String]) {
        lastSubmittedInputs = letterInputs
    }

    func startNewGame() {
        startNewGameCallCount += 1
    }

    func clearEvaluationFeedback(currentInputs: [String]) {
        clearEvaluationFeedbackCallCount += 1
        lastClearedInputs = currentInputs
    }
}
