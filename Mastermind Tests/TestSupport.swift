import AccessibilitySnapshot
import AccessibilitySnapshotCore
import Foundation
import SnapshotTesting
import SwiftUI
import UIKit
@testable import Mastermind

final class TestSupport {
    private init() {}

    private static let iPhone17SnapshotSize = CGSize(width: 402, height: 874)

    @MainActor
    static func makeSwiftUIViewController(viewFactory: SwiftUIGameViewFactory) -> UIViewController {
        let rootView = NavigationStack {
            viewFactory.makeView()
                .navigationTitle("SwiftUI")
                .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.light)

        let controller = UIHostingController(rootView: rootView)
        prepare(controller)
        return controller
    }

    @MainActor
    static func makeInfoViewController(viewFactory: InfoViewFactory) -> UIViewController {
        let rootView = NavigationStack {
            viewFactory.makeView()
                .navigationTitle("Info")
                .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.light)

        let controller = UIHostingController(rootView: rootView)
        prepare(controller)
        return controller
    }

    @MainActor
    static func makeUIKitViewController(
        viewFactory: UIKitGameViewFactory
    ) -> UIKitGameViewController {
        viewFactory.themeManager.isDarkMode = false
        let controller = viewFactory.makeViewController()
        controller.loadViewIfNeeded()
        prepare(controller)
        return controller
    }

    @MainActor
    private static func prepare(_ controller: UIViewController) {
        controller.overrideUserInterfaceStyle = .light
        controller.view.frame = CGRect(origin: .zero, size: iPhone17SnapshotSize)
        controller.view.bounds = CGRect(origin: .zero, size: iPhone17SnapshotSize)
        controller.view.setNeedsLayout()
        controller.view.layoutIfNeeded()
    }

    static func assertAccessibilitySnapshot(
        of controller: UIViewController,
        named name: String,
        fileID: StaticString = #fileID,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        _ = verifySnapshot(
            of: controller,
            as: .accessibilityImage(showActivationPoints: .never),
            named: name,
            snapshotDirectory: centralizedSnapshotDirectory(for: file),
            fileID: fileID,
            file: file,
            testName: "test",
            line: line
        )
    }

    private static func centralizedSnapshotDirectory(for file: StaticString) -> String {
        let fileURL = URL(fileURLWithPath: "\(file)", isDirectory: false)
        let suiteName = fileURL.deletingPathExtension().lastPathComponent

        var directoryURL = fileURL.deletingLastPathComponent()
        while directoryURL.lastPathComponent != "Mastermind Tests", directoryURL.path != "/" {
            directoryURL.deleteLastPathComponent()
        }

        return directoryURL
            .appendingPathComponent("__Snapshots__", isDirectory: true)
            .appendingPathComponent(suiteName, isDirectory: true)
            .path
    }
}
