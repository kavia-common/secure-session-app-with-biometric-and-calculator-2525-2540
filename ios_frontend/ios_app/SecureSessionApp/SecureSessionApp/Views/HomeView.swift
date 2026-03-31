import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var appLock: AppLockManager

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text("Home")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AndroidRefTheme.textPrimary)

                Spacer()

                Button("Logout") {
                    Task {
                        await session.logout()
                        appLock.unlockWithoutPrompt()
                    }
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AndroidRefTheme.primary)
            }
            .padding(.horizontal, AndroidRefTheme.outerHPadding)
            .padding(.top, 12)
            .padding(.bottom, 6)
            .background(AndroidRefTheme.canvas)

            CalculatorView()
        }
        .background(AndroidRefTheme.canvas)
        .navigationBarHidden(true)
    }
}
