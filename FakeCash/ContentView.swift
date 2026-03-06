import SwiftUI

struct ContentView: View {
    @StateObject var account = AccountModel()
    @State private var selectedTab: Int = 0
    @State private var showEdit = false
    @State private var showCard = false
    @State private var showSend = false
    @State private var showNotifications = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if showCard {
                    CardDetailView(account: account, isPresented: $showCard)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if showSend {
                    SendView(account: account, isPresented: $showSend)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else if showNotifications {
                    NotificationsView(account: account, isPresented: $showNotifications)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    MoneyView(account: account,
                              showEdit: $showEdit,
                              showCard: $showCard,
                              showSend: $showSend,
                              showNotifications: $showNotifications)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showCard)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showSend)
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showNotifications)

            if !showCard && !showSend && !showNotifications {
                BottomTabBar(account: account,
                             selectedTab: $selectedTab,
                             showSend: $showSend,
                             showNotifications: $showNotifications)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showEdit) {
            EditAccountSheet(account: account)
        }
        .preferredColorScheme(account.isDarkMode ? .dark : .light)
    }
}
