import Nimble
import Quick
@testable import Mastermind

final class StringPluralizationSpec: QuickSpec {
    override class func spec() {
        describe("String.pluralized(for:)") {
            it("adds s to a word") {
                expect("game".pluralized(for: 2)) == "games"
            }

            it("keeps the implementation simple for irregular words") {
                expect("story".pluralized(for: 2)) == "storys"
                expect("box".pluralized(for: 2)) == "boxs"
            }

            it("keeps the singular form when the count is one") {
                expect("attempt".pluralized(for: 1)) == "attempt"
            }

            it("uses the plural form when the count is not one") {
                expect("attempt".pluralized(for: 0)) == "attempts"
                expect("attempt".pluralized(for: 2)) == "attempts"
            }
        }
    }
}
