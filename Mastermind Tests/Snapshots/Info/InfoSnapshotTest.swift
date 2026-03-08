import AccessibilitySnapshot
import AccessibilitySnapshotCore
import SnapshotTesting
import Testing
import UIKit
@testable import Mastermind

@Suite(.serialized, .snapshots(record: .failed))
struct InfoSnapshotTest {
    @MainActor
    @Test("records the info screen")
    func recordsInfoScreen() {
        SnapshotTestSupport.assertRunningOnIPhone17()

        let module = InfoModuleFactory().createModule()
        let controller = TestSupport.makeInfoViewController(
            viewFactory: module.viewFactory
        )

        TestSupport.assertAccessibilitySnapshot(
            of: controller,
            named: "info"
        )
    }
}
