import Observation
import UIKit

final class UIKitGameViewController: UIViewController {

    private let state: GameFeatureState
    private let presenter: GamePresentationLogic
    private let themeManager: ThemeManager

    private var textFields: [UITextField] = []
    private var titleLabel = UILabel()
    private var messageLabel = UILabel()
    private var attemptsLabel = UILabel()
    private var previousGuessesLabel = UILabel()
    private var checkButton = UIButton(type: .system)
    private var newGameButton = UIButton(type: .system)
    private var historyStackView = UIStackView()
    private var inputStack = UIStackView()
    private var inputPanelStack = UIStackView()
    private var historyPanelStack = UIStackView()
    private var rootStack = UIStackView()
    private var scrollView = UIScrollView()
    private var textFieldHeightConstraints: [NSLayoutConstraint] = []
    private var checkButtonHeightConstraint: NSLayoutConstraint?
    private var newGameButtonHeightConstraint: NSLayoutConstraint?
    private var isLandscapeLayout: Bool?

    // MARK: - Init

    init(state: GameFeatureState, presenter: GamePresentationLogic, themeManager: ThemeManager) {
        self.state = state
        self.presenter = presenter
        self.themeManager = themeManager
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI()
        observeState()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutForOrientation()
    }

    private func updateLayoutForOrientation() {
        let isLandscape = view.bounds.width > view.bounds.height
        guard isLandscape != isLandscapeLayout else { return }
        isLandscapeLayout = isLandscape

        rootStack.axis = isLandscape ? .horizontal : .vertical
        rootStack.distribution = isLandscape ? .fillEqually : .fill
        rootStack.alignment = isLandscape ? .top : .fill
        rootStack.spacing = isLandscape ? 16 : 24

        inputPanelStack.spacing = isLandscape ? 8 : 16
        inputPanelStack.setCustomSpacing(isLandscape ? 16 : 32, after: attemptsLabel)
        inputPanelStack.setCustomSpacing(isLandscape ? 12 : 24, after: inputStack)

        titleLabel.font = .systemFont(ofSize: isLandscape ? 24 : 34, weight: .bold)

        let textFieldFontSize: CGFloat = isLandscape ? 22 : 32
        textFields.forEach { $0.font = .monospacedSystemFont(ofSize: textFieldFontSize, weight: .bold) }
        textFieldHeightConstraints.forEach { $0.constant = isLandscape ? 48 : 64 }

        checkButtonHeightConstraint?.constant = isLandscape ? 40 : 50
        newGameButtonHeightConstraint?.constant = isLandscape ? 40 : 50

        updateHistory()
    }

    private var adaptiveAccentColor: UIColor {
        AppColors.adaptiveAccentUI(isDarkMode: themeManager.isDarkMode)
    }

    private var canSubmitGuess: Bool {
        !state.isGameWon && state.letterInputs.allSatisfy { $0.count == 1 && $0.first?.isLetter == true }
    }

