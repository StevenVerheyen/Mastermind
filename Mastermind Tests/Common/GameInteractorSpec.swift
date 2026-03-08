import Nimble
import Quick
@testable import Mastermind

final class GameInteractorSpec: QuickSpec {
    override class func spec() {
        describe("GameInteractor") {
            var engine: MockMastermindEngine!
            var output: MockInteractorOutput!
            var sut: GameInteractor!

            beforeEach {
                engine = MockMastermindEngine()
                output = MockInteractorOutput()
                sut = GameInteractor(engine: engine)
                sut.output = output
                engine.stubbedSecret = ["A", "B", "C", "D"]
            }

            context("when starting a new game") {
                beforeEach {
                    engine.stubbedSecret = ["T", "E", "S", "T"]
                    sut.startNewGame()
                }

                it("publishes the newly generated secret") {
                    expect(output.didStartNewGameCalled).to(beTrue())
                    expect(output.lastState?.secret) == ["T", "E", "S", "T"]
                }

                it("resets the session state") {
                    expect(output.lastState?.attempts) == 0
                    expect(output.lastState?.history).to(beEmpty())
                    expect(output.lastState?.isGameOver).to(beFalse())
                }
            }

            context("when evaluating a valid guess") {
                beforeEach {
                    engine.stubbedStatuses = [.correct, .wrong, .misplaced, .correct]
                    sut.startNewGame()
                    sut.evaluateGuess(["A", "X", "B", "D"])
                }

                it("records the attempt in history") {
                    expect(output.lastState?.attempts) == 1
                    expect(output.lastState?.history.count) == 1
                }

                it("maps the engine statuses back onto the guessed letters") {
                    expect(output.lastResult?.statuses) == [.correct, .wrong, .misplaced, .correct]
                    expect(output.lastResult?.letters.map(\.character)) == ["A", "X", "B", "D"]
                }
            }

            context("when the guess wins the game") {
                beforeEach {
                    engine.stubbedStatuses = [.correct, .correct, .correct, .correct]
                    sut.startNewGame()
                    sut.evaluateGuess(["A", "B", "C", "D"])
                }

                it("marks the result as a win") {
                    expect(output.lastResult?.isWin).to(beTrue())
                }

                it("ends the game") {
                    expect(output.lastState?.isGameOver).to(beTrue())
                }

                it("ignores any later guesses") {
                    sut.evaluateGuess(["W", "X", "Y", "Z"])

                    expect(output.evaluateCallCount) == 1
                    expect(output.lastState?.attempts) == 1
                }
            }

            context("when the engine returns malformed output") {
                beforeEach {
                    engine.stubbedStatuses = [.correct]
                    sut.startNewGame()
                    sut.evaluateGuess(["A", "B", "C", "D"])
                }

                it("does not publish a guess evaluation") {
                    expect(output.evaluateCallCount) == 0
                    expect(output.lastState?.attempts) == 0
                    expect(output.lastState?.history).to(beEmpty())
                }
            }

            context("when the guess length is invalid") {
                beforeEach {
                    engine.stubbedStatuses = [.correct, .correct, .correct, .correct]
                    sut.startNewGame()
                    sut.evaluateGuess(["A", "B", "C"])
                }

                it("ignores the guess") {
                    expect(output.evaluateCallCount) == 0
                    expect(output.lastState?.attempts) == 0
                    expect(output.lastState?.history).to(beEmpty())
                }
            }
        }
    }
}
