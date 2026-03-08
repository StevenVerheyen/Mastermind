import Foundation
import Testing

final class SnapshotTestSupport {
    private init() {}

    static func assertRunningOnIPhone17() {
        #expect(
            ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] == "iPhone 17",
            "Snapshot tests must run on the iPhone 17 simulator."
        )
    }
}
