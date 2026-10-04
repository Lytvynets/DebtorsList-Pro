

import SwiftUI
import SwiftData

struct DebtorsListView: View {

    @Query(sort: \Debtor.createdAt, order: .reverse) private var allDebtors: [Debtor]
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var currencyService: CurrencyService
    @EnvironmentObject private var purchaseManager: InAppPurchaseViewModel

    @AppStorage(AppDefaults.displayCurrencyKey) private var displayCurrency: String = "USD"
    @State private var searchText = ""
    @State private var filter: DebtorFilter = .all
    @State private var sortOption: SortOption = .amount
    @State private var isShowingReminder = false
    @State private var reminderText = ""

    private enum DebtorFilter: String, CaseIterable {
        case all = "All"
        case owedToMe = "They owe me"
        case iOwe = "I owe"
        case closed = "Closed"
    }

    private enum SortOption: String, CaseIterable {
        case amount = "Amount"
        case name = "Name"
        case lastActivity = "Last activity"
    }

    private var filteredDebtors: [Debtor] {
        var result: [Debtor]

        switch filter {
        case .all: result = allDebtors.filter { !$0.isSettled }
        case .owedToMe: result = allDebtors.filter { $0.direction == .owedToMe && !$0.isSettled }
        case .iOwe: result = allDebtors.filter { $0.direction == .iOwe && !$0.isSettled }
        case .closed: result = allDebtors.filter { $0.isSettled }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        switch sortOption {
        case .amount: result.sort { $0.remainingAmount > $1.remainingAmount }
        case .name: result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .lastActivity: result.sort { $0.lastActivityDate > $1.lastActivityDate }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                searchAndSort
                filterChips

                Text("\(filteredDebtors.count) debtors")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if filteredDebtors.isEmpty {
                    Spacer()
                    EmptyStateView(
                        systemImage: "magnifyingglass",
                        title: "Nothing found",
                        message: searchText.isEmpty
                            ? "No debtors in this category yet."
                            : "We couldn't find a debtor matching \"\(searchText)\"."
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(filteredDebtors, id: \.id) { debtor in
                            DebtorRow(debtor: debtor, displayCurrency: displayCurrency)
                                .background(
                                    NavigationLink(destination: DebtorDetailView(debtor: debtor)) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                )
                            .listRowBackground(AppTheme.background)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    modelContext.delete(debtor)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    reminderText = "Hi \(debtor.name)! Just a friendly reminder about the debt. Thanks! 🙂"
                                    isShowingReminder = true
                                } label: {
                                    Label("Remind", systemImage: "bell")
                                }
                                .tint(AppTheme.primary)

                                Button {
                                    debtor.isSettled = true
                                } label: {
                                    Label("Mark as paid", systemImage: "checkmark")
                                }
                                .tint(AppTheme.success)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }

                if !purchaseManager.isPro {
                    AdBannerView()
                        .padding(.horizontal, -16) 
                }
            }
            .padding(.horizontal)
            .scrollDismissesKeyboard(.interactively)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Debtors")
            .sheet(isPresented: $isShowingReminder) {
                ShareSheet(items: [reminderText])
            }
        }
    }

    private var searchAndSort: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppTheme.textSecondary)
                TextField("Search debtors", text: $searchText)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            .padding(10)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Menu {
                Picker("Sort by", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(10)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(DebtorFilter.allCases, id: \.self) { option in
                    Button {
                        filter = option
                    } label: {
                        Text(option.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(filter == option ? AppTheme.primary : AppTheme.surface)
                            .foregroundStyle(filter == option ? .white : AppTheme.textPrimary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}
