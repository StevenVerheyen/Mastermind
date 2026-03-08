import Observation

@Observable
final class GameFeatureState {
    var letterInputs: [String]
    var letterStatuses: [LetterStatus]
    var gameMessage: String
    var isGameWon: Bool
    var attempts: Int
    var guessHistory: [GuessResult]

    init(
        letterInputs: [String] = GameRules.initialInputs,
        letterStatuses: [LetterStatus] = GameRules.initialStatuses,
        gameMessage: String = GameRules.initialMessage,
        isGameWon: Bool = false,
        attempts: Int = 0,
        guessHistory: [GuessResult] = []
    ) {
        self.letterInputs = letterInputs
        self.letterStatuses = letterStatuses
        self.gameMessage = gameMessage
        self.isGameWon = isGameWon
        self.attempts = attempts
        self.guessHistory = guessHistory
    }
}