    private func observeState() {
        withObservationTracking {
            _ = state.letterInputs
            _ = state.letterStatuses
            _ = state.gameMessage
            _ = state.isGameWon
            _ = state.attempts
            _ = state.guessHistory
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
                self?.observeState()
            }
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        titleLabel.text = "Mastermind"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = adaptiveAccentColor
        titleLabel.textAlignment = .center
        titleLabel.accessibilityTraits = .header

        messageLabel.font = .preferredFont(forTextStyle: .subheadline)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.accessibilityIdentifier = "gameMessage"

        attemptsLabel.font = .preferredFont(forTextStyle: .caption1)
        attemptsLabel.textColor = .secondaryLabel
        attemptsLabel.textAlignment = .center
        attemptsLabel.adjustsFontForContentSizeCategory = true

        inputStack.axis = .horizontal
        inputStack.spacing = 12
        inputStack.distribution = .fillEqually
        inputStack.accessibilityLabel = "Letter input boxes"

        for index in 0..<GameRules.codeLength {
            let textField = createLetterTextField(tag: index)
            textFields.append(textField)
            inputStack.addArrangedSubview(textField)
        }

        checkButton = createStyledButton(
            title: "Check",
            backgroundColor: AppColors.primaryUI,
            action: #selector(checkTapped)
        )
        checkButton.accessibilityLabel = "Check guess"
        checkButton.accessibilityHint = "Submits your 4-letter guess for evaluation"
        checkButton.accessibilityIdentifier = "checkButton"

        newGameButton = createStyledButton(
            title: "New Game",
            backgroundColor: adaptiveAccentColor,
            action: #selector(newGameTapped)
        )
        newGameButton.isHidden = true
        newGameButton.accessibilityLabel = "Start new game"
        newGameButton.accessibilityHint = "Generates a new secret code and resets the board"
        newGameButton.accessibilityIdentifier = "newGameButton"

        previousGuessesLabel.text = "Previous Guesses"
        previousGuessesLabel.font = .preferredFont(forTextStyle: .headline)
        previousGuessesLabel.textColor = adaptiveAccentColor
        previousGuessesLabel.adjustsFontForContentSizeCategory = true
        previousGuessesLabel.accessibilityTraits = .header

        historyStackView.axis = .vertical
        historyStackView.spacing = 6

        inputPanelStack = UIStackView(arrangedSubviews: [
            titleLabel, messageLabel, attemptsLabel,
            inputStack, checkButton, newGameButton
        ])
        inputPanelStack.axis = .vertical
        inputPanelStack.spacing = 16
        inputPanelStack.alignment = .fill
        inputPanelStack.setCustomSpacing(32, after: attemptsLabel)
        inputPanelStack.setCustomSpacing(24, after: inputStack)

        historyPanelStack = UIStackView(arrangedSubviews: [
            previousGuessesLabel, historyStackView
        ])
        historyPanelStack.axis = .vertical
        historyPanelStack.spacing = 8
        historyPanelStack.alignment = .fill

        rootStack = UIStackView(arrangedSubviews: [inputPanelStack, historyPanelStack])
        rootStack.spacing = 24

        checkButtonHeightConstraint = checkButton.heightAnchor.constraint(equalToConstant: 50)
        newGameButtonHeightConstraint = newGameButton.heightAnchor.constraint(equalToConstant: 50)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        rootStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(rootStack)

        var constraints: [NSLayoutConstraint] = [
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            rootStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            rootStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            rootStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            rootStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            rootStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48),
        ]
        constraints += [checkButtonHeightConstraint, newGameButtonHeightConstraint].compactMap { $0 }
        NSLayoutConstraint.activate(constraints)

