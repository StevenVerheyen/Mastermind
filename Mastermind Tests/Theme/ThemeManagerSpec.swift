import Nimble
import Quick
import SwiftUI
import UIKit
@testable import Mastermind

final class ThemeManagerSpec: QuickSpec {
    override class func spec() {
        describe("ThemeManager") {
            var suiteName: String!
            var userDefaults: UserDefaults!
            let isDarkModeKey = "ThemeManagerSpec.isDarkMode"

            beforeEach {
                suiteName = "ThemeManagerSpec.\(UUID().uuidString)"
                userDefaults = UserDefaults(suiteName: suiteName)
            }

            afterEach {
                userDefaults.removePersistentDomain(forName: suiteName)
            }

            it("defaults to light mode when no preference has been saved") {
                let themeManager = ThemeManager(
                    userDefaults: userDefaults,
                    isDarkModeKey: isDarkModeKey
                )

                expect(themeManager.isDarkMode).to(beFalse())
                expect(themeManager.colorScheme) == .light
            }

            it("restores the saved dark mode preference") {
                userDefaults.set(true, forKey: isDarkModeKey)

                let themeManager = ThemeManager(
                    userDefaults: userDefaults,
                    isDarkModeKey: isDarkModeKey
                )

                expect(themeManager.isDarkMode).to(beTrue())
                expect(themeManager.colorScheme) == .dark
            }

            it("persists changes to the selected theme") {
                let themeManager = ThemeManager(
                    userDefaults: userDefaults,
                    isDarkModeKey: isDarkModeKey
                )

                themeManager.isDarkMode = true
                expect(userDefaults.object(forKey: isDarkModeKey) as? Bool) == true
                expect(themeManager.colorScheme) == .dark

                themeManager.isDarkMode = false
                expect(userDefaults.object(forKey: isDarkModeKey) as? Bool) == false
                expect(themeManager.colorScheme) == .light
            }
        }

        describe("AppColors") {
            describe("adaptive accent colors") {
                it("uses the expected accent colors for each appearance") {
                    expectColor(UIColor(AppColors.adaptiveAccent(for: .dark)), toMatch: AppColors.primaryUI)
                    expectColor(UIColor(AppColors.adaptiveAccent(for: .light)), toMatch: AppColors.secondaryUI)
                    expectColor(AppColors.adaptiveAccentUI(isDarkMode: true), toMatch: AppColors.primaryUI)
                    expectColor(AppColors.adaptiveAccentUI(isDarkMode: false), toMatch: AppColors.secondaryUI)
                }
            }

            describe("status colors") {
                it("maps each letter status to matching SwiftUI and UIKit colors") {
                    let expectedColors: [(LetterStatus, UIColor)] = [
                        (.correct, .systemGreen),
                        (.misplaced, .systemOrange),
                        (.wrong, .systemRed),
                        (.unknown, .clear)
                    ]

                    for (status, expectedColor) in expectedColors {
                        expectColor(UIColor(AppColors.color(for: status)), toMatch: expectedColor)
                        expectColor(AppColors.uiColor(for: status), toMatch: expectedColor)
                    }
                }
            }
        }
    }

    private static func expectColor(_ actualColor: UIColor, toMatch expectedColor: UIColor) {
        let actual = colorComponents(of: actualColor)
        let expected = colorComponents(of: expectedColor)

        expect(actual.red).to(beCloseTo(expected.red, within: 0.001))
        expect(actual.green).to(beCloseTo(expected.green, within: 0.001))
        expect(actual.blue).to(beCloseTo(expected.blue, within: 0.001))
        expect(actual.alpha).to(beCloseTo(expected.alpha, within: 0.001))
    }

    private static func colorComponents(of color: UIColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
            .getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}
