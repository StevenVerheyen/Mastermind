import Nimble
import Quick
@testable import Mastermind

final class GamePresenterSpec: QuickSpec {
    override class func spec() {
        describe("GamePresenter") {
            var interactor: MockInteractorInput!
            var state: GameFeatureState!
            var sut: GamePresenter!

            beforeEach {
                interactor = MockInteractorInput()
                state = GameFeatureState()
                sut = GamePresenter(interactor: interactor, state: state)
                interactor.output = sut
            }

            describe("#initializeGame") {
                context("when initialization is requested multiple times") {
                    beforeEach {
                        sut.initializeGame()
                        sut.initializeGame()
                    }

                    it("starts the game only once") {
                        expect(interactor.startNewGameCallCount) == 1
                    }
                }
            }

            describe("#submitGuess") {
                context("when submitting an incomplete guess") {
                    beforeEach {
                        sut.submitGuess(letterInputs: ["A", "", "C", "D"])
                    }

                    it("shows a validation message") {
                        expect(state.gameMessage) == "Please enter a letter in each box"
                    }

                    it("does not forward the guess to the interactor") {
                        expect(interactor.lastGuess).to(beNil())
                    }
                }

                context("when submitting a guess with invalid non-letter content") {
                    beforeEach {
                        sut.submitGuess(letterInputs: [" a ", "1", " bc ", ""])
                    }

                    it("keeps the normalized text in UI state") {
                        expect(state.letterInputs) == ["A", "1", "BC", ""]
                    }

                    it("shows a validation message without calling the interactor") {
                        expect(state.gameMessage) == "Please enter a letter in each box"
                        expect(interactor.lastGuess).to(beNil())
                    }
                }

                context("when submitting a valid guess with extra whitespace and lowercase letters") {
                    beforeEach {
                        sut.submitGuess(letterInputs: [" a ", "b", " C", "d "])
                    }

                    it("normalizes the inputs before forwarding them") {
                        expect(interactor.lastGuess) == ["A", "B", "C", "D"]
                    }
                }
            }

            describe("#startNewGame") {
                context("when starting a new game after a win") {
                    beforeEach {
                        let winningResult = makeGuessResult(
                            letters: [("W", .correct), ("I", .correct), ("N", .correct), ("S", .correct)]
                        )
                        sut.didEvaluateGuess(
                            state: GameState(
                                secret: ["W", "I", "N", "S"],
                                isGameOver: true,
                                history: [winningResult]
                            ),
                            result: winningResult
                        )

                        sut.startNewGame()
                    }

                    it("asks the interactor for a fresh game") {
                        expect(interactor.startNewGameCallCount) == 1
                    }

                    it("resets the board state") {
                        expect(state.letterInputs) == GameRules.initialInputs
                        expect(state.letterStatuses) == GameRules.initialStatuses
                        expect(state.gameMessage) == GameRules.initialMessage
                        expect(state.isGameWon).to(beFalse())
                    }
                }
            }

            describe("GameInteractorOutputProtocol") {
                describe("#didStartNewGame") {
                    context("when receiving a new game state after stale progress") {
                        beforeEach {
                            state.letterInputs = ["W", "I", "N", "S"]
                            state.letterStatuses = [.correct, .correct, .correct, .correct]
                            state.gameMessage = "Old message"
                            state.isGameWon = true
                            state.attempts = 3
                            state.guessHistory = [makeGuessResult(
                                letters: [("W", .correct), ("I", .correct), ("N", .correct), ("S", .correct)]
                            )]

                            sut.didStartNewGame(state: GameState(secret: ["T", "E", "S", "T"]))
                        }

                        it("restores the default presenter state") {
                            expect(state.letterInputs) == GameRules.initialInputs
                            expect(state.letterStatuses) == GameRules.initialStatuses
                            expect(state.gameMessage) == GameRules.initialMessage
                            expect(state.isGameWon).to(beFalse())
                        }

                        it("clears attempts and history") {
                            expect(state.attempts) == 0
                            expect(state.guessHistory).to(beEmpty())
                        }
                    }
                }

                describe("#didEvaluateGuess") {
                    context("when receiving a winning evaluation") {
                        beforeEach {
                            let winResult = makeGuessResult(
                                letters: [("A", .correct), ("B", .correct), ("C", .correct), ("D", .correct)]
                            )
                            sut.didEvaluateGuess(
                                state: GameState(
                                    secret: ["A", "B", "C", "D"],
                                    isGameOver: true,
                                    history: [winResult]
                                ),
                                result: winResult
                            )
                        }

                        it("marks the UI state as won") {
                            expect(state.isGameWon).to(beTrue())
                        }

                        it("updates the attempts and statuses") {
                            expect(state.attempts) == 1
                            expect(state.letterStatuses) == [.correct, .correct, .correct, .correct]
                        }

                        it("shows a victory message") {
                            expect(state.gameMessage).to(contain("won"))
                        }
                    }

                    context("when receiving a non-winning evaluation") {
                        beforeEach {
                            let result = makeGuessResult(
                                letters: [("A", .correct), ("X", .wrong), ("B", .misplaced), ("Z", .wrong)]
                            )
                            sut.didEvaluateGuess(
                                state: GameState(
                                    secret: ["A", "B", "C", "D"],
                                    isGameOver: false,
                                    history: [result]
                                ),
                                result: result
                            )
                        }

                        it("keeps the win flag cleared") {
                            expect(state.isGameWon).to(beFalse())
                        }

                        it("stores the latest guess state") {
                            expect(state.attempts) == 1
                            expect(state.guessHistory.map(\.statuses)) == [[.correct, .wrong, .misplaced, .wrong]]
                            expect(state.letterStatuses) == [.correct, .wrong, .misplaced, .wrong]
                        }

                        it("restores the default prompt") {
                            expect(state.gameMessage) == GameRules.initialMessage
                        }
                    }
                }
            }

            describe("#clearEvaluationFeedback") {
                context("when clearing evaluation feedback") {
                    beforeEach {
                        sut.clearEvaluationFeedback(currentInputs: ["A", "B", "C", "D"])
                    }

                    it("preserves the current input") {
                        expect(state.letterInputs) == ["A", "B", "C", "D"]
                    }

                    it("clears only the evaluation statuses") {
                        expect(state.letterStatuses) == GameRules.initialStatuses
                    }
                }
            }
        }
    }

    private static func makeGuessResult(
        letters: [(Character, LetterStatus)]
    ) -> GuessResult {
        GuessResult(
            letters: letters.enumerated().map { index, entry in
                LetterResult(id: index, character: entry.0, status: entry.1)
            }
        )
    }
}
