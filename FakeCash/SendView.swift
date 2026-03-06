import SwiftUI

struct SendView: View {
    @ObservedObject var account: AccountModel
    @Binding var isPresented: Bool

    @State private var amountString = ""
    @State private var phase: SendPhase = .numpad
    @State private var recipient = ""
    @State private var note = ""

    enum SendPhase: Equatable { case numpad, recipient, success }

    var displayAmount: String {
        if amountString.isEmpty { return "$0" }
        if amountString.hasSuffix(".") { return "$\(amountString)" }
        if let d = Double(amountString) {
            let formatted = d >= 1000
                ? String(format: "$%.0f", d)
                : (amountString.contains(".") ? "$\(amountString)" : "$\(amountString)")
            return formatted
        }
        return "$\(amountString)"
    }

    var body: some View {
        Group {
            switch phase {
            case .numpad:   numpadView
            case .recipient: recipientView
            case .success:  successView
            }
        }
        .animation(.easeInOut(duration: 0.2), value: phase)
    }

    // MARK: - Numpad (Screenshot 1 — Green bg)
    var numpadView: some View {
        ZStack {
            Color(hex: "00D632").ignoresSafeArea()

            VStack(spacing: 0) {
                // Top row: QR + search + avatar
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 14)
                    ZStack(alignment: .topTrailing) {
                        if account.useEmojiProfile {
                            Circle()
                                .fill(Color(hex: account.profileColor))
                                .frame(width: 36, height: 36)
                                .overlay(Text(account.profileEmoji).font(.system(size: 18)))
                        } else {
                            Circle()
                                .fill(Color(hex: "1a4a8a"))
                                .frame(width: 36, height: 36)
                                .overlay(Text(account.profileLetter.isEmpty ? "?" : String(account.profileLetter.prefix(1)))
                                    .font(.system(size:16,weight:.bold)).foregroundColor(.white))
                        }
                        if account.notificationCount > 0 {
                            Circle().fill(Color.red).frame(width:16,height:16)
                                .overlay(Text("\(min(account.notificationCount,9))")
                                    .font(.system(size:9,weight:.bold)).foregroundColor(.white))
                                .offset(x:4,y:-4)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)

                Spacer()

                // Amount display
                Text(displayAmount)
                    .font(.system(size: amountString.count > 6 ? 64 : 80, weight: .heavy))
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal, 30)

                Spacer()

                // Numpad
                VStack(spacing: 4) {
                    ForEach([[1,2,3],[4,5,6],[7,8,9]], id: \.first) { row in
                        HStack(spacing: 0) {
                            ForEach(row, id: \.self) { n in
                                numKey(label: "\(n)") { tapNum("\(n)") }
                            }
                        }
                    }
                    HStack(spacing: 0) {
                        numKey(label: "•") { tapNum(".") }
                        numKey(label: "0") { tapNum("0") }
                        numKey(icon: "chevron.left") { deleteLast() }
                    }
                }
                .padding(.horizontal, 8)

                // Pool / Request / Pay
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Text("Pool")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(Color(hex: "00D632").opacity(0.5))
                                .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.black.opacity(0.15), lineWidth: 1))
                                .cornerRadius(50)
                        }
                        Button(action: {}) {
                            Text("Request")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.black.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(Color(hex: "00D632").opacity(0.5))
                                .overlay(RoundedRectangle(cornerRadius: 50).stroke(Color.black.opacity(0.15), lineWidth: 1))
                                .cornerRadius(50)
                        }
                    }
                    Button(action: {
                        if !amountString.isEmpty && Double(amountString) ?? 0 > 0 {
                            phase = .recipient
                        }
                    }) {
                        Text("Pay")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.black)
                            .cornerRadius(50)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Bottom tab
                HStack {
                    Spacer()
                    Text(account.balanceRounded)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black.opacity(0.5))
                    Spacer()
                    Text("$")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "clock")
                            .font(.system(size: 22))
                            .foregroundColor(.black.opacity(0.5))
                        if account.notificationCount > 0 {
                            Circle().fill(Color.red).frame(width:14,height:14)
                                .overlay(Text("\(min(account.notificationCount,9))")
                                    .font(.system(size:8,weight:.bold)).foregroundColor(.white))
                                .offset(x:8,y:-8)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Recipient (Screenshot 2 — White bg)
    var recipientView: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Top nav
                HStack {
                    Button(action: { phase = .numpad }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("$\(amountString.isEmpty ? "0" : amountString)")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    Button(action: {
                        if !recipient.isEmpty { phase = .success }
                    }) {
                        Text("Pay")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 18).padding(.vertical, 8)
                            .background(recipient.isEmpty ? Color(UIColor.systemGray5) : Color(UIColor.systemGray5))
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 20).padding(.top, 56).padding(.bottom, 0)

                Divider().padding(.top, 12)

                // To field
                HStack(spacing: 12) {
                    Text("To")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 36, alignment: .leading)
                    TextField("Name, $Cashtag, Phone, Email", text: $recipient)
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 20).padding(.vertical, 16)

                Divider()

                // For / note field
                HStack(spacing: 12) {
                    Text("For")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 36, alignment: .leading)
                    TextField("Note (required)", text: $note)
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                    Spacer()
                    Circle()
                        .fill(Color(UIColor.systemGray5))
                        .frame(width: 36, height: 36)
                        .overlay(Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.primary))
                }
                .padding(.horizontal, 20).padding(.vertical, 16)

                Divider()

                // Use: Cash balance
                HStack(spacing: 12) {
                    Text("Use")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 36, alignment: .leading)
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "00D632"))
                            .frame(width: 26, height: 26)
                        Text("$")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.white)
                    }
                    Text("Cash balance: \(account.balanceDisplay)")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.secondaryLabel))
                }
                .padding(.horizontal, 20).padding(.vertical, 16)

                Divider()

                // Suggested contacts
                VStack(alignment: .leading, spacing: 0) {
                    Text("Suggested")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20).padding(.top, 22).padding(.bottom, 16)

                    ForEach(account.contacts) { contact in
                        Button(action: { recipient = contact.cashtag }) {
                            HStack(spacing: 14) {
                                Circle()
                                    .fill(Color(hex: contact.colorHex))
                                    .frame(width: 54, height: 54)
                                    .overlay(Text(contact.initial)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(contact.name)
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text(contact.cashtag)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                                Spacer()
                                Circle()
                                    .stroke(Color(UIColor.systemGray4), lineWidth: 1.5)
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        recipient == contact.cashtag
                                            ? Circle().fill(Color.black).frame(width: 14, height: 14)
                                            : nil
                                    )
                            }
                            .padding(.horizontal, 20).padding(.vertical, 10)
                        }
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Success
    var successView: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24).padding(.top, 56)

                Circle()
                    .fill(Color(hex: "00D632"))
                    .frame(width: 70, height: 70)
                    .overlay(Image(systemName: "checkmark")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.black))
                    .padding(.horizontal, 24).padding(.top, 24)

                Text("$\(amountString) sent\nto \(recipient)")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.primary)
                    .lineSpacing(4)
                    .padding(.horizontal, 24).padding(.top, 20)

                Spacer()

                Button(action: { isPresented = false }) {
                    Text("Done")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.black)
                        .cornerRadius(50)
                }
                .padding(.horizontal, 20).padding(.bottom, 48)
            }
        }
    }

    // MARK: - Numpad helpers
    func numKey(label: String? = nil, icon: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.black)
                } else {
                    Text(label ?? "")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 72)
        }
    }

    func tapNum(_ char: String) {
        if char == "." {
            if amountString.contains(".") { return }
            if amountString.isEmpty { amountString = "0" }
        }
        if amountString == "0" && char != "." { amountString = char; return }
        if amountString.count >= 8 { return }
        amountString += char
    }

    func deleteLast() {
        if !amountString.isEmpty { amountString.removeLast() }
    }
}
