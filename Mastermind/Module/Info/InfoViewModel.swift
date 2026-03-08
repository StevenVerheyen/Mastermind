import Foundation

struct InfoBulletContent: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
}

struct InfoColorPreviewContent: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let colorDescription: String
}

final class InfoContentViewModel {
    let architectureParagraphs = [
        "This app uses a tab-based module architecture with a SwiftUI app shell and one factory-backed module per tab item.",
        "Each tab owns its own module factory, view factory, and view model. The game tabs also assemble a shared game presenter and interactor behind those module-specific entry points."
    ]

    let featureComponents = [
        InfoBulletContent(
            title: "Entity",
            description: "GameEntity.swift defines the data models: GuessResult, LetterResult, LetterStatus, and GameState. These are plain value types with no dependencies. LetterResult includes an accessibilityDescription property that produces VoiceOver-friendly text for each evaluated letter."
        ),
        InfoBulletContent(
            title: "Interactor",
            description: "GameInteractor is the source of truth for the current session. It owns the secret, win state, and history, and reports authoritative GameState updates back to the presenter."
        ),
        InfoBulletContent(
            title: "Presenter",
            description: "GamePresenter contains the shared game presentation logic. It validates guesses, reacts to interactor callbacks, and mutates the active module's GameFeatureState."
        ),
        InfoBulletContent(
            title: "View Model",
            description: "Each game tab exposes a dedicated parent-facing view model with openFeature(). That entry point hides the feature assembly details while each module keeps its own presenter, state, and session lifecycle."
        ),
        InfoBulletContent(
            title: "View",
            description: "SwiftUIGameView, UIKitGameViewController, and InfoView are built through module-specific view factories. The game views bind directly to GameFeatureState and send user intents to GamePresenter."
        )
    ]

    let dualUIFrameworkParagraphs = [
        "The app demonstrates the same game implemented in both SwiftUI and UIKit, each in its own tab. Both tabs share the same rules and presenter logic, but each module factory creates an independent game session.",
        "The SwiftUI view uses Observation-driven state updates and FocusState to auto-advance between fields. The UIKit view uses UITextField delegates, UIStackView-based layout, Auto Layout constraints, and adjustsFontForContentSizeCategory for Dynamic Type support.",
        "The UIKit view controller is embedded in the SwiftUI tab bar via UIViewControllerRepresentable (UIKitGameViewWrapper), which bridges UIKit into SwiftUI and forwards runtime theme updates into the controller."
    ]

    let testabilityParagraphs = [
        "The game module is testable in isolation because the engine is injected into the interactor, the presenter mutates a dedicated GameFeatureState, and each tab module wires its own parent-facing view model through factories.",
        "Quick and Nimble are used to test the engine, interactor, presenter, and view model logic with focused behavior specs and test doubles.",
        "InfoModuleSpec verifies that the Info module factory shares one InfoContentViewModel with its view factory and that the parent-facing InfoViewModel opens the expected feature view.",
        "LetterResultAccessibilitySpec checks the spoken accessibility descriptions used for evaluated letters and guess history.",
        "GameSnapshotSpec uses Swift Testing with SnapshotTesting and AccessibilitySnapshot to verify hosted SwiftUI and UIKit screens on an iPhone 17-sized canvas, including their accessibility overlay."
    ]

    let themingParagraphs = [
        "The app supports light and dark mode via ThemeManager (@Observable). The theme manager is owned at the app level and passed into the tab shell so the color scheme stays shared across all tabs.",
        "For the UIKit tab, the UIKit module factory injects ThemeManager into the wrapper and controller so UIKit refreshes interface style and adaptive accent colors together."
    ]

    let themeColorPreviews = [
        InfoColorPreviewContent(title: "Primary tint:", colorDescription: "#00ABEF"),
        InfoColorPreviewContent(title: "Secondary tint:", colorDescription: "#003768")
    ]

    let themeColorNote = "To ensure readability, labels and buttons that use the secondary color in light mode automatically switch to the primary color in dark mode via AppColors.adaptiveAccent(for:)."

    let accessibilityBullets = [
        InfoBulletContent(
            title: "VoiceOver Support",
            description: "Every interactive element has an accessibilityLabel, accessibilityHint, and where applicable an accessibilityValue. Input fields announce their position (\"Letter 1\"), current content, and evaluation status (\"A, correct position\"). History rows are grouped into single accessible elements with full spoken descriptions."
        ),
        InfoBulletContent(
            title: "Semantic Structure",
            description: "Section headers use .isHeader accessibility traits, enabling VoiceOver rotor navigation. Decorative elements like bullet dots are hidden from assistive technology with accessibilityHidden. The Info tab's bullet points use accessibilityElement(children: .combine) so title and description are read together."
        ),
        InfoBulletContent(
            title: "Touch Targets",
            description: "All interactive elements meet the minimum 44×44pt touch target requirement per WCAG 2.5.8. Input boxes use frame(minWidth: 44, minHeight: 44) in SwiftUI and heightAnchor.constraint(greaterThanOrEqualToConstant: 44) in UIKit."
        ),
        InfoBulletContent(
            title: "Dynamic Type",
            description: "UIKit labels and buttons use preferredFont(forTextStyle:) and set adjustsFontForContentSizeCategory = true, ensuring text scales with the user's preferred content size. SwiftUI text uses semantic font styles that scale automatically."
        ),
        InfoBulletContent(
            title: "Accessibility Identifiers",
            description: "All interactive elements carry accessibilityIdentifier values (for example input_0, checkButton, newGameButton, and gameMessage) for automation and accessibility regression tests."
        )
    ]

    let colorContrastDescription = "Status colors are applied as backgrounds with 0.3 opacity plus bold foreground text, maintaining sufficient contrast ratios. The adaptive accent color ensures brand-colored headings remain readable in both light and dark mode."
}

final class InfoViewModel {
    private let viewFactory: InfoViewFactory

    init(viewFactory: InfoViewFactory) {
        self.viewFactory = viewFactory
    }

    func openFeature() -> InfoView {
        viewFactory.makeView()
    }
}
