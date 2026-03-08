import Foundation

struct GuessResult: Equatable {
    let letters: [LetterResult]

    var isWin: Bool {
        letters.allSatisfy { $0.status == .correct }
    }

    var statuses: [LetterStatus] {
        letters.map(\.status)
    }
}

struct LetterResult: Equatable, Identifiable {
    let id: Int
    let character: Character
    let status: LetterStatus

    var accessibilityDescription: String {
        "\(character), \(status.accessibilityDescription)"
    }
}
