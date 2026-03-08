import Nimble
import Quick
@testable import Mastermind

final class MastermindEngineSpec: QuickSpec {
    override class func spec() {
        describe("MastermindEngine") {
            describe("generateSecret") {
                it("creates a secret with the configured code length") {
                    let sut = MastermindEngine()
                    expect(sut.generateSecret().count) == GameRules.codeLength
                }

                it("uses uppercase alphabetic characters only") {
                    let sut = MastermindEngine()
                    let secret = sut.generateSecret()

                    expect(secret.allSatisfy(\.isLetter)).to(beTrue())
                    expect(secret.allSatisfy(\.isUppercase)).to(beTrue())
                }

                it("produces more than one unique value across repeated generations") {
                    let sut = MastermindEngine()
                    let secrets = (0..<20).map { _ in String(sut.generateSecret()) }
                    expect(Set(secrets).count).to(beGreaterThan(1))
                }
            }

            describe("evaluate") {
                it("marks exact matches as correct") {
                    let sut = MastermindEngine()
                    let result = sut.evaluate(
                        guess: ["A", "B", "C", "D"],
                        against: ["A", "B", "C", "D"]
                    )

                    expect(result) == [.correct, .correct, .correct, .correct]
                }

                it("marks letters that are absent as wrong") {
                    let sut = MastermindEngine()
                    let result = sut.evaluate(
                        guess: ["W", "X", "Y", "Z"],
                        against: ["A", "B", "C", "D"]
                    )

                    expect(result) == [.wrong, .wrong, .wrong, .wrong]
                }

                it("marks letters in the wrong position as misplaced") {
                    let sut = MastermindEngine()
                    let result = sut.evaluate(
                        guess: ["D", "C", "B", "A"],
                        against: ["A", "B", "C", "D"]
                    )

                    expect(result) == [.misplaced, .misplaced, .misplaced, .misplaced]
                }

                it("combines correct, misplaced, and wrong results in a single guess") {
                    let sut = MastermindEngine()
                    let result = sut.evaluate(
                        guess: ["A", "X", "B", "Z"],
                        against: ["A", "B", "C", "D"]
                    )

                    expect(result) == [.correct, .wrong, .misplaced, .wrong]
                }

                it("returns an empty result for mismatched lengths") {
                    let sut = MastermindEngine()
                    let result = sut.evaluate(
                        guess: ["A", "B"],
                        against: ["A", "B", "C", "D"]
                    )

                    expect(result).to(beEmpty())
                }

                it("consumes duplicate letters only from unmatched secret positions") {
                    let sut = MastermindEngine()
                    let result = sut.evaluate(
                        guess: ["A", "A", "A", "A"],
                        against: ["A", "B", "A", "D"]
                    )

                    expect(result) == [.correct, .wrong, .correct, .wrong]
                }
            }
        }
    }
}
