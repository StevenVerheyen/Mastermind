import Nimble
import Quick
@testable import Mastermind

final class LetterResultAccessibilitySpec: QuickSpec {
    override class func spec() {
        describe("LetterResult accessibility descriptions") {
            it("describes a correct letter") {
                let result = LetterResult(id: 0, character: "A", status: .correct)
                expect(result.accessibilityDescription) == "A, correct position"
            }

            it("describes a misplaced letter") {
                let result = LetterResult(id: 1, character: "B", status: .misplaced)
                expect(result.accessibilityDescription) == "B, wrong position"
            }

            it("describes a wrong letter") {
                let result = LetterResult(id: 2, character: "Z", status: .wrong)
                expect(result.accessibilityDescription) == "Z, not in the word"
            }

            it("composes spoken history from a full guess result") {
                let guess = GuessResult(letters: [
                    LetterResult(id: 0, character: "A", status: .correct),
                    LetterResult(id: 1, character: "X", status: .wrong),
                    LetterResult(id: 2, character: "B", status: .misplaced),
                    LetterResult(id: 3, character: "D", status: .correct),
                ])

                let description = guess.letters
                    .map(\.accessibilityDescription)
                    .joined(separator: ", ")

                expect(description) == "A, correct position, X, not in the word, B, wrong position, D, correct position"
            }
        }
    }
}
