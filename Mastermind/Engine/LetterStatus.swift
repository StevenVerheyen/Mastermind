import Foundation

enum LetterStatus: Equatable, Sendable, CaseIterable {
    case correct
    case misplaced
    case wrong
    case unknown

    var accessibilityDescription: String {
        switch self {
        case .correct:   "correct position"
        case .misplaced: "wrong position"
        case .wrong:     "not in the word"
        case .unknown:   "not yet checked"
        }
    }
}
