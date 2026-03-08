import Nimble
import Quick
import UIKit
@testable import Mastermind

final class UIKitGameViewControllerSpec: AsyncSpec {
    override class func spec() {
        describe("UIKitGameViewController") {
            var themeManager: ThemeManager!
            var module: UIKitGameModule!
            var controller: UIKitGameViewController!
            var window: UIWindow?

            beforeEach {
                themeManager = nil
                module = nil
                controller = nil
                window = nil
            }

            afterEach {
                await MainActor.run {
                    window?.isHidden = true
                    window = nil
                }
            }

            func makeController(
                engine: SnapshotMastermindEngine = SnapshotMastermindEngine()
            ) async {
                await MainActor.run {
                    themeManager = ThemeManager()
                    module = UIKitGameModuleFactory(themeManager: themeManager).createModule(
                        engine: engine
                    )
                    controller = TestSupport.makeUIKitViewController(
                        viewFactory: module.viewFactory
                    )
                }
            }

            func attachWindow() async {
                await MainActor.run {
                    let hostingWindow = UIWindow(frame: controller.view.bounds)
                    hostingWindow.rootViewController = controller
                    hostingWindow.makeKeyAndVisible()
                    window = hostingWindow
                }
            }

            func textField(_ identifier: String) async -> UITextField {
                await MainActor.run {
                    guard let textField = controller.view.textField(withAccessibilityIdentifier: identifier) else {
                        fatalError("Missing text field \(identifier)")
                    }
                    return textField
                }
            }

            func button(_ identifier: String) async -> UIButton {
                await MainActor.run {
                    guard let button = controller.view.button(withAccessibilityIdentifier: identifier) else {
                        fatalError("Missing button \(identifier)")
                    }
                    return button
                }
            }

            describe("editing changed handling") {
                context("when deleting a letter from an evaluated guess") {
                    var firstTextField: UITextField!

                    beforeEach {
                        let configuredEngine = SnapshotMastermindEngine(
                            stubbedSecret: ["T", "E", "S", "T"],
                            stubbedStatuses: [.correct, .wrong, .misplaced, .correct]
                        )
                        await MainActor.run {
                            themeManager = ThemeManager()
                            module = UIKitGameModuleFactory(themeManager: themeManager).createModule(
                                engine: configuredEngine
                            )
                            module.state.letterInputs = ["T", "A", "E", "T"]
                            module.presenter.submitGuess(letterInputs: module.state.letterInputs)
                            controller = TestSupport.makeUIKitViewController(
                                viewFactory: module.viewFactory
                            )
                            firstTextField = controller.view.textField(
                                withAccessibilityIdentifier: "letterInput_0"
                            )
                            firstTextField.text = ""
                            firstTextField.sendActions(for: .editingChanged)
                        }
                    }

                    it("clears the edited field") {
                        await MainActor.run {
                            expect(firstTextField.text) == ""
                        }
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

                    beforeEach {
                        await makeController()
                        await attachWindow()

                        secondTextField = await textField("letterInput_1")
                        await MainActor.run {
                            secondTextField.text = "A"
                            secondTextField.becomeFirstResponder()
                            secondTextField.text = ""
                            secondTextField.sendActions(for: .editingChanged)
                        }
                    }

                    it("keeps focus on the same field") {
                        await MainActor.run {
                            expect(secondTextField.isFirstResponder).to(beTrue())
                        }
                    }

                    it("clears the edited field") {
                        await MainActor.run {
                            expect(secondTextField.text) == ""
                        }
                    }
                }

                context("when every input contains one valid letter") {
                    var checkButton: UIButton!

                    beforeEach {
                        await makeController()
                        checkButton = await button("checkButton")

                        await MainActor.run {
                            for (index, value) in ["A", "B", "C", "D"].enumerated() {
                                let field = controller.view.textField(
                                    withAccessibilityIdentifier: "letterInput_\(index)"
                                )
                                field?.text = value
                                field?.sendActions(for: .editingChanged)
                            }
                        }
                    }

                    it("stores the current inputs in state") {
                        expect(module.state.letterInputs) == ["A", "B", "C", "D"]
                    }

                    it("enables the check button") {
                        await MainActor.run {
                            expect(checkButton.isEnabled).to(beTrue())
                            expect(checkButton.alpha) == 1
                        }
                    }
                }
            }

            describe("UITextFieldDelegate replacement handling") {
                context("when replacing a field with mixed pasted content") {
                    var firstTextField: UITextField!
                    var secondTextField: UITextField!
                    var shouldApplyChange: Bool!

                    beforeEach {
                        await makeController()
                        await attachWindow()

                        firstTextField = await textField("letterInput_0")
                        secondTextField = await textField("letterInput_1")

                        await MainActor.run {
                            firstTextField.becomeFirstResponder()
                            shouldApplyChange = controller.textField(
                                firstTextField,
                                shouldChangeCharactersIn: NSRange(location: 0, length: 0),
                                replacementString: "1ab"
                            )
                        }
                    }

                    it("handles the replacement in the delegate") {
                        expect(shouldApplyChange).to(beFalse())
                    }

                    it("keeps only the last alphabetic character in uppercase") {
                        await MainActor.run {
                            expect(firstTextField.text) == "B"
                        }
                        expect(module.state.letterInputs[0]) == "B"
                    }

                    it("advances focus to the next field") {
                        await MainActor.run {
                            expect(secondTextField.isFirstResponder).to(beTrue())
                        }
                    }
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

    func button(withAccessibilityIdentifier identifier: String) -> UIButton? {
        if let button = self as? UIButton,
           button.accessibilityIdentifier == identifier {
            return button
        }

        for subview in subviews {
            if let button = subview.button(withAccessibilityIdentifier: identifier) {
                return button
            }
        }

        return nil
    }
}
