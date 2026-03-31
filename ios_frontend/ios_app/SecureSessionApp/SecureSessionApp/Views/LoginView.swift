import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var appLock: AppLockManager

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false

    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Title block (top-left)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Sample Declarative Gradle Android App")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AndroidRefTheme.textPrimary)

                    Text("This app is for demonstrating declarative gradle ...")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(AndroidRefTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 12)

                // Auth state label line
                Text("Auth state: LoggedOut")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AndroidRefTheme.textSecondary)
                    .padding(.top, 2)

                // Login card
                AndroidRefCard {
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Login")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(AndroidRefTheme.textPrimary)
                            Text("(mocked: any username/password)")
                                .font(.system(size: 12))
                                .foregroundStyle(AndroidRefTheme.textSecondary)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Username (any)")
                                .font(.system(size: 12))
                                .foregroundStyle(AndroidRefTheme.textSecondary)

                            TextField("", text: $email)
                                .textContentType(.username)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textFieldStyle(AndroidRefTextFieldStyle())
                        }
                        .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password (mock)")
                                .font(.system(size: 12))
                                .foregroundStyle(AndroidRefTheme.textSecondary)

                            ZStack(alignment: .trailing) {
                                Group {
                                    if isPasswordVisible {
                                        TextField("", text: $password)
                                            .textContentType(.password)
                                            .textInputAutocapitalization(.never)
                                            .autocorrectionDisabled()
                                    } else {
                                        SecureField("", text: $password)
                                            .textContentType(.password)
                                    }
                                }
                                .textFieldStyle(AndroidRefTextFieldStyle())
                                .padding(.trailing, 34) // space for eye icon overlay

                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(AndroidRefTheme.textSecondary)
                                        .frame(width: 34, height: 44)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
                            }
                        }
                        .padding(.top, 2)

                        Text("Logged out. Use any username/password.")
                            .font(.system(size: 12))
                            .foregroundStyle(AndroidRefTheme.textSecondary)
                            .padding(.top, 2)

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 12))
                                .foregroundStyle(.red)
                                .padding(.top, 2)
                        }

                        Button {
                            Task { await submit() }
                        } label: {
                            if isSubmitting {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                    Text("Login")
                                }
                            } else {
                                Text("Login")
                            }
                        }
                        .buttonStyle(AndroidRefPrimaryButtonStyle(isDisabled: isLoginDisabled))
                        .disabled(isLoginDisabled)
                        .padding(.top, 2)
                    }
                }
                .padding(.top, 2)

                // Session actions section
                Text("Session actions")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AndroidRefTheme.textPrimary)
                    .padding(.top, 8)

                HStack(spacing: 8) {
                    Button("Lock") {
                        // For demo parity with Android reference "session actions"
                        if session.isAuthenticated {
                            appLock.lock()
                        }
                    }
                    .buttonStyle(AndroidRefChipButtonStyle())
                    .disabled(!session.isAuthenticated)

                    Button("Unlock") {
                        if session.isAuthenticated {
                            Task { await appLock.unlock() }
                        }
                    }
                    .buttonStyle(AndroidRefChipButtonStyle())
                    .disabled(!session.isAuthenticated)

                    Button("Clear") {
                        // Clear fields locally (matches "clear" utility behavior in reference)
                        email = ""
                        password = ""
                        errorMessage = nil
                    }
                    .buttonStyle(AndroidRefChipButtonStyle())
                }
                .padding(.top, 2)

                Button {
                    // Not implemented in this sample UI: keep button for layout parity.
                    // (The app still uses /me internally when needed; this is just a demo action.)
                } label: {
                    Text("Call protected endpoint")
                }
                .buttonStyle(AndroidRefPrimaryButtonStyle())
                .padding(.top, 6)

                Button {
                    // Another demo action for parity with the reference screenshot.
                } label: {
                    Text("Another protected action")
                }
                .buttonStyle(AndroidRefPrimaryButtonStyle())
                .padding(.top, 2)

                Spacer(minLength: 12)
            }
            .androidRefScreenPadding()
        }
        .background(AndroidRefTheme.canvas)
        .navigationBarHidden(true)
    }

    private var isLoginDisabled: Bool {
        isSubmitting || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty
    }

    private func submit() async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await session.login(email: email, password: password)
        } catch {
            errorMessage = (error as? AppError)?.localizedDescription ?? error.localizedDescription
        }
    }
}
