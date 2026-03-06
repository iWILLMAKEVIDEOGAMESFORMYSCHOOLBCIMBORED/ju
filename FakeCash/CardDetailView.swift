import SwiftUI

struct CardDetailView: View {
    @ObservedObject var account: AccountModel
    @Binding var isPresented: Bool

    @State private var rotX: Double = 0
    @State private var rotY: Double = 0

    var isDark: Bool { account.isDarkMode }
    var bg: Color { isDark ? .black : .white }
    var textP: Color { isDark ? .white : .black }
    var textS: Color { isDark ? Color(hex: "8e8e93") : Color(hex: "6c6c70") }
    var rowBg: Color { isDark ? Color(hex: "1c1c1e") : Color(hex: "f2f2f7") }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    navBar
                    draggableCard
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    lockCopyButtons
                        .padding(.horizontal, 16)
                        .padding(.bottom, 28)
                    offersRow
                    Divider().padding(.horizontal, 20).padding(.vertical, 4)
                    sectionTitle("Spending")
                    menuRow("chart.bar.fill",             "Insights & activity",   "$3 in Mar")
                    menuRow("arrow.clockwise",            "Round Ups",             "Off")
                    menuRow("link",                       "Linked merchants",      "")
                    menuRow("creditcard",                 "Find an ATM",           "")
                    Divider().padding(.horizontal, 20).padding(.vertical, 8)
                    sectionTitle("Manage card")
                    menuRow("plus.rectangle.on.rectangle","Add card to Apple Pay", "")
                    menuRow("pencil.and.outline",          "Design a new card",    "")
                    menuRow("nosign",                      "Blocked businesses",   "")
                    menuRow("asterisk",                    "Change PIN",           "")
                    menuRow("questionmark.circle",         "Get card support",     "")
                    Color.clear.frame(height: 80)
                }
            }
        }
    }

    // MARK: - Nav Bar
    var navBar: some View {
        HStack {
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(textP)
            }
            Spacer()
            Text("Card")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(textP)
            Spacer()
            Color.clear.frame(width: 28)
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
        .padding(.bottom, 24)
    }

    // MARK: - 3D Draggable Card
    var draggableCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(
                    colors: account.cardStyle.gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 210)
                .shadow(color: .black.opacity(0.5), radius: 20, x: CGFloat(rotY) * 0.3, y: 10)

            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                .frame(height: 210)

            // Eye icon
            VStack {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "eye")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        )
                }
                Spacer()
            }
            .padding(16)

            // Card content
            VStack(alignment: .leading, spacing: 12) {
                Spacer()
                HStack(spacing: 18) {
                    dotGroup(4)
                    dotGroup(4)
                    dotGroup(4)
                    Text(account.cardLastFour)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(account.cardStyle.textColor)
                }
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(account.cardholderName)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(account.cardStyle.textColor)
                        HStack(spacing: 14) {
                            Text("CVV •••")
                                .font(.system(size: 12))
                                .foregroundColor(account.cardStyle.textColor.opacity(0.7))
                            Text("EXP ••/••")
                                .font(.system(size: 12))
                                .foregroundColor(account.cardStyle.textColor.opacity(0.7))
                        }
                    }
                    Spacer()
                    Text("VISA")
                        .font(.system(size: 24, weight: .black, design: .serif))
                        .italic()
                        .foregroundColor(account.cardStyle.textColor)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
        .rotation3DEffect(.degrees(rotX), axis: (x: 1, y: 0, z: 0))
        .rotation3DEffect(.degrees(rotY), axis: (x: 0, y: 1, z: 0))
        .gesture(
            DragGesture()
                .onChanged { val in
                    withAnimation(.interactiveSpring()) {
                        rotY = max(-25, min(25, Double(val.translation.width / 8)))
                        rotX = max(-20, min(20, Double(-val.translation.height / 12)))
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        rotX = 0
                        rotY = 0
                    }
                }
        )
    }

    func dotGroup(_ n: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<n, id: \.self) { _ in
                Circle()
                    .fill(account.cardStyle.textColor)
                    .frame(width: 7, height: 7)
            }
        }
    }

    // MARK: - Lock / Copy Buttons
    var lockCopyButtons: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "lock").font(.system(size: 15))
                    Text("Lock").font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(textS)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(rowBg)
                .cornerRadius(50)
            }
            Button(action: {}) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.on.doc").font(.system(size: 15))
                    Text("Copy •• \(account.cardLastFour)").font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(textP)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(rowBg)
                .cornerRadius(50)
            }
        }
    }

    // MARK: - Offers Row
    var offersRow: some View {
        HStack(spacing: 14) {
            HStack(spacing: -10) {
                Circle().fill(Color.yellow).frame(width: 40, height: 40)
                    .overlay(Text("DC").font(.system(size: 11, weight: .black)).foregroundColor(.black))
                Circle().fill(Color(hex: "FF385C")).frame(width: 40, height: 40)
                    .overlay(Image(systemName: "house.fill").font(.system(size: 16)).foregroundColor(.white))
                Circle().fill(.black).frame(width: 40, height: 40)
                    .overlay(Image(systemName: "applelogo").font(.system(size: 16)).foregroundColor(.white))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Explore offers").font(.system(size: 16, weight: .semibold)).foregroundColor(textP)
                Text("Instant discounts").font(.system(size: 13)).foregroundColor(textS)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundColor(textS)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Section Title
    func sectionTitle(_ t: String) -> some View {
        HStack {
            Text(t).font(.system(size: 24, weight: .bold)).foregroundColor(textP)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    // MARK: - Menu Row
    func menuRow(_ icon: String, _ label: String, _ detail: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(textP).frame(width: 28)
            Text(label).font(.system(size: 17, weight: .medium)).foregroundColor(textP)
            Spacer()
            if !detail.isEmpty {
                Text(detail).font(.system(size: 15)).foregroundColor(textS)
            }
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(textS)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
}
