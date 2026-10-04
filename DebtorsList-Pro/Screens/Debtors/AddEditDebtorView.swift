

import SwiftUI
import SwiftData


struct AddEditDebtorView: View {

    let debtorToEdit: Debtor?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var purchaseManager: InAppPurchaseViewModel
    @EnvironmentObject private var adManager: AdManager
    @Query private var allDebtors: [Debtor]

    @State private var name = ""
    @State private var amountText = ""
    @State private var direction: DebtDirection = .owedToMe
    @State private var unitType: DebtUnitType = .currency
    @State private var currencyCode = "USD"
    @State private var itemName: String?
    @State private var itemEmoji: String?
    @State private var dueDate: Date?
    @State private var notes = ""

    @State private var isShowingCurrencyPicker = false
    @State private var isShowingContactPicker = false
    @State private var isShowingPaywall = false
    @State private var isShowingLimitAlert = false

    private let notesLimit = 200

    private var isEditing: Bool { debtorToEdit != nil }

    private var currencyOrItemLabel: String {
        unitType == .currency ? currencyCode : (itemEmoji ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    nameSection
                    amountSection
                    currencyItemSection
                    directionSection
                    dueDateSection
                    notesSection

                    PrimaryButton(title: "Save Debtor") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || amountText.isEmpty)
                        .padding(.top, 4)
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit Debtor" : "Add Debtor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppTheme.primary)
                }
            }
            .onAppear(perform: populateIfEditing)
            .sheet(isPresented: $isShowingCurrencyPicker) {
                CurrencyItemPickerView(
                    unitType: $unitType,
                    currencyCode: $currencyCode,
                    itemName: $itemName,
                    itemEmoji: $itemEmoji
                )
            }
            .sheet(isPresented: $isShowingContactPicker) {
                ContactPickerView { pickedName in
                    name = pickedName
                }
            }
            .fullScreenCover(isPresented: $isShowingPaywall) {
                PaywallView(onClose: { isShowingPaywall = false })
            }
            .alert("Free plan limit reached", isPresented: $isShowingLimitAlert) {
                Button("Upgrade to Pro") { isShowingPaywall = true }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("The Free plan supports up to \(AppDefaults.freeDebtorLimit) active debtors. Upgrade to Pro for unlimited debtors.")
            }
        }
    }


    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel("Name")
            HStack(spacing: 10) {
                FieldBox {
                    TextField("Enter name", text: $name)
                        .foregroundStyle(AppTheme.textPrimary)
                        .padding(.vertical, 4)
                }

                Button {
                    isShowingContactPicker = true
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "person.crop.circle")
                        Text("Contacts")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 92)
                    .padding(.vertical, 10)
                }
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel("Amount")
            FieldBox {
                HStack {
                    TextField("0.00", text: $amountText)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Divider().frame(height: 20)
                    Button {
                        isShowingCurrencyPicker = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(currencyOrItemLabel)
                            Image(systemName: "chevron.down").font(.caption2)
                        }
                        .foregroundStyle(AppTheme.textPrimary)
                    }
                }
            }
        }
    }

    private var currencyItemSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel("Currency / Item")
            Button {
                isShowingCurrencyPicker = true
            } label: {
                FieldBox {
                    HStack {
                        Text(unitType == .currency
                             ? "\(currencyCode) — \(CurrencyCatalog.name(for: currencyCode))"
                             : "\(itemEmoji ?? "") \(itemName ?? "Custom item")")
                            .foregroundStyle(AppTheme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
    }

    private var directionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel("Direction")
            HStack(spacing: 0) {
                directionButton(.owedToMe, label: "They owe me", icon: "arrow.up", tint: AppTheme.success)
                directionButton(.iOwe, label: "I owe", icon: "arrow.down", tint: AppTheme.danger)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func directionButton(_ value: DebtDirection, label: String, icon: String, tint: Color) -> some View {
        let isSelected = direction == value
        return Button {
            direction = value
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label)
            }
            .font(.bodyText.weight(.medium))
            .foregroundStyle(isSelected ? .white : tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? tint : tint.opacity(0.15))
        }
    }

    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel("Due date", badge: "PRO")

            if purchaseManager.isPro {
                FieldBox {
                    DatePicker(
                        "Due date",
                        selection: Binding(get: { dueDate ?? .now }, set: { dueDate = $0 }),
                        displayedComponents: .date
                    )
                    .foregroundStyle(AppTheme.textPrimary)
                }
            } else {
                Button {
                    isShowingPaywall = true
                } label: {
                    FieldBox {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Set due date")
                            Spacer()
                            Text("PRO")
                                .font(.caption.bold())
                                .foregroundStyle(AppTheme.gold)
                        }
                        .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                Text("Due date is available in Pro.")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            FieldLabel("Notes (optional)")
            FieldBox {
                VStack(alignment: .trailing, spacing: 4) {
                    TextField("Add a note...", text: $notes, axis: .vertical)
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(3...6)
                        .onChange(of: notes) { _, newValue in
                            if newValue.count > notesLimit {
                                notes = String(newValue.prefix(notesLimit))
                            }
                        }
                    Text("\(notes.count)/\(notesLimit)")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
        }
    }


    private func populateIfEditing() {
        guard let debtor = debtorToEdit else { return }
        name = debtor.name
        amountText = String(debtor.originalAmount)
        direction = debtor.direction
        unitType = debtor.unitType
        currencyCode = debtor.currencyCode ?? "USD"
        itemName = debtor.itemName
        itemEmoji = debtor.itemEmoji
        dueDate = debtor.dueDate
        notes = debtor.notes ?? ""
    }

    private func save() {
        guard let amount = Double(amountText.replacingOccurrences(of: ",", with: ".")) else { return }

        if !isEditing && !purchaseManager.isPro {
            let activeCount = allDebtors.filter { !$0.isSettled }.count
            guard activeCount < AppDefaults.freeDebtorLimit else {
                isShowingLimitAlert = true
                return
            }
        }

        let effectiveDueDate = purchaseManager.isPro ? dueDate : nil
        let targetDebtor: Debtor
        let wasEditing = isEditing

        if let existing = debtorToEdit {
            existing.name = name
            existing.originalAmount = amount
            existing.direction = direction
            existing.unitType = unitType
            existing.currencyCode = unitType == .currency ? currencyCode : nil
            existing.itemName = unitType == .item ? itemName : nil
            existing.itemEmoji = unitType == .item ? itemEmoji : nil
            existing.dueDate = effectiveDueDate
            existing.notes = notes.isEmpty ? nil : notes
            targetDebtor = existing
        } else {
            let newDebtor = Debtor(
                name: name,
                direction: direction,
                unitType: unitType,
                currencyCode: unitType == .currency ? currencyCode : nil,
                itemName: unitType == .item ? itemName : nil,
                itemEmoji: unitType == .item ? itemEmoji : nil,
                originalAmount: amount,
                dueDate: effectiveDueDate,
                notes: notes.isEmpty ? nil : notes
            )
            modelContext.insert(newDebtor)
            targetDebtor = newDebtor
        }

        if purchaseManager.isPro && effectiveDueDate != nil {
            Task { await NotificationManager.shared.scheduleDueDateReminder(for: targetDebtor) }
        } else {
            NotificationManager.shared.cancelDueDateReminder(for: targetDebtor)
        }

        if !wasEditing && !purchaseManager.isPro {
            adManager.requestInterstitialAfterDismiss()
        }
        dismiss()
    }
}


private struct FieldLabel: View {
    let text: String
    let badge: String?

    init(_ text: String, badge: String? = nil) {
        self.text = text
        self.badge = badge
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            if let badge {
                Text(badge)
                    .font(.caption2.bold())
                    .foregroundStyle(AppTheme.primary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.primary.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }
}

private struct FieldBox<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
