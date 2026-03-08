import SwiftUI

struct InfoView: View {
    let viewModel: InfoContentViewModel

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                architecture
                viper
                frameworks
                theming
                testability
                accessibility
            }
            .padding()
        }
    }

    private var accentColor: Color {
        AppColors.adaptiveAccent(for: colorScheme)
    }

    private var architecture: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Architecture Overview")

            ForEach(viewModel.architectureParagraphs, id: \.self) { paragraph in
                Text(paragraph)
            }
        }
    }

    private var viper: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Feature Components")

            ForEach(viewModel.featureComponents) { bullet in
                bulletPoint(title: bullet.title, description: bullet.description)
            }
        }
    }

    private var frameworks: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Dual UI Frameworks")

            ForEach(viewModel.dualUIFrameworkParagraphs, id: \.self) { paragraph in
                Text(paragraph)
            }
        }
    }

    private var testability: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Testability")

            ForEach(viewModel.testabilityParagraphs, id: \.self) { paragraph in
                Text(paragraph)
            }
        }
    }

    private var theming: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Theming & Adaptive Colors")

            ForEach(viewModel.themingParagraphs, id: \.self) { paragraph in
                Text(paragraph)
            }

            themingColorsDescription
        }
    }

    private var accessibility: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("EAA & A11Y Compliance")

            Text("The app follows the European Accessibility Act (EAA) requirements and WCAG accessibility guidelines across both UI frameworks:")

            ForEach(viewModel.accessibilityBullets.prefix(4)) { bullet in
                bulletPoint(title: bullet.title, description: bullet.description)
            }

            colorContrastDescription

            if let identifiersBullet = viewModel.accessibilityBullets.last {
                bulletPoint(
                    title: identifiersBullet.title,
                    description: identifiersBullet.description
                )
            }
        }
    }

    private var themingColorsDescription: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The brand colors are defined centrally in AppColors:")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text("• \(viewModel.themeColorPreviews[0].title)")
                        .foregroundStyle(.secondary)
                    colorPreviewText(
                        color: AppColors.primary,
                        description: viewModel.themeColorPreviews[0].colorDescription
                    )
                }

                HStack(spacing: 6) {
                    Text("• \(viewModel.themeColorPreviews[1].title)")
                        .foregroundStyle(.secondary)
                    colorPreviewText(
                        color: AppColors.secondary,
                        description: viewModel.themeColorPreviews[1].colorDescription
                    )
                }
            }

            Text(viewModel.themeColorNote)
                .foregroundStyle(.secondary)
        }
    }

    private var colorContrastDescription: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(AppColors.primary)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text("Color Contrast")
                    .fontWeight(.semibold)
                HStack(spacing: 4) {
                    Text("Status colors (")
                        .foregroundStyle(.secondary)
                    colorPreviewText(color: .green, description: "green,")
                    colorPreviewText(color: .orange, description: "orange,")
                    colorPreviewText(color: .red, description: "red)")
                }
                Text(viewModel.colorContrastDescription)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func colorPreviewText(
        color: Color,
        description: String
    ) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 14, height: 14)
                .accessibilityHidden(true)

            Text(description)
                .fontWeight(.medium)
        }
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(description)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(accentColor)
            .accessibilityAddTraits(.isHeader)
    }

    private func bulletPoint(
        title: String,
        description: String
    ) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(AppColors.primary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
