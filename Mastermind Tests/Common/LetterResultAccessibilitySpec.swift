import Nimble
import Quick
@testable import Mastermind

final class LetterResultAccessibilitySpec: QuickSpec {
    override class func spec() {
        describe("LetterResult.accessibilityDescription") {
            it("describes a correct letter") {
                expectAccessibilityDescription(for: .correct) == "A, correct position"
            }

            it("describes an unchecked letter") {
                expectAccessibilityDescription(for: .unknown) == "A, not yet checked"
            }

            it("describes a misplaced letter") {
                expectAccessibilityDescription(
                    for: .misplaced,
                    id: 1,
                    character: "B"
                ) == "B, wrong position"
            }

            it("describes a wrong letter") {
                expectAccessibilityDescription(
                    for: .wrong,
                    id: 2,
                    character: "Z"
                ) == "Z, not in the word"
            }
        }

        describe("guess history accessibility output") {
            it("composes spoken history from a full guess result") {
                let guess = GuessResult(letters: [
                    makeLetterResult(id: 0, character: "A", status: .correct),
                    makeLetterResult(id: 1, character: "X", status: .wrong),
                    makeLetterResult(id: 2, character: "B", status: .misplaced),
                    makeLetterResult(id: 3, character: "D", status: .correct),
                ])

                let description = guess.letters
                    .map(\.accessibilityDescription)
                    .joined(separator: ", ")

                expect(description) == "A, correct position, X, not in the word, B, wrong position, D, correct position"
            }
        }
    }

    private static func expectAccessibilityDescription(
        for status: LetterStatus,
        id: Int = 0,
        character: Character = "A"
    ) -> String {
        makeLetterResult(id: id, character: character, status: status).accessibilityDescription
    }

    private static func makeLetterResult(
        id: Int,
        character: Character,
        status: LetterStatus
    ) -> LetterResult {
        LetterResult(id: id, character: character, status: status)
    }
}
