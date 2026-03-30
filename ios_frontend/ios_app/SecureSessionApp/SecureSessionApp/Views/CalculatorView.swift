import SwiftUI

struct CalculatorView: View {
    @StateObject private var model = CalculatorViewModel()

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .trailing, spacing: 8) {
                Text(model.secondaryDisplay)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text(model.primaryDisplay)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(model.buttons, id: \.self) { button in
                    Button {
                        model.tap(button)
                    } label: {
                        Text(button.label)
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, minHeight: 54)
                            .background(button.background)
                            .foregroundStyle(button.foreground)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .accessibilityLabel(button.accessibilityLabel)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

final class CalculatorViewModel: ObservableObject {
    enum Op: String {
        case add = "+"
        case subtract = "−"
        case multiply = "×"
        case divide = "÷"
    }

    struct CalcButton: Hashable {
        let label: String
        let kind: Kind

        enum Kind: Hashable {
            case digit(Int)
            case decimal
            case op(Op)
            case equals
            case clear
            case plusMinus
            case percent
        }

        var accessibilityLabel: String {
            switch kind {
            case .digit(let d): return "Digit \(d)"
            case .decimal: return "Decimal"
            case .op(let op): return "Operator \(op.rawValue)"
            case .equals: return "Equals"
            case .clear: return "Clear"
            case .plusMinus: return "Plus minus"
            case .percent: return "Percent"
            }
        }

        var background: Color {
            switch kind {
            case .op, .equals:
                return .blue.opacity(0.9)
            case .clear, .plusMinus, .percent:
                return .gray.opacity(0.25)
            default:
                return .white
            }
        }

        var foreground: Color {
            switch kind {
            case .op, .equals:
                return .white
            default:
                return .primary
            }
        }
    }

    @Published private(set) var primaryDisplay: String = "0"
    @Published private(set) var secondaryDisplay: String = ""

    private var storedValue: Double?
    private var pendingOp: Op?
    private var isEnteringNewNumber: Bool = true

    let buttons: [CalcButton] = [
        .init(label: "C", kind: .clear),
        .init(label: "±", kind: .plusMinus),
        .init(label: "%", kind: .percent),
        .init(label: "÷", kind: .op(.divide)),

        .init(label: "7", kind: .digit(7)),
        .init(label: "8", kind: .digit(8)),
        .init(label: "9", kind: .digit(9)),
        .init(label: "×", kind: .op(.multiply)),

        .init(label: "4", kind: .digit(4)),
        .init(label: "5", kind: .digit(5)),
        .init(label: "6", kind: .digit(6)),
        .init(label: "−", kind: .op(.subtract)),

        .init(label: "1", kind: .digit(1)),
        .init(label: "2", kind: .digit(2)),
        .init(label: "3", kind: .digit(3)),
        .init(label: "+", kind: .op(.add)),

        .init(label: "0", kind: .digit(0)),
        .init(label: ".", kind: .decimal),
        .init(label: "=", kind: .equals),
        .init(label: "", kind: .equals) // filler to keep grid aligned
    ].filter { $0.label != "" }

    func tap(_ button: CalcButton) {
        switch button.kind {
        case .digit(let d):
            inputDigit(d)
        case .decimal:
            inputDecimal()
        case .clear:
            clear()
        case .plusMinus:
            toggleSign()
        case .percent:
            percent()
        case .op(let op):
            setOperation(op)
        case .equals:
            evaluate()
        }
    }

    private func inputDigit(_ digit: Int) {
        if isEnteringNewNumber {
            primaryDisplay = "\(digit)"
            isEnteringNewNumber = false
        } else {
            if primaryDisplay == "0" {
                primaryDisplay = "\(digit)"
            } else {
                primaryDisplay.append("\(digit)")
            }
        }
    }

    private func inputDecimal() {
        if isEnteringNewNumber {
            primaryDisplay = "0."
            isEnteringNewNumber = false
            return
        }
        guard !primaryDisplay.contains(".") else { return }
        primaryDisplay.append(".")
    }

    private func clear() {
        primaryDisplay = "0"
        secondaryDisplay = ""
        storedValue = nil
        pendingOp = nil
        isEnteringNewNumber = true
    }

    private func toggleSign() {
        guard let value = Double(primaryDisplay) else { return }
        primaryDisplay = formatNumber(-value)
    }

    private func percent() {
        guard let value = Double(primaryDisplay) else { return }
        primaryDisplay = formatNumber(value / 100.0)
    }

    private func setOperation(_ op: Op) {
        if let pendingOp {
            // If there was an op pending and user presses another op, evaluate first.
            if !isEnteringNewNumber {
                evaluate()
            }
            self.pendingOp = op
        } else {
            storedValue = Double(primaryDisplay)
            pendingOp = op
            isEnteringNewNumber = true
        }
        updateSecondary()
    }

    private func evaluate() {
        guard let op = pendingOp else { return }
        guard let left = storedValue else { return }
        guard let right = Double(primaryDisplay) else { return }

        let result: Double
        switch op {
        case .add:
            result = left + right
        case .subtract:
            result = left - right
        case .multiply:
            result = left * right
        case .divide:
            result = right == 0 ? Double.nan : left / right
        }

        primaryDisplay = result.isNaN ? "Error" : formatNumber(result)
        secondaryDisplay = ""
        storedValue = nil
        pendingOp = nil
        isEnteringNewNumber = true
    }

    private func updateSecondary() {
        guard let storedValue, let pendingOp else {
            secondaryDisplay = ""
            return
        }
        secondaryDisplay = "\(formatNumber(storedValue)) \(pendingOp.rawValue)"
    }

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 10
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
