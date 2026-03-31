import SwiftUI

/// Shared design tokens + small view helpers to match the provided Android reference screenshots.
enum AndroidRefTheme {
    // Canvas / surfaces
    static let canvas = Color(red: 0.965, green: 0.969, blue: 0.984) // ~ #F6F7FB
    static let surface = Color.white
    static let inputFill = Color(red: 0.953, green: 0.957, blue: 0.965) // ~ #F3F4F6
    static let chipFill = Color(red: 0.933, green: 0.949, blue: 0.969) // ~ #EEF2F7
    static let border = Color(red: 0.898, green: 0.906, blue: 0.922) // ~ #E5E7EB

    // Text
    static let textPrimary = Color(red: 0.122, green: 0.122, blue: 0.122) // ~ #1F1F1F
    static let textSecondary = Color(red: 0.420, green: 0.447, blue: 0.502) // ~ #6B7280

    // Primary
    static let primary = Color(red: 0.184, green: 0.435, blue: 0.929) // ~ #2F6FED
    static let onPrimary = Color.white

    // Layout constants
    static let outerHPadding: CGFloat = 16
    static let cardPadding: CGFloat = 12
    static let cardCornerRadius: CGFloat = 8
    static let inputCornerRadius: CGFloat = 6
    static let buttonCornerRadius: CGFloat = 8
}

/// A simple card container matching the Android screenshot: white surface + 1pt border + 8pt radius.
struct AndroidRefCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(AndroidRefTheme.cardPadding)
            .background(AndroidRefTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: AndroidRefTheme.cardCornerRadius)
                    .stroke(AndroidRefTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AndroidRefTheme.cardCornerRadius))
    }
}

struct AndroidRefTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(AndroidRefTheme.inputFill)
            .overlay(
                RoundedRectangle(cornerRadius: AndroidRefTheme.inputCornerRadius)
                    .stroke(AndroidRefTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AndroidRefTheme.inputCornerRadius))
    }
}

/// Filled primary button (blue) with the height/radius from the reference.
struct AndroidRefPrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(AndroidRefTheme.onPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(AndroidRefTheme.primary.opacity(isDisabled ? 0.55 : (configuration.isPressed ? 0.82 : 1.0)))
            .clipShape(RoundedRectangle(cornerRadius: AndroidRefTheme.buttonCornerRadius))
    }
}

/// Small “chip” buttons (light gray fill + border) used on Login “Session actions” row.
struct AndroidRefChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(AndroidRefTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 34)
            .background(AndroidRefTheme.chipFill.opacity(configuration.isPressed ? 0.85 : 1.0))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AndroidRefTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

extension View {
    func androidRefScreenPadding() -> some View {
        padding(.horizontal, AndroidRefTheme.outerHPadding)
    }
}
