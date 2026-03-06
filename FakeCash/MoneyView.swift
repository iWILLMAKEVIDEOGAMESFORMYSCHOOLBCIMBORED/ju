import SwiftUI

struct MoneyView: View {
    @ObservedObject var account: AccountModel
    @Binding var showEdit: Bool
    @Binding var showCard: Bool
    @Binding var showSend: Bool
    @Binding var showNotifications: Bool
    @State private var balanceHidden = false
    @State private var showAddMoney = false
    @State private var toastMessage: String? = nil

    var isDark: Bool { account.isDarkMode }
    var textP: Color { isDark ? .white : .black }
    var textS: Color { isDark ? Color(hex: "8e8e93") : Color(hex: "6c6c70") }
    var tileBg: Color { isDark ? Color(hex: "1c1c1e") : Color(hex: "ffffff") }
    var btnBg: Color { isDark ? Color(hex: "2c2c2e") : Color(hex: "e8e8e8") }
    var sectionBg: Color { isDark ? Color(hex: "111111") : Color(hex: "f5f5f5") }
    var pageBg: Color { isDark ? Color(hex: "1a1a1a") : Color(hex: "f0f0f0") }

    var body: some View {
        ZStack {
            pageBg.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Dark gradient bg + header + peeking card ──
                    ZStack(alignment: .top) {
                        // User-customizable gradient background
                        LinearGradient(
                            colors: [
                                Color(hex: account.gradientTopColor),
                                Color(hex: account.gradientBottomColor)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 310)

                        VStack(spacing: 0) {
                            headerRow
                                .padding(.horizontal, 20)
                                .padding(.top, 56)
                                .padding(.bottom, 18)

                            // Card peeking (only top portion visible, like screenshot 3)
                            peekingCard
                                .padding(.horizontal, 16)
                        }
                    }
                    .frame(height: 310)

                    // ── White balance section slides over card ──
                    balanceSection
                        .background(sectionBg)
                        .cornerRadius(24, corners: [.topLeft, .topRight])
                        .offset(y: -24)
                        .padding(.bottom, -24)

                    // ── Savings tile ──
                    savingsTile
                        .padding(.horizontal, 16).padding(.top, 12)

                    // ── Bitcoin tile ──
                    bitcoinTile
                        .padding(.horizontal, 16).padding(.top, 12)

                    // ── More for you ──
                    moreForYou

                    // ── Add money list ──
                    addMoneySection

                    disclosureText
                    Color.clear.frame(height: 90)
                }
            }

            if let msg = toastMessage {
                VStack {
                    Spacer().frame(height: 65)
                    Text(msg)
                        .font(.system(size: 14, weight: .medium)).foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(Color(hex: "1c1c1e")).cornerRadius(14)
                    Spacer()
                }
                .zIndex(99)
            }
        }
        .sheet(isPresented: $showAddMoney) {
            AddMoneySheet(account: account, isPresented: $showAddMoney)
        }
    }

    // MARK: - Header
    var headerRow: some View {
        HStack {
            Text("Money")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 14)

            Button(action: { showEdit = true }) {
                ZStack(alignment: .topTrailing) {
                    if account.useEmojiProfile {
                        Circle()
                            .fill(Color(hex: account.profileColor))
                            .frame(width: 36, height: 36)
                            .overlay(Text(account.profileEmoji).font(.system(size: 18)))
                    } else {
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "1a4a8a"), Color(hex: "0d2d5e")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 36, height: 36)
                            .overlay(Text(account.profileLetter.isEmpty ? "?" : String(account.profileLetter.prefix(1))).font(.system(size: 16, weight: .bold)).foregroundColor(.white))
                    }
                    if account.notificationCount > 0 {
                        Circle().fill(Color.red).frame(width: 16, height: 16)
                            .overlay(Text("\(min(account.notificationCount,9))").font(.system(size: 9, weight: .bold)).foregroundColor(.white))
                            .overlay(Circle().stroke(Color(hex: account.gradientTopColor), lineWidth: 2))
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
    }

    // MARK: - Peeking card (only top strip visible, balance section covers most of it)
    var peekingCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(
                    colors: account.cardStyle.gradient,
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(height: 190)
                .shadow(color: .black.opacity(0.4), radius: 14, x: 0, y: 6)

            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                .frame(height: 190)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    HStack(spacing: 7) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(account.cardStyle.textColor.opacity(0.18))
                                .frame(width: 22, height: 16)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(account.cardStyle.textColor.opacity(0.45))
                                .frame(width: 9, height: 7)
                        }
                        Text("•• \(account.cardLastFour)")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(account.cardStyle.textColor.opacity(0.9))
                    }
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(account.cardStyle.textColor.opacity(0.1))
                    .cornerRadius(20)

                    Spacer()

                    Text(account.cashtag)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(account.cardStyle.textColor.opacity(0.75))
                }
                .padding(.horizontal, 18).padding(.top, 18)
            }
        }
        .frame(height: 190)
        .onTapGesture { showCard = true }
    }

    // MARK: - Balance Section
    var balanceSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 5) {
                    Text("Cash balance •• \(account.accountLastFour)")
                        .font(.system(size: 16, weight: .medium)).foregroundColor(textP)
                    Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold)).foregroundColor(textP)
                }
                Spacer()
                Button(action: { balanceHidden.toggle() }) {
                    Image(systemName: "eye.slash").font(.system(size: 20)).foregroundColor(textS)
                }
            }
            .padding(.horizontal, 22).padding(.top, 28).padding(.bottom, 4)

            Text(balanceHidden ? "••••••" : account.balanceDisplay)
                .font(.system(size: 50, weight: .bold)).foregroundColor(textP)
                .tracking(-1.5)
                .padding(.horizontal, 22).padding(.bottom, 30)

            HStack(spacing: 12) {
                // Add money button opens sheet
                Button(action: { showAddMoney = true }) {
                    Text("Add money")
                        .font(.system(size: 16, weight: .semibold)).foregroundColor(textP)
                        .frame(maxWidth: .infinity).padding(.vertical, 17)
                        .background(btnBg).cornerRadius(50)
                }
                Button(action: { toast("Withdraw tapped") }) {
                    Text("Withdraw")
                        .font(.system(size: 16, weight: .semibold)).foregroundColor(textP)
                        .frame(maxWidth: .infinity).padding(.vertical, 17)
                        .background(btnBg).cornerRadius(50)
                }
            }
            .padding(.horizontal, 22).padding(.bottom, 14)

            // Green status
            greenStatusRow
                .padding(.horizontal, 22).padding(.bottom, 24)
        }
    }

    // MARK: - Green Status
    // Solid green tall rounded rect — like the rounded-rectangle phone-body shape Cash App uses
    var greenStatusRow: some View {
        HStack(spacing: 12) {
            ZStack {
                // Outer phone body
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: "00D632"))
                    .frame(width: 16, height: 28)
                // Top speaker nub
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.55))
                    .frame(width: 6, height: 3)
                    .offset(y: -9)
            }

            Text("Green status")
                .font(.system(size: 16, weight: .semibold)).foregroundColor(textP)
            Spacer()
            Text(account.greenStatusText)
                .font(.system(size: 15, weight: .medium)).foregroundColor(textS)
        }
        .padding(.horizontal, 16).padding(.vertical, 16)
        .background(tileBg).cornerRadius(16)
    }

    // MARK: - Tiles
    var savingsTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(tileBg)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Savings").font(.system(size: 15, weight: .medium)).foregroundColor(textP)
                    Text(account.savingsDisplay).font(.system(size: 28, weight: .bold)).foregroundColor(textP)
                    Text("Up to 3.25% interest").font(.system(size: 13)).foregroundColor(textS)
                }
                Spacer()
                Circle().stroke(Color(hex: "00D632"), lineWidth: 2).frame(width: 44, height: 44)
                    .overlay(Text("$").font(.system(size: 20, weight: .bold)).foregroundColor(Color(hex: "00D632")))
            }.padding(18)
        }
    }

    var bitcoinTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(tileBg)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Bitcoin").font(.system(size: 15, weight: .medium)).foregroundColor(textP)
                    Text(account.bitcoinDisplay).font(.system(size: 28, weight: .bold)).foregroundColor(textP)
                    HStack(spacing: 4) {
                        Image(systemName: account.bitcoinChange >= 0 ? "arrow.up" : "arrow.down")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(account.bitcoinChange >= 0 ? Color(hex: "00D632") : .red)
                        Text(String(format: "%.2f%%", abs(account.bitcoinChange)))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(account.bitcoinChange >= 0 ? Color(hex: "00D632") : .red)
                        Text("today").font(.system(size: 13)).foregroundColor(textS)
                    }
                }
                Spacer()
                BitcoinMiniChart(positive: account.bitcoinChange >= 0).frame(width: 100, height: 50)
            }.padding(18)
        }
    }

    // MARK: - More For You
    var moreForYou: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("More for you")
                .font(.system(size: 22, weight: .bold)).foregroundColor(textP)
                .padding(.horizontal, 20).padding(.top, 28).padding(.bottom, 16)

            ForEach([("💵","Paychecks","Get paid faster"),
                     ("🪙","Bitcoin","Learn and invest"),
                     ("🌹","Savings","Up to 3.25% interest"),
                     ("📈","Stocks","Invest with $1"),
                     ("💎","Pools","Collect money with anyone")], id: \.1) { icon, label, sub in
                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isDark ? Color(hex: "2c2c2e") : Color(hex: "f0f0f0"))
                        .frame(width: 52, height: 52)
                        .overlay(Text(icon).font(.system(size: 26)))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(label).font(.system(size: 17, weight: .semibold)).foregroundColor(textP)
                        Text(sub).font(.system(size: 14)).foregroundColor(textS)
                    }
                    Spacer()
                    Button(action: { toast("Starting \(label)") }) {
                        Text("Start")
                            .font(.system(size: 15, weight: .semibold)).foregroundColor(textP)
                            .padding(.horizontal, 18).padding(.vertical, 8)
                            .background(isDark ? Color(hex: "2c2c2e") : Color(hex: "f0f0f0"))
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 20)
            }
        }
    }

    // MARK: - Add Money List
    var addMoneySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Add money")
                .font(.system(size: 22, weight: .bold)).foregroundColor(textP)
                .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 4)

            ForEach(Array([("arrow.down.to.line","Direct deposit"),
                           ("arrow.2.circlepath","Get bank or wire transfer"),
                           ("banknote","Deposit paper money"),
                           ("doc.viewfinder","Deposit check"),
                           ("repeat","Auto reload")].enumerated()), id: \.offset) { i, row in
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        Image(systemName: row.0).font(.system(size: 20)).foregroundColor(textP).frame(width: 28)
                        Text(row.1).font(.system(size: 17, weight: .medium)).foregroundColor(textP)
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(textS)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 18)
                    .contentShape(Rectangle()).onTapGesture { toast("\(row.1) tapped") }
                    if i < 4 { Divider().padding(.leading, 64) }
                }
            }
        }
    }

    var disclosureText: some View {
        VStack(alignment: .leading, spacing: 14) {
            (Text("Your balance is eligible for FDIC pass-through insurance through Wells Fargo Bank, N.A., Sutton Bank, and/or The Bancorp Bank, N.A., Members FDIC. See the ")
             + Text("Cash App Terms of Service.").underline())
            .font(.system(size: 11, design: .monospaced)).foregroundColor(textS)
        }
        .padding(.horizontal, 20).padding(.vertical, 24)
    }

    func toast(_ msg: String) {
        withAnimation { toastMessage = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { toastMessage = nil } }
    }
}

