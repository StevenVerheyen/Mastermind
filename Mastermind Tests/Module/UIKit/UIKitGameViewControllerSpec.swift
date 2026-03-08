import Nimble
import Quick
import UIKit
@testable import Mastermind

final class UIKitGameViewControllerSpec: QuickSpec {
    override class func spec() {
        describe("UIKitGameViewController") {
            var engine: SnapshotMastermindEngine!
            var themeManager: ThemeManager!
            var module: UIKitGameModule!
            var controller: UIKitGameViewController!

            context("when deleting a letter from an evaluated guess") {
                var firstTextField: UITextField!

                beforeEach {
                    waitUntil { done in
                        DispatchQueue.main.async {
                            engine = SnapshotMastermindEngine(
                                stubbedSecret: ["T", "E", "S", "T"],
                                stubbedStatuses: [.correct, .wrong, .misplaced, .correct]
                            )
                            themeManager = ThemeManager()
                            module = UIKitGameModuleFactory(themeManager: themeManager).createModule(
                                engine: engine
                            )
                            module.state.letterInputs = ["T", "A", "E", "T"]
                            module.presenter.submitGuess(letterInputs: module.state.letterInputs)

                            controller = TestSupport.makeUIKitViewController(
                                viewFactory: module.viewFactory
                            )
                            firstTextField = controller.view.textField(withAccessibilityIdentifier: "letterInput_0")
                            firstTextField.text = ""
                            firstTextField.sendActions(for: .editingChanged)
                            done()
                        }
                    }
                }

                it("clears the edited field") {
                    expect(firstTextField.text) == ""
                }

                it("updates the current inputs in state") {
                    expect(module.state.letterInputs) == ["", "A", "E", "T"]
                }

                it("resets the evaluation statuses") {
                    expect(module.state.letterStatuses) == GameRules.initialStatuses
                }
            }

            context("when deleting the current value from a focused input") {
                var secondTextField: UITextField!
                var window: UIWindow!

                beforeEach {
                    waitUntil { done in
                        DispatchQueue.main.async {
                            themeManager = ThemeManager()
                            module = UIKitGameModuleFactory(themeManager: themeManager).createModule(
                                engine: SnapshotMastermindEngine()
                            )

                            controller = TestSupport.makeUIKitViewController(
                                viewFactory: module.viewFactory
                            )
                            window = UIWindow(frame: controller.view.bounds)
                            window.rootViewController = controller
                            window.makeKeyAndVisible()

                            secondTextField = controller.view.textField(withAccessibilityIdentifier: "letterInput_1")
                            secondTextField.text = "A"
                            secondTextField.becomeFirstResponder()
                            secondTextField.text = ""
                            secondTextField.sendActions(for: .editingChanged)
                            done()
                        }
                    }
                }

                afterEach {
                    waitUntil { done in
                        DispatchQueue.main.async {
                            window?.isHidden = true
                            window = nil
                            done()
                        }
                    }
                }

                it("keeps focus on the same field") {
                    expect(secondTextField.isFirstResponder).to(beTrue())
                }

                it("clears the edited field") {
                    expect(secondTextField.text) == ""
                }
            }
        }
    }
}

private extension UIView {
    func textField(withAccessibilityIdentifier identifier: String) -> UITextField? {
        if let textField = self as? UITextField,
           textField.accessibilityIdentifier == identifier {
            return textField
        }

        for subview in subviews {
            if let textField = subview.textField(withAccessibilityIdentifier: identifier) {
                return textField
            }
        }

        return nil
    }
}
