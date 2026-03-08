import Foundation

struct InfoModule {
    let contentViewModel: InfoContentViewModel
    let viewModel: InfoViewModel
    let viewFactory: InfoViewFactory
}

struct InfoModuleFactory {
    func createModule() -> InfoModule {
        let contentViewModel = InfoContentViewModel()
        let viewFactory = InfoViewFactory(contentViewModel: contentViewModel)
        let viewModel = InfoViewModel(viewFactory: viewFactory)

        return InfoModule(
            contentViewModel: contentViewModel,
            viewModel: viewModel,
            viewFactory: viewFactory
        )
    }

    func createViewFactory() -> InfoViewFactory {
        createModule().viewFactory
    }
}
