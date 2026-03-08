import SwiftUI

struct InfoViewFactory {
    let contentViewModel: InfoContentViewModel

    func makeView() -> InfoView {
        InfoView(viewModel: contentViewModel)
    }
}
