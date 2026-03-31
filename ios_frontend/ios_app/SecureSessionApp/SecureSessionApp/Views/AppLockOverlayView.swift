import SwiftUI

struct AppLockOverlayView: View {
    let title: String
    let message: String
    let unlockAction: () -> Void

    var body: some View {
        ZStack {
            // Dimmed scrim behind the card (matches typical Android "modal overlay" feel).
            AndroidRefTheme.textPrimary
                .opacity(0.20)
                .ignoresSafeArea()

            // Centered "card" using the same card container as Login/Home.
            AndroidRefCard {
                VStack(alignment: .center, spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(AndroidRefTheme.primary)
                        .padding(.top, 2)

                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AndroidRefTheme.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(AndroidRefTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 2)

                    Button(action: unlockAction) {
                        Text("Unlock")
                    }
                    .buttonStyle(AndroidRefPrimaryButtonStyle())
                    .padding(.top, 6)
                    .accessibilityLabel("Unlock app")
                }
            }
            .frame(maxWidth: 360)
            .padding(.horizontal, AndroidRefTheme.outerHPadding)
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}
