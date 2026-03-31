import SwiftUI

struct CalculatorView: View {
    @StateObject private var model = CalculatorCardViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Signed-in status card
                AndroidRefCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("You are signed in.")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AndroidRefTheme.textPrimary)

                        Text("Your session is active. Use the calculator below.")
                            .font(.system(size: 12))
                            .foregroundStyle(AndroidRefTheme.textSecondary)
                    }
                }
                .padding(.top, 6)

                Text("Calculator")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AndroidRefTheme.textPrimary)
                    .padding(.top, 6)

                // Calculator card
                AndroidRefCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Enter a number")
                            .font(.system(size: 12))
                            .foregroundStyle(AndroidRefTheme.textSecondary)

                        TextField("", text: $model.input)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(AndroidRefTextFieldStyle())

                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                Button("Add") { model.add() }
                                    .buttonStyle(AndroidRefPrimaryButtonStyle())
                                Button("Subtract") { model.subtract() }
                                    .buttonStyle(AndroidRefPrimaryButtonStyle())
                            }

                            HStack(spacing: 10) {
                                Button("Multiply") { model.multiply() }
                                    .buttonStyle(AndroidRefPrimaryButtonStyle())
                                Button("Divide") { model.divide() }
                                    .buttonStyle(AndroidRefPrimaryButtonStyle())
                            }
                        }
                        .padding(.top, 2)

                        HStack {
                            Spacer()
                            Button("Clear") { model.clear() }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AndroidRefTheme.textSecondary)
                                .padding(.top, 2)
                            Spacer()
                        }
                    }
                }

                Text("Result: \(model.resultText)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(AndroidRefTheme.textSecondary)
                    .padding(.top, 6)

                Spacer(minLength: 12)
            }
            .androidRefScreenPadding()
            .padding(.top, 2)
        }
        .background(AndroidRefTheme.canvas)
    }
}

@MainActor
final class CalculatorCardViewModel: ObservableObject {
    @Published var input: String = "2"
    @Published private(set) var result: Double = 0

    var resultText: String {
        if result.isNaN || result.isInfinite { return "Error" }
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 10
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: result)) ?? "\(result)"
    }

    func add() {
        guard let value = parseInput() else { return }
        result = result + value
    }

    func subtract() {
        guard let value = parseInput() else { return }
        result = result - value
    }

    func multiply() {
        guard let value = parseInput() else { return }
        result = result * value
    }

    func divide() {
        guard let value = parseInput() else { return }
        result = value == 0 ? Double.nan : (result / value)
    }

    func clear() {
        input = ""
        result = 0
    }

    private func parseInput() -> Double? {
        // Accept both comma and dot decimal separators for robustness.
        let normalized = input.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
}
