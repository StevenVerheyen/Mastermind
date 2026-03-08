import Foundation

struct GameState {
    var secret: [Character] = []
    var isGameOver: Bool = false
    var history: [GuessResult] = []

    var attempts: Int {
        history.count
    }
}
