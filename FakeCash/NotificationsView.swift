import SwiftUI

struct NotificationsView: View {
    @ObservedObject var account: AccountModel
    @Binding var isPresented: Bool
    @State private var showAddSheet = false

    var isDark: Bool { account.isDarkMode }
    var bg: Color { isDark ? .black : Color(hex: "f2f2f7") }
    var cardBg: Color { isDark ? Color(hex: "1c1c1e") : .white }
    var textP: Color { isDark ? .white : .black }
    var textS: Color { isDark ? Color(hex: "8e8e93") : Color(hex: "6c6c70") }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textP)
                    }
                    Spacer()
                    Text("Activity")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(textP)
                    Spacer()
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(textP)
                    }
                }
                .padding(.horizontal, 20).padding(.top, 56).padding(.bottom, 20)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 1) {
                        ForEach(account.notifications) { notif in
                            notifRow(notif)
                        }
                        .onDelete { idx in account.notifications.remove(atOffsets: idx) }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddNotificationSheet(account: account)
        }
    }

    func notifRow(_ n: FakeNotification) -> some View {
        HStack(spacing: 14) {
            Circle().fill(isDark ? Color(hex: "2c2c2e") : Color(hex: "f0f0f0"))
                .frame(width: 48, height: 48)
                .overlay(Text(n.emoji).font(.system(size: 22)))

            VStack(alignment: .leading, spacing: 3) {
                Text(n.title).font(.system(size: 16, weight: .semibold)).foregroundColor(textP)
                Text(n.subtitle).font(.system(size: 14)).foregroundColor(textS)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(n.amount)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(n.amount.hasPrefix("+") ? Color(hex: "00D632") : textP)
                Text(n.time).font(.system(size: 12)).foregroundColor(textS)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(cardBg)
        .cornerRadius(16)
    }
}

struct AddNotificationSheet: View {
    @ObservedObject var account: AccountModel
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var subtitle = ""
    @State private var amount = ""
    @State private var time = "Just now"
    @State private var emoji = "💸"

    var isDark: Bool { account.isDarkMode }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notification")) {
                    HStack { Text("Emoji"); Spacer(); TextField("💸", text: $emoji).multilineTextAlignment(.trailing) }
                    HStack { Text("Title"); Spacer(); TextField("Cash received", text: $title).multilineTextAlignment(.trailing) }
                    HStack { Text("Subtitle"); Spacer(); TextField("From $johndoe", text: $subtitle).multilineTextAlignment(.trailing) }
                    HStack { Text("Amount"); Spacer(); TextField("+$50.00", text: $amount).multilineTextAlignment(.trailing).keyboardType(.decimalPad) }
                    HStack { Text("Time"); Spacer(); TextField("Just now", text: $time).multilineTextAlignment(.trailing) }
                }
                Section {
                    Button(action: addAndDismiss) {
                        HStack { Spacer()
                            Text("Add Notification").font(.system(size: 17, weight: .bold)).foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color(hex: "00D632"))
                }
            }
            .navigationTitle("Add Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
            }
        }
    }

    func addAndDismiss() {
        let n = FakeNotification(
            title: title.isEmpty ? "Notification" : title,
            subtitle: subtitle.isEmpty ? "" : subtitle,
            amount: amount.isEmpty ? "+$0.00" : amount,
            time: time.isEmpty ? "Just now" : time,
            emoji: emoji.isEmpty ? "💸" : emoji
        )
        account.notifications.insert(n, at: 0)
        account.notificationCount += 1
        dismiss()
    }
}