        for textField in textFields {
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            let heightConstraint = textField.heightAnchor.constraint(equalToConstant: 64)
            heightConstraint.isActive = true
            textFieldHeightConstraints.append(heightConstraint)
        }
    }

    private func createLetterTextField(tag: Int) -> UITextField {
        let textField = UITextField()
        textField.tag = tag
        textField.font = .monospacedSystemFont(ofSize: 32, weight: .bold)
        textField.textAlignment = .center
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 2
        textField.layer.borderColor = AppColors.primaryUI.cgColor
        textField.backgroundColor = .systemBackground
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.accessibilityLabel = "Letter \(tag + 1)"
        textField.accessibilityHint = "Enter a letter from A to Z"
        textField.accessibilityIdentifier = "letterInput_\(tag)"
        return textField
    }

    private func createStyledButton(
        title: String,
        backgroundColor: UIColor,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 12
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - Actions

    @objc private func checkTapped() {
        presenter.submitGuess(letterInputs: currentLetterInputs)
        view.endEditing(true)
    }

    @objc private func newGameTapped() {
        presenter.startNewGame()
        for textField in textFields {
            textField.text = ""
            textField.backgroundColor = .systemBackground
        }
        textFields.first?.becomeFirstResponder()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        let filtered = String(text.uppercased().filter(\.isLetter).prefix(1))
        textField.text = filtered

        if !filtered.isEmpty, textField.tag < GameRules.codeLength - 1 {
            textFields[textField.tag + 1].becomeFirstResponder()
        }

        for textField in textFields {
            textField.backgroundColor = .systemBackground
        }

        presenter.clearEvaluationFeedback(currentInputs: currentLetterInputs)
        updateCheckButtonState()
    }

    private var currentLetterInputs: [String] {
        textFields.map { $0.text ?? "" }
    }

    private func updateCheckButtonState() {
        let inputs = currentLetterInputs
        for (index, input) in inputs.enumerated() {
            state.letterInputs[index] = input
        }

        let canCheck = canSubmitGuess
        checkButton.isEnabled = canCheck
        checkButton.alpha = canCheck ? 1.0 : 0.5
    }

    // MARK: - UI Update

    func refreshTheme() {
        let accent = adaptiveAccentColor
        titleLabel.textColor = accent
        previousGuessesLabel.textColor = accent
        newGameButton.backgroundColor = accent
        overrideUserInterfaceStyle = themeManager.isDarkMode ? .dark : .light
        updateHistory()
    }

    fileprivate func updateUI() {
        messageLabel.text = state.gameMessage
        let shouldShowAttempts = !state.isGameWon && state.attempts > 0
        attemptsLabel.text = shouldShowAttempts ? "Attempts: \(state.attempts)" : ""
        attemptsLabel.isHidden = !shouldShowAttempts
        let canCheck = canSubmitGuess
        checkButton.isEnabled = canCheck
        checkButton.alpha = canCheck ? 1.0 : 0.5
        newGameButton.isHidden = !state.isGameWon

        for (index, textField) in textFields.enumerated() {
            let status = state.letterStatuses[index]
            let input = state.letterInputs[index]
            textField.text = input
            let letter = input.isEmpty ? "empty" : input
            if status != .unknown {
                textField.backgroundColor = AppColors.uiColor(for: status).withAlphaComponent(0.3)
                textField.accessibilityValue = "\(letter), \(status.accessibilityDescription)"
            } else {
                textField.accessibilityValue = letter
            }
        }

        if state.isGameWon {
            dismissKeyboard()
        }

        refreshTheme()
    }

    private func updateHistory() {
        historyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        previousGuessesLabel.isHidden = state.guessHistory.isEmpty

        for (index, result) in state.guessHistory.enumerated().reversed() {
            let row = createHistoryRow(attempt: index + 1, result: result)
            historyStackView.addArrangedSubview(row)
        }
    }

    private func createHistoryRow(attempt: Int, result: GuessResult) -> UIView {
        let isLandscape = isLandscapeLayout == true
        let letterSize: CGFloat = isLandscape ? 32 : 40
        let fontSize: CGFloat = isLandscape ? 14 : 18

        let numberLabel = UILabel()
        numberLabel.text = "#\(attempt)"
        numberLabel.font = .preferredFont(forTextStyle: .caption1)
        numberLabel.textColor = .secondaryLabel
        numberLabel.adjustsFontForContentSizeCategory = true
        numberLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true

        let letterStack = UIStackView()
        letterStack.axis = .horizontal
        letterStack.spacing = isLandscape ? 6 : 8

        for letter in result.letters {
            let label = UILabel()
            label.text = String(letter.character)
            label.font = .monospacedSystemFont(ofSize: fontSize, weight: .bold)
            label.textAlignment = .center
            label.backgroundColor = AppColors.uiColor(for: letter.status).withAlphaComponent(0.3)
            label.layer.cornerRadius = 8
            label.layer.borderWidth = 1
            label.layer.borderColor = AppColors.uiColor(for: letter.status).cgColor
            label.clipsToBounds = true
            label.widthAnchor.constraint(equalToConstant: letterSize).isActive = true
            label.heightAnchor.constraint(equalToConstant: letterSize).isActive = true
            letterStack.addArrangedSubview(label)
        }

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [numberLabel, letterStack, spacer])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        row.isAccessibilityElement = true
        row.accessibilityLabel = "Attempt \(attempt): \(result.letters.map(\.accessibilityDescription).joined(separator: ", "))"
        return row
    }
}

// MARK: - UITextFieldDelegate

extension UIKitGameViewController: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        if string.isEmpty {
            textField.text = ""
            textFieldDidChange(textField)
            return false
        }

        guard let replacement = string.uppercased().last(where: \.isLetter) else {
            return false
        }

        textField.text = String(replacement)
        textFieldDidChange(textField)
        return false
    }
}