// MARK: - Bitcoin Mini Chart
struct BitcoinMiniChart: View {
    var positive: Bool
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let pts: [CGFloat] = [0.6,0.75,0.5,0.7,0.45,0.55,0.35,0.5,0.3,0.45,0.2,0.35,0.15,0.25,0.1]
            let step = w / CGFloat(pts.count - 1)
            Path { path in
                path.move(to: CGPoint(x: 0, y: h * pts[0]))
                for (i, pt) in pts.enumerated() { path.addLine(to: CGPoint(x: CGFloat(i)*step, y: h*pt)) }
            }
            .stroke(positive ? Color(hex: "00D632") : Color.red,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Bottom Tab Bar
struct BottomTabBar: View {
    @ObservedObject var account: AccountModel
    @Binding var selectedTab: Int
    @Binding var showSend: Bool
    @Binding var showNotifications: Bool

    var isDark: Bool { account.isDarkMode }
    var bg: Color { isDark ? Color(hex: "0a0a0a") : .white }
    var active: Color { isDark ? .white : .black }
    var inactive: Color { isDark ? Color(hex: "636366") : Color(hex: "aaaaaa") }

    var body: some View {
        HStack {
            Spacer()
            Button(action: { selectedTab = 0 }) {
                Text(account.balanceRounded)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(selectedTab == 0 ? active : inactive)
            }
            Spacer()
            Button(action: { showSend = true }) {
                Text("$").font(.system(size: 26, weight: .bold)).foregroundColor(inactive)
            }
            Spacer()
            ZStack(alignment: .topTrailing) {
                Button(action: { showNotifications = true }) {
                    Image(systemName: "clock").font(.system(size: 22))
                        .foregroundColor(selectedTab == 2 ? active : inactive)
                }
                if account.notificationCount > 0 {
                    Circle().fill(Color.red).frame(width: 16, height: 16)
                        .overlay(Text("\(min(account.notificationCount,9))").font(.system(size: 9, weight: .bold)).foregroundColor(.white))
                        .overlay(Circle().stroke(bg, lineWidth: 2))
                        .offset(x: 9, y: -9)
                }
            }
            Spacer()
        }
        .padding(.top, 12).padding(.bottom, 34)
        .background(bg.ignoresSafeArea(edges: .bottom))
        .overlay(Divider().background(isDark ? Color(hex: "2c2c2e") : Color(hex: "e0e0e0")), alignment: .top)
    }
}
