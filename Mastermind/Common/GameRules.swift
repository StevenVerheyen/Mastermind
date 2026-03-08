import Foundation

enum GameRules {
    static let codeLength = 4
    static let initialInputs = Array(repeating: "", count: codeLength)
    static let initialStatuses = Array(repeating: LetterStatus.unknown, count: codeLength)
    static let initialMessage = "Enter \(codeLength) letters and press Check"
}
