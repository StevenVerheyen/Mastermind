import Nimble
import Quick
@testable import Mastermind

final class SwiftUIGameViewModelSpec: QuickSpec {
    override class func spec() {
        describe("SwiftUIGameViewModel") {
            describe("#openFeature") {
                it("opens a factory-backed feature view") {
                    let module = SwiftUIGameModuleFactory().createModule()
                    let view = module.viewModel.openFeature()

                    expect(view.state).to(beIdenticalTo(module.state))
                    expect(view.presenter).to(beIdenticalTo(module.presenter))
                }

                it("reuses the same feature session across repeated opens") {
                    let module = SwiftUIGameModuleFactory().createModule()
                    let firstView = module.viewModel.openFeature()
                    let secondView = module.viewModel.openFeature()

                    expect(firstView.state).to(beIdenticalTo(secondView.state))
                    expect(firstView.presenter).to(beIdenticalTo(secondView.presenter))
                }
            }
        }
    }
}
