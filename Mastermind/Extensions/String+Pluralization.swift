import Foundation

extension String {
    var pluralized: String { self + "s" }

    func pluralized(for count: Int) -> String {
        count == 1 ? self : pluralized
    }
}
