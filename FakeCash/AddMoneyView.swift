import SwiftUI

struct AddMoneySheet: View {
    @ObservedObject var account: AccountModel
    @Binding var isPresented: Bool

    // Use Int to avoid associated-value pattern matching issues
    // 0 = picker, 1 = authenticating, 2 = success
    @State private var stepIndex: Int = 0
    @State private var selectedAmount: Double = 10
    @State private var dotOffset: [CGFloat] = [0, 0, 0]

    var body: some View {
        Group {
            if stepIndex == 0      { pickerView }
            else if stepIndex == 1 { authenticatingView }
            else                   { successView }
        }
    }

    // MARK: - Picker
    var pickerView: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: "d0d0d0"))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)

                Text("Add money")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 20)

                Text("Cash balance \(account.balanceDisplay)")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.top, 4).padding(.bottom, 28)

                let amounts: [Double] = [10, 25, 50, 100, 200]
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 12
                ) {
                    ForEach(amounts, id: \.self) { amt in
                        Button(action: {
                            selectedAmount = amt
                            stepIndex = 1
                            startDotAnimation()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                                stepIndex = 2
                            }
                        }) {
                            Text("$\(Int(amt))")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 22)
                                .background(Color.white)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(hex: "e0e0e0"), lineWidth: 1.5)
                                )
                        }
                    }
                    Button(action: {}) {
                        Text("•••")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 22)
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(hex: "e0e0e0"), lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 24)

                Button(action: {
                    selectedAmount = 25
                    stepIndex = 1
                    startDotAnimation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { stepIndex = 2 }
                }) {
                    HStack(spacing: 5) {
                        Text("Add money with").font(.system(size: 16))
                        Image(systemName: "applelogo").font(.system(size: 14))
                        Text("Pay").font(.system(size: 16))
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Color(hex: "f2f2f2")).cornerRadius(50)
                }
                .padding(.horizontal, 16).padding(.bottom, 12)

                Button(action: {
                    selectedAmount = 50
                    stepIndex = 1
                    startDotAnimation()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) { stepIndex = 2 }
                }) {
                    Text("Add money from debit card")
                        .font(.system(size: 16)).foregroundColor(.gray)
                        .frame(maxWidth: .infinity).padding(.vertical, 18)
                        .background(Color(hex: "e0e0e0")).cornerRadius(50)
                }
                .padding(.horizontal, 16).padding(.bottom, 30)
            }
        }
        .presentationDetents([.height(540)])
        .presentationDragIndicator(.hidden)
    }

    // MARK: - Authenticating
    var authenticatingView: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "f5f5f5"))
                        .frame(width: 110, height: 80)
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(Color.black.opacity(0.8))
                                .frame(width: 13, height: 13)
                                .offset(y: dotOffset[i])
                        }
                    }
                }
                Text("Authenticating...")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
        }
    }

    // MARK: - Success
    var successView: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        account.balance += selectedAmount
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.top, 56)

                Spacer().frame(height: 40)

                Circle()
                    .fill(Color(hex: "00D632"))
                    .frame(width: 72, height: 72)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .padding(.bottom, 24)

                Text("You added $\(amountLabel) to\nyour balance")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                Spacer()

                Button(action: {
                    account.balance += selectedAmount
                    isPresented = false
                }) {
                    Text("Done")
                        .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 20)
                        .background(Color.black).cornerRadius(50)
                }
                .padding(.horizontal, 16).padding(.bottom, 40)
            }
        }
    }

    var amountLabel: String {
        let v = Int(selectedAmount)
        return "\(v)"
    }

    func startDotAnimation() {
        for i in 0..<3 {
            let delay = Double(i) * 0.18
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    dotOffset[i] = -8
                }
            }
        }
    }
}
