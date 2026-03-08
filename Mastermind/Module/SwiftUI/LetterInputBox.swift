import SwiftUI

struct LetterInputBox: View {

    let index: Int
    @Binding var text: String
    let status: LetterStatus
    let isLandscape: Bool
    let accessibilityValue: String
    let focusedField: FocusState<Int?>.Binding
    let onTextChange: (String, String) -> Void

    var body: some View {
        TextField("", text: sanitizedText)
            .textFieldStyle(.plain)
            .font(.system(size: isLandscape ? 22 : 32, weight: .bold, design: .monospaced))
            .multilineTextAlignment(.center)
            .textInputAutocapitalization(.characters)
            .autocorrectionDisabled()
            .submitLabel(index == GameRules.codeLength - 1 ? .done : .next)
            .frame(minWidth: 44, minHeight: 44)
            .frame(width: isLandscape ? 48 : 64, height: isLandscape ? 48 : 64)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.primary, lineWidth: 2)
            )
            .focused(focusedField, equals: index)
            .onChange(of: text) { oldValue, newValue in
                onTextChange(oldValue, newValue)
            }
            .accessibilityLabel("Letter \(index + 1)")
            .accessibilityValue(accessibilityValue)
            .accessibilityHint("Enter a letter from A to Z")
            .accessibilityIdentifier("input_\(index)")
    }

    private var backgroundColor: Color {
        guard status != .unknown else { return .clear }
        return AppColors.color(for: status).opacity(0.3)
    }

    private var sanitizedText: Binding<String> {
        Binding(
            get: { text },
            set: { newValue in
                let sanitized = sanitizedLetter(from: newValue, previousValue: text)

                if text == sanitized, newValue != sanitized {
                    text = ""
                }

                text = sanitized
            }
        )
    }

    /// Returns a sanitized string value. Filters out non-letter values.
    /// If only a non-letter value is entered an empty string is returned.
    private func sanitizedLetter(from newValue: String, previousValue: String) -> String {
        let letters = newValue.uppercased().filter(\.isLetter)

        guard let latestLetter = letters.last else {
            return ""
        }

        guard let previousLetter = previousValue.uppercased().first, letters.count > 1 else {
            return String(latestLetter)
        }

        for letter in letters.reversed() where letter != previousLetter {
            return String(letter)
        }

        return String(previousLetter)
    }
}
