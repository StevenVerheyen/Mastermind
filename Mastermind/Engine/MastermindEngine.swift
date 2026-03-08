import Foundation

protocol MastermindEngineProtocol: AnyObject {
    func generateSecret() -> [Character]
    func evaluate(guess: [Character], against secret: [Character]) -> [LetterStatus]
}

final class MastermindEngine: MastermindEngineProtocol {

    /*
     === 🟠 explanation 🟠 ===
     For readability reason, I've chosen for predefined characters instead of
     getting low-level unicode characters, which would be more efficient.
     However; readablility is important too.
     */
    func generateSecret() -> [Character] {
        (0..<GameRules.codeLength).compactMap { _ in
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ".randomElement()
        }
    }

    func evaluate(guess: [Character], against secret: [Character]) -> [LetterStatus] {
        guard guess.count == secret.count else { return [] }

        var result = Array(repeating: LetterStatus.wrong, count: guess.count)
        var remainingSecretCounts: [Character: Int] = [:]

        for index in guess.indices {
            if guess[index] == secret[index] {
                result[index] = .correct
            } else {
                remainingSecretCounts[secret[index], default: 0] += 1
            }
        }

        for index in guess.indices where result[index] != .correct {
            let character = guess[index]
            let remainingCount = remainingSecretCounts[character, default: 0]

            guard remainingCount > 0 else { continue }

            result[index] = .misplaced
            remainingSecretCounts[character] = remainingCount - 1
        }

        return result
    }
}
