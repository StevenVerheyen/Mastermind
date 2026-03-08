import Nimble
import Quick
@testable import Mastermind

final class InfoModuleSpec: QuickSpec {
    override class func spec() {
        describe("InfoModuleFactory") {
            describe("#createModule") {
                it("creates a module whose view factory shares the same content view model") {
                    let module = InfoModuleFactory().createModule()

                    expect(module.viewFactory.contentViewModel).to(beIdenticalTo(module.contentViewModel))
                }

                it("creates a parent-facing view model that opens the same feature view") {
                    let module = InfoModuleFactory().createModule()
                    let view = module.viewModel.openFeature()

                    expect(view.viewModel).to(beIdenticalTo(module.contentViewModel))
                }
            }
        }

        describe("InfoContentViewModel") {
            it("keeps the collections that InfoView indexes at safe sizes") {
                let viewModel = InfoContentViewModel()

                expect(viewModel.themeColorPreviews.count) == 2
                expect(viewModel.accessibilityBullets.count) >= 5
                expect(viewModel.accessibilityBullets.last?.title) == "Accessibility Identifiers"
            }
        }
    }
}
