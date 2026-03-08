import Nimble
import Quick
@testable import Mastermind

final class MastermindEngineSpec: QuickSpec {
    override class func spec() {
        describe("MastermindEngine") {
            var sut: MastermindEngine!

            beforeEach {
                sut = MastermindEngine()
            }

            describe("#generateSecret") {
                it("creates a secret with the configured code length") {
                    expect(sut.generateSecret().count) == GameRules.codeLength
                }

                it("uses uppercase alphabetic characters only") {
                    let secret = sut.generateSecret()

                    expect(secret.allSatisfy(\.isLetter)).to(beTrue())
                    expect(secret.allSatisfy(\.isUppercase)).to(beTrue())
                }

                it("produces more than one unique value across repeated generations") {
                    let secrets = (0..<20).map { _ in String(sut.generateSecret()) }
                    expect(Set(secrets).count).to(beGreaterThan(1))
                }
            }

            describe("#evaluate(guess:against:)") {
                it("marks exact matches as correct") {
                    let result = sut.evaluate(
                        guess: ["A", "B", "C", "D"],
                        against: ["A", "B", "C", "D"]
                    )

                    expect(result) == [.correct, .correct, .correct, .correct]
                }

                it("marks letters that are absent as wrong") {
                    let result = sut.evaluate(
                        guess: ["W", "X", "Y", "Z"],
                        against: ["A", "B", "C", "D"]
                    )

                    expect(result) == [.wrong, .wrong, .wrong, .wrong]
                }

                it("marks letters in the wrong position as misplaced") {
                    let result = sut.evaluate(
                        guess: ["D", "C", "B", "A"],
                        against: ["A", "B", "C", "D"]
                    )

                    expect(result) == [.misplaced, .misplaced, .misplaced, .misplaced]
                }

                it("combines correct, misplaced, and wrong results in a single guess") {
                    let result = sut.evaluate(
                        guess: ["A", "X", "B", "Z"],
                        against: ["A", "B", "C", "D"]
                    )

                    expect(result) == [.correct, .wrong, .misplaced, .wrong]
                }

                it("returns an empty result for mismatched lengths") {
                    let result = sut.evaluate(
                        guess: ["A", "B"],
                        against: ["A", "B", "C", "D"]
                    )

                    expect(result).to(beEmpty())
                }

                it("consumes duplicate letters only from unmatched secret positions") {
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
