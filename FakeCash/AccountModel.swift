import SwiftUI
import Combine

struct FakeNotification: Identifiable, Codable {
    var id = UUID()
    var title: String
    var subtitle: String
    var amount: String
    var time: String
    var emoji: String
}

class AccountModel: ObservableObject {
    @Published var balance: Double = 24.85
    @Published var savingsBalance: Double = 14500.00
    @Published var bitcoinBalance: Double = 12552.47
    @Published var bitcoinChange: Double = -0.24

    @Published var cardLastFour: String = "2367"
    @Published var accountLastFour: String = "9890"
    @Published var cashtag: String = "$1xorfee"
    @Published var cardholderName: String = "Elliot Payne"
    @Published var cardStyle: CardStyle = .black

    @Published var profileEmoji: String = "🌍"
    @Published var profileLetter: String = ""
    @Published var profileColor: String = "444444"
    @Published var useEmojiProfile: Bool = true

    @Published var greenStatusText: String = "In progress"

    @Published var isDarkMode: Bool = true
    // Gradient top color (hex) — user can change in editor
    @Published var gradientTopColor: String = "0a0a0a"
    @Published var gradientBottomColor: String = "282828"

    @Published var notificationCount: Int = 1
    @Published var notifications: [FakeNotification] = [
        FakeNotification(title: "Cash received", subtitle: "From $johndoe", amount: "+$50.00", time: "2m ago", emoji: "💸"),
        FakeNotification(title: "Payment sent", subtitle: "To $janedoe", amount: "-$25.00", time: "1h ago", emoji: "✅"),
        FakeNotification(title: "Direct deposit", subtitle: "Payroll", amount: "+$1,200.00", time: "Yesterday", emoji: "🏦"),
    ]

    var balanceDisplay: String { formatCurrency(balance) }
    var savingsDisplay: String { formatCurrency(savingsBalance) }
    var bitcoinDisplay: String { formatCurrency(bitcoinBalance) }
    var balanceRounded: String {
        if balance >= 1000 { return "$\(Int(balance / 1000))K" }
        return "$\(Int(balance))"
    }

    private func formatCurrency(_ v: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency; f.currencySymbol = "$"
        f.minimumFractionDigits = 2; f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: v)) ?? "$0.00"
    }
}

enum CardStyle: String, CaseIterable, Identifiable {
    case black = "Black"
    case gold = "Gold"
    case silver = "Silver"
    case midnight = "Midnight"
    var id: String { rawValue }

    var gradient: [Color] {
        switch self {
        case .black:    return [Color(hex: "1a1a1a"), Color(hex: "0d0d0d")]
        case .gold:     return [Color(hex: "c8a96e"), Color(hex: "f5e6c8"), Color(hex: "b8940e")]
        case .silver:   return [Color(hex: "9e9e9e"), Color(hex: "e0e0e0"), Color(hex: "757575")]
        case .midnight: return [Color(hex: "0d1b2a"), Color(hex: "1b2838"), Color(hex: "0a1628")]
        }
    }

    var textColor: Color {
        switch self {
        case .gold, .silver: return Color.black.opacity(0.75)
        default: return .white
        }
    }
}
