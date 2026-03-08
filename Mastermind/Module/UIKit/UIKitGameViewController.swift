import Observation
import UIKit

final class UIKitGameViewController: UIViewController {

    private enum LayoutMetrics {
        static let contentInset = UIEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
        static let regularMaxContentWidth: CGFloat = 420
        static let compactMaxContentWidth: CGFloat = 900
        static let regularRootSpacing: CGFloat = 24
        static let compactRootSpacing: CGFloat = 16
        static let regularPanelSpacing: CGFloat = 16
        static let compactPanelSpacing: CGFloat = 8
        static let regularAttemptsSpacing: CGFloat = 32
        static let compactAttemptsSpacing: CGFloat = 16
        static let regularInputSpacing: CGFloat = 24
        static let compactInputSpacing: CGFloat = 12
        static let regularTitleSize: CGFloat = 34
        static let compactTitleSize: CGFloat = 24
        static let regularTextFieldFontSize: CGFloat = 32
        static let compactTextFieldFontSize: CGFloat = 22
        static let regularTextFieldHeight: CGFloat = 64
        static let compactTextFieldHeight: CGFloat = 48
        static let regularHistoryLetterSize: CGFloat = 40
        static let compactHistoryLetterSize: CGFloat = 32
        static let regularHistoryFontSize: CGFloat = 18
        static let compactHistoryFontSize: CGFloat = 14
        static let regularHistorySpacing: CGFloat = 8
        static let compactHistorySpacing: CGFloat = 6
        static let regularButtonHeight: CGFloat = 50
        static let compactButtonHeight: CGFloat = 40
    }

    private enum LayoutStyle {
        case regular
        case compact
    }

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
    private var scrollContentView = UIView()
    private var textFieldHeightConstraints: [NSLayoutConstraint] = []
    private var checkButtonHeightConstraint: NSLayoutConstraint?
    private var newGameButtonHeightConstraint: NSLayoutConstraint?
    private var rootStackWidthConstraint: NSLayoutConstraint?
    private var currentLayoutStyle: LayoutStyle?

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
        updateLayout()
    }

    private var layoutStyle: LayoutStyle {
        let isCompactPhoneLandscape = traitCollection.userInterfaceIdiom == .phone
            && view.bounds.width > view.bounds.height
        return isCompactPhoneLandscape ? .compact : .regular
    }

    private func updateLayout() {
        updateCenteredContentWidth()

        let style = layoutStyle
        guard style != currentLayoutStyle else { return }
        currentLayoutStyle = style

        rootStack.axis = style == .compact ? .horizontal : .vertical
        rootStack.distribution = style == .compact ? .fillEqually : .fill
        rootStack.alignment = style == .compact ? .top : .fill
        rootStack.spacing = style == .compact
            ? LayoutMetrics.compactRootSpacing
            : LayoutMetrics.regularRootSpacing

        inputPanelStack.spacing = style == .compact
            ? LayoutMetrics.compactPanelSpacing
            : LayoutMetrics.regularPanelSpacing
        inputPanelStack.setCustomSpacing(
            style == .compact ? LayoutMetrics.compactAttemptsSpacing : LayoutMetrics.regularAttemptsSpacing,
            after: attemptsLabel
        )
        inputPanelStack.setCustomSpacing(
            style == .compact ? LayoutMetrics.compactInputSpacing : LayoutMetrics.regularInputSpacing,
            after: inputStack
        )

        titleLabel.font = .systemFont(
            ofSize: style == .compact ? LayoutMetrics.compactTitleSize : LayoutMetrics.regularTitleSize,
            weight: .bold
        )

        let textFieldFontSize = style == .compact
            ? LayoutMetrics.compactTextFieldFontSize
            : LayoutMetrics.regularTextFieldFontSize
        textFields.forEach { $0.font = .monospacedSystemFont(ofSize: textFieldFontSize, weight: .bold) }
        textFieldHeightConstraints.forEach {
            $0.constant = style == .compact
                ? LayoutMetrics.compactTextFieldHeight
                : LayoutMetrics.regularTextFieldHeight
        }

        let buttonHeight = style == .compact
            ? LayoutMetrics.compactButtonHeight
            : LayoutMetrics.regularButtonHeight
        checkButtonHeightConstraint?.constant = buttonHeight
        newGameButtonHeightConstraint?.constant = buttonHeight

        updateHistory()
    }

    private func updateCenteredContentWidth() {
        let availableWidth = max(
            view.bounds.width - LayoutMetrics.contentInset.left - LayoutMetrics.contentInset.right,
            0
        )
        let maxContentWidth = layoutStyle == .compact
            ? LayoutMetrics.compactMaxContentWidth
            : LayoutMetrics.regularMaxContentWidth
        rootStackWidthConstraint?.constant = min(availableWidth, maxContentWidth)
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
        rootStack.axis = .vertical
        rootStack.spacing = LayoutMetrics.regularRootSpacing

        checkButtonHeightConstraint = checkButton.heightAnchor.constraint(equalToConstant: LayoutMetrics.regularButtonHeight)
        newGameButtonHeightConstraint = newGameButton.heightAnchor.constraint(equalToConstant: LayoutMetrics.regularButtonHeight)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(scrollContentView)

        rootStack.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.addSubview(rootStack)

        rootStackWidthConstraint = rootStack.widthAnchor.constraint(equalToConstant: 0)

        var constraints: [NSLayoutConstraint] = [
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollContentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            scrollContentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),

            rootStack.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: LayoutMetrics.contentInset.top),
            rootStack.leadingAnchor.constraint(
                greaterThanOrEqualTo: scrollContentView.leadingAnchor,
                constant: LayoutMetrics.contentInset.left
            ),
            rootStack.trailingAnchor.constraint(
                lessThanOrEqualTo: scrollContentView.trailingAnchor,
                constant: -LayoutMetrics.contentInset.right
            ),
            rootStack.bottomAnchor.constraint(
                lessThanOrEqualTo: scrollContentView.bottomAnchor,
                constant: -LayoutMetrics.contentInset.bottom
            ),
            rootStack.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
        ]
        constraints += [rootStackWidthConstraint].compactMap { $0 }
        constraints += [checkButtonHeightConstraint, newGameButtonHeightConstraint].compactMap { $0 }
        NSLayoutConstraint.activate(constraints)

        for textField in textFields {
            textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            let heightConstraint = textField.heightAnchor.constraint(equalToConstant: 64)
            heightConstraint.isActive = true
            textFieldHeightConstraints.append(heightConstraint)
        }

        updateLayout()
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
        let isCompactStyle = currentLayoutStyle == .compact
        let letterSize: CGFloat = isCompactStyle
            ? LayoutMetrics.compactHistoryLetterSize
            : LayoutMetrics.regularHistoryLetterSize
        let fontSize: CGFloat = isCompactStyle
            ? LayoutMetrics.compactHistoryFontSize
            : LayoutMetrics.regularHistoryFontSize

        let numberLabel = UILabel()
        numberLabel.text = "#\(attempt)"
        numberLabel.font = .preferredFont(forTextStyle: .caption1)
        numberLabel.textColor = .secondaryLabel
        numberLabel.adjustsFontForContentSizeCategory = true
        numberLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true

        let letterStack = UIStackView()
        letterStack.axis = .horizontal
        letterStack.spacing = isCompactStyle
            ? LayoutMetrics.compactHistorySpacing
            : LayoutMetrics.regularHistorySpacing

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
