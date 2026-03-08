import ConfettiSwiftUI
import SwiftUI

struct SwiftUIGameView: View {

    @Bindable var state: GameFeatureState
    let presenter: GamePresentationLogic
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @FocusState private var focusedField: Int?
    @State private var confettiTrigger = 0

    private var isLandscape: Bool { verticalSizeClass == .compact }

    /*
     === 🟠 explanation 🟠 ===
     The confetti part is totally unnecessary. This is merely to
     showcase the usage of SPM (Swift Package Manager)
     */
    var body: some View {
        Group {
            if isLandscape {
                landscapeBody
            } else {
                portraitBody
            }
        }
        .onTapGesture {
            // dismisses the keyboard when tapping outside the input fields
            focusedField = nil
        }
        .onChange(of: state.isGameWon) { oldValue, isGameWon in
            guard isGameWon && !oldValue else { return }
            // dismisses the keyboard when winning the game
            focusedField = nil
            confettiTrigger += 1
        }
        .confettiCannon(trigger: $confettiTrigger)
    }

    private var portraitBody: some View {
        ScrollView {
            VStack(spacing: 32) {
                headerSection
                inputSection
                checkButton
                historySection
            }
            .padding()
        }
    }

    private var landscapeBody: some View {
        HStack(alignment: .top, spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    headerSection
                    inputSection
                    checkButton
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity)

            ScrollView {
                historySection
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var accentColor: Color {
        AppColors.adaptiveAccent(for: colorScheme)
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack {
            Text("Mastermind")
                .font(isLandscape ? .title2 : .largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(accentColor)
                .accessibilityAddTraits(.isHeader)

            Text(state.gameMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("gameMessage")

            if !state.isGameWon && state.attempts > 0 {
                Text("Attempts: \(state.attempts)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var inputSection: some View {
        HStack(spacing: 12) {
            ForEach(0..<GameRules.codeLength, id: \.self) { index in
                LetterInputBox(
                    index: index,
                    text: $state.letterInputs[index],
                    status: state.letterStatuses[index],
                    isLandscape: isLandscape,
                    accessibilityValue: letterAccessibilityValue(at: index),
                    focusedField: $focusedField
                ) { oldValue, newValue in
                    handleInputChange(
                        at: index,
                        oldValue: oldValue,
                        newValue: newValue
                    )
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Letter input boxes")
    }

    private func letterAccessibilityValue(at index: Int) -> String {
        let input = state.letterInputs[index]
        let letter = input.isEmpty ? "empty" : input

        let status = state.letterStatuses[index]
        guard status != .unknown else { return letter }
        return "\(letter), \(status.accessibilityDescription)"
    }

    private var canSubmitGuess: Bool {
        !state.isGameWon && state.letterInputs.allSatisfy { $0.count == 1 && $0.first?.isLetter == true }
    }

    private var checkButton: some View {
        VStack(spacing: 12) {
            Button {
                presenter.submitGuess(letterInputs: state.letterInputs)
            } label: {
                Text("Check")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: isLandscape ? 36 : 44, idealHeight: isLandscape ? 40 : 50)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!canSubmitGuess)
            .opacity(canSubmitGuess ? 1.0 : 0.5)
            .accessibilityLabel("Check guess")
            .accessibilityHint("Submits your 4-letter guess for evaluation")
            .accessibilityIdentifier("checkButton")

            if state.isGameWon {
                Button {
                    presenter.startNewGame()
                    focusedField = 0
                } label: {
                    Text("New Game")
                        .font(.headline)
                        .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: isLandscape ? 36 : 44, idealHeight: isLandscape ? 40 : 50)
                    .background(accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityLabel("Start new game")
                .accessibilityHint("Generates a new secret code and resets the board")
                .accessibilityIdentifier("newGameButton")
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !state.guessHistory.isEmpty {
                Text("Previous Guesses")
                    .font(.headline)
                    .foregroundStyle(accentColor)
                    .accessibilityAddTraits(.isHeader)

                ForEach(Array(state.guessHistory.enumerated().reversed()), id: \.offset) { index, result in
                    historyRow(attempt: index + 1, result: result)
                }
            }
        }
    }

    private func historyRow(attempt: Int, result: GuessResult) -> some View {
        HStack(spacing: 8) {
            Text("#\(attempt)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 30, alignment: .leading)

            ForEach(result.letters) { letter in
                Text(String(letter.character))
                    .font(.system(size: isLandscape ? 14 : 18, weight: .bold, design: .monospaced))
                    .frame(width: isLandscape ? 32 : 40, height: isLandscape ? 32 : 40)
                    .background(AppColors.color(for: letter.status).opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.color(for: letter.status), lineWidth: 1)
                    )
                    .accessibilityHidden(true)
            }

            Spacer()
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Attempt \(attempt): \(result.letters.map(\.accessibilityDescription).joined(separator: ", "))")
    }

    // MARK: - Input Handling

    private func handleInputChange(at index: Int, oldValue: String, newValue: String) {
        if !newValue.isEmpty, index < GameRules.codeLength - 1 {
            focusedField = index + 1
        }

        presenter.clearEvaluationFeedback(currentInputs: state.letterInputs)
    }
}
