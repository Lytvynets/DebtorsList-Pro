
import SwiftUI

struct MainTabView: View {

    private enum Tab {
        case home, debtors, stats, settings
    }

    @EnvironmentObject private var adManager: AdManager
    @State private var selectedTab: Tab = .home
    @State private var isShowingAddDebtor = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(Tab.home)

                DebtorsListView()
                    .tabItem { Label("Debtors", systemImage: "person.2.fill") }
                    .tag(Tab.debtors)

                StatsView()
                    .tabItem { Label("Stats", systemImage: "chart.pie.fill") }
                    .tag(Tab.stats)

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                    .tag(Tab.settings)
            }
            .tint(AppTheme.primary)

            if selectedTab == .home || selectedTab == .debtors {
                Button {
                    isShowingAddDebtor = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(AppTheme.primaryGradient)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 70)
            }
        }
        .sheet(isPresented: $isShowingAddDebtor, onDismiss: {
            adManager.showInterstitialIfRequested()
        }) {
            AddEditDebtorView(debtorToEdit: nil)
        }
    }
}
