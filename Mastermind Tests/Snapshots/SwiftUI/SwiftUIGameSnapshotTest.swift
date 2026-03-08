import AccessibilitySnapshot
import AccessibilitySnapshotCore
import SnapshotTesting
import Testing
import UIKit
@testable import Mastermind

@Suite(.serialized, .snapshots(record: .failed))
struct SwiftUIGameSnapshotTest {
    @MainActor
    @Test("records the initial SwiftUI game state")
    func recordsInitialSwiftUIGameState() {
        SnapshotTestSupport.assertRunningOnIPhone17()

        let module = SwiftUIGameModuleFactory().createModule(
            engine: SnapshotMastermindEngine()
        )
        let controller = TestSupport.makeSwiftUIViewController(
            viewFactory: module.viewFactory
        )

        #expect(module.state.gameMessage == GameRules.initialMessage)

        TestSupport.assertAccessibilitySnapshot(
            of: controller,
            named: "swiftui-initial"
        )
    }

    @MainActor
    @Test("records a winning SwiftUI game state")
    func recordsWinningSwiftUIGameState() {
        SnapshotTestSupport.assertRunningOnIPhone17()

        let engine = SnapshotMastermindEngine(
            stubbedSecret: ["W", "I", "N", "S"],
            stubbedStatuses: [.correct, .correct, .correct, .correct]
        )
        let module = SwiftUIGameModuleFactory().createModule(engine: engine)
        module.state.letterInputs = ["W", "I", "N", "S"]
        module.presenter.submitGuess(letterInputs: module.state.letterInputs)

        let controller = TestSupport.makeSwiftUIViewController(
            viewFactory: module.viewFactory
        )

        #expect(module.state.isGameWon)
        #expect(module.state.gameMessage.contains("won"))

        TestSupport.assertAccessibilitySnapshot(
            of: controller,
            named: "swiftui-win"
        )
    }

    @MainActor
    @Test("records an evaluated SwiftUI game state")
    func recordsEvaluatedSwiftUIGameState() {
        SnapshotTestSupport.assertRunningOnIPhone17()

        let engine = SnapshotMastermindEngine(
            stubbedSecret: ["T", "E", "S", "T"],
            stubbedStatuses: [.correct, .wrong, .misplaced, .correct]
        )
        let module = SwiftUIGameModuleFactory().createModule(engine: engine)
        module.state.letterInputs = ["T", "A", "E", "T"]
        module.presenter.submitGuess(letterInputs: module.state.letterInputs)

        let controller = TestSupport.makeSwiftUIViewController(
            viewFactory: module.viewFactory
        )

        #expect(module.state.attempts == 1)
        #expect(module.state.letterStatuses == [.correct, .wrong, .misplaced, .correct])

        TestSupport.assertAccessibilitySnapshot(
            of: controller,
            named: "swiftui-evaluated"
        )
    }
}
