import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var appLock: AppLockManager

    var body: some View {
        CalculatorView()
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout") {
                        Task {
                            await session.logout()
                            appLock.unlockWithoutPrompt()
                        }
                    }
                }
            }
    }
}
