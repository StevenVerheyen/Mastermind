import AccessibilitySnapshot
import AccessibilitySnapshotCore
import SnapshotTesting
import Testing
import UIKit
@testable import Mastermind

@Suite(.serialized, .snapshots(record: .failed))
struct UIKitGameSnapshotTest {
    @MainActor
    @Test("records the initial UIKit game state")
    func recordsInitialUIKitGameState() {
        SnapshotTestSupport.assertRunningOnIPhone17()

        let themeManager = ThemeManager()
        let module = UIKitGameModuleFactory(themeManager: themeManager).createModule(
            engine: SnapshotMastermindEngine()
        )
        let controller = TestSupport.makeUIKitViewController(
            viewFactory: module.viewFactory
        )

        #expect(module.state.gameMessage == GameRules.initialMessage)

        TestSupport.assertAccessibilitySnapshot(
            of: controller,
            named: "uikit-initial"
        )
    }

    @MainActor
    @Test("records an evaluated UIKit game state")
    func recordsEvaluatedUIKitGameState() {
        SnapshotTestSupport.assertRunningOnIPhone17()

        let engine = SnapshotMastermindEngine(
            stubbedSecret: ["T", "E", "S", "T"],
            stubbedStatuses: [.correct, .wrong, .misplaced, .correct]
        )
        let themeManager = ThemeManager()
        let module = UIKitGameModuleFactory(themeManager: themeManager).createModule(
            engine: engine
        )
        module.state.letterInputs = ["T", "A", "E", "T"]
        module.presenter.submitGuess(letterInputs: module.state.letterInputs)

        let controller = TestSupport.makeUIKitViewController(
            viewFactory: module.viewFactory
        )

        #expect(module.state.attempts == 1)
        #expect(module.state.letterStatuses == [.correct, .wrong, .misplaced, .correct])

        TestSupport.assertAccessibilitySnapshot(
            of: controller,
            named: "uikit-evaluated"
        )
    }

    @MainActor
    @Test("records a winning UIKit game state")
    func recordsWinningUIKitGameState() {
        SnapshotTestSupport.assertRunningOnIPhone17()

        let engine = SnapshotMastermindEngine(
            stubbedSecret: ["W", "I", "N", "S"],
            stubbedStatuses: [.correct, .correct, .correct, .correct]
        )
        let themeManager = ThemeManager()
        let module = UIKitGameModuleFactory(themeManager: themeManager).createModule(
            engine: engine
        )
        module.state.letterInputs = ["W", "I", "N", "S"]
        module.presenter.submitGuess(letterInputs: module.state.letterInputs)

        let controller = TestSupport.makeUIKitViewController(
            viewFactory: module.viewFactory
        )

        #expect(module.state.isGameWon)
        #expect(module.state.gameMessage.contains("won"))

        TestSupport.assertAccessibilitySnapshot(
            of: controller,
            named: "uikit-win"
        )
    }
}
