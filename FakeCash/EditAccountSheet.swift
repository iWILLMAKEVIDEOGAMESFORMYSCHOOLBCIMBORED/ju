import SwiftUI

struct EditAccountSheet: View {
    @ObservedObject var account: AccountModel
    @Environment(\.dismiss) var dismiss

    @State private var balanceText = ""
    @State private var savingsText = ""
    @State private var bitcoinText = ""
    @State private var bitcoinChange = ""
    @State private var cashtag = ""
    @State private var cardLast4 = ""
    @State private var accountLast4 = ""
    @State private var cardholderName = ""
    @State private var profileEmoji = ""
    @State private var profileLetter = ""
    @State private var profileColor = ""
    @State private var greenStatus = ""
    @State private var notifCount = ""
    @State private var gradTop = ""
    @State private var gradBottom = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("🌓 Appearance")) {
                    Toggle("Dark Mode", isOn: $account.isDarkMode)
                    Toggle("Use Emoji Profile", isOn: $account.useEmojiProfile)
                    if account.useEmojiProfile {
                        HStack { Text("Profile Emoji"); Spacer(); TextField("🌍", text: $profileEmoji).multilineTextAlignment(.trailing) }
                    } else {
                        HStack { Text("Profile Letter"); Spacer(); TextField("B", text: $profileLetter).multilineTextAlignment(.trailing) }
                        HStack { Text("Color (hex)"); Spacer(); TextField("8B5CF6", text: $profileColor).multilineTextAlignment(.trailing) }
                    }
                }

                Section(header: Text("🎨 Background Gradient")) {
                    HStack {
                        Text("Top color (hex)")
                        Spacer()
                        TextField("0a0a0a", text: $gradTop)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Bottom color (hex)")
                        Spacer()
                        TextField("282828", text: $gradBottom)
                            .multilineTextAlignment(.trailing)
                    }
                    // Preview
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            colors: [Color(hex: gradTop.isEmpty ? account.gradientTopColor : gradTop),
                                     Color(hex: gradBottom.isEmpty ? account.gradientBottomColor : gradBottom)],
                            startPoint: .top, endPoint: .bottom))
                        .frame(height: 40)
                }

                Section(header: Text("💳 Card")) {
                    Picker("Card Style", selection: $account.cardStyle) {
                        ForEach(CardStyle.allCases) { style in Text(style.rawValue).tag(style) }
                    }
                    HStack { Text("Cashtag"); Spacer(); TextField("$1xorfee", text: $cashtag).multilineTextAlignment(.trailing) }
                    HStack { Text("Card last 4"); Spacer(); TextField("2367", text: $cardLast4).keyboardType(.numberPad).multilineTextAlignment(.trailing) }
                    HStack { Text("Account last 4"); Spacer(); TextField("9890", text: $accountLast4).keyboardType(.numberPad).multilineTextAlignment(.trailing) }
                    HStack { Text("Cardholder name"); Spacer(); TextField("Elliot Payne", text: $cardholderName).multilineTextAlignment(.trailing) }
                }

                Section(header: Text("💰 Balances")) {
                    HStack { Text("Cash $"); TextField("24.85", text: $balanceText).keyboardType(.decimalPad) }
                    HStack { Text("Savings $"); TextField("14500.00", text: $savingsText).keyboardType(.decimalPad) }
                    HStack { Text("Bitcoin $"); TextField("12552.47", text: $bitcoinText).keyboardType(.decimalPad) }
                    HStack { Text("BTC Change %"); TextField("-0.24", text: $bitcoinChange).keyboardType(.decimalPad) }
                }

                Section(header: Text("📱 Status")) {
                    HStack { Text("Green status text"); Spacer(); TextField("In progress", text: $greenStatus).multilineTextAlignment(.trailing) }
                }

                Section(header: Text("🔔 Notifications")) {
                    HStack { Text("Badge count"); Spacer(); TextField("1", text: $notifCount).keyboardType(.numberPad).multilineTextAlignment(.trailing) }
                }

                Section {
                    Button(action: saveAndDismiss) {
                        HStack { Spacer(); Text("Save Changes").font(.system(size: 17, weight: .bold)).foregroundColor(.white); Spacer() }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color(hex: "00D632"))
                }
            }
            .navigationTitle("Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
            }
        }
        .onAppear(perform: loadValues)
    }

    func loadValues() {
        balanceText    = String(format: "%.2f", account.balance)
        savingsText    = String(format: "%.2f", account.savingsBalance)
        bitcoinText    = String(format: "%.2f", account.bitcoinBalance)
        bitcoinChange  = String(format: "%.2f", account.bitcoinChange)
        cashtag        = account.cashtag
        cardLast4      = account.cardLastFour
        accountLast4   = account.accountLastFour
        cardholderName = account.cardholderName
        profileEmoji   = account.profileEmoji
        profileLetter  = account.profileLetter
        profileColor   = account.profileColor
        greenStatus    = account.greenStatusText
        notifCount     = "\(account.notificationCount)"
        gradTop        = account.gradientTopColor
        gradBottom     = account.gradientBottomColor
    }

    func saveAndDismiss() {
        if let v = Double(balanceText)   { account.balance = v }
        if let v = Double(savingsText)   { account.savingsBalance = v }
        if let v = Double(bitcoinText)   { account.bitcoinBalance = v }
        if let v = Double(bitcoinChange) { account.bitcoinChange = v }
        if !cashtag.isEmpty              { account.cashtag = cashtag }
        if cardLast4.count == 4          { account.cardLastFour = cardLast4 }
        if accountLast4.count == 4       { account.accountLastFour = accountLast4 }
        if !cardholderName.isEmpty       { account.cardholderName = cardholderName }
        if !profileEmoji.isEmpty         { account.profileEmoji = profileEmoji }
        if profileLetter.count >= 1      { account.profileLetter = String(profileLetter.prefix(1)) }
        if !profileColor.isEmpty         { account.profileColor = profileColor }
        if !greenStatus.isEmpty          { account.greenStatusText = greenStatus }
        if let n = Int(notifCount)       { account.notificationCount = n }
        if !gradTop.isEmpty              { account.gradientTopColor = gradTop }
        if !gradBottom.isEmpty           { account.gradientBottomColor = gradBottom }
        dismiss()
    }
}
