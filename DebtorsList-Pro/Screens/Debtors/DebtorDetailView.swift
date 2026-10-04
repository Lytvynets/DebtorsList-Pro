

import SwiftUI
import SwiftData

struct DebtorDetailView: View {

    @Bindable var debtor: Debtor

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: InAppPurchaseViewModel

    @State private var isShowingEdit = false
    @State private var isShowingAddPayment = false
    @State private var isShowingDeleteConfirm = false
    @State private var isShowingPaywall = false
    @State private var isShowingShareSheet = false

    private var reminderText: String {
        let amountText = debtor.unitType == .currency
            ? debtor.remainingAmount.formatted(.currency(code: debtor.currencyCode ?? "USD"))
            : "\(Int(debtor.remainingAmount)) \(debtor.itemName ?? "")"
        return "Hi \(debtor.name)! Just a friendly reminder about the debt of \(amountText). Thanks! 🙂"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                Button {
                    isShowingShareSheet = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Remind")
                                .foregroundStyle(AppTheme.textPrimary)
                            Text("Send a reminder via WhatsApp, SMS, etc.")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .foregroundStyle(AppTheme.primary)

                if debtor.unitType == .currency {
                    statsRow
                }

                paymentsTimeline

                if let notes = debtor.notes, !notes.isEmpty {
                    notesRow(notes)
                }

                HStack(spacing: 12) {
                    Button {
                        isShowingEdit = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(AppTheme.surface)
                    .foregroundStyle(AppTheme.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Button(role: .destructive) {
                        isShowingDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(AppTheme.surface)
                    .foregroundStyle(AppTheme.danger)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingEdit) {
            AddEditDebtorView(debtorToEdit: debtor)
        }
        .sheet(isPresented: $isShowingAddPayment) {
            AddPaymentView(debtor: debtor)
        }
        .sheet(isPresented: $isShowingShareSheet) {
            ShareSheet(items: [reminderText])
        }
        .fullScreenCover(isPresented: $isShowingPaywall) {
            PaywallView(onClose: { isShowingPaywall = false })
        }
        .alert("Delete this debtor?", isPresented: $isShowingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                modelContext.delete(debtor)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                AvatarView(initials: debtor.initials, size: 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text(debtor.name)
                        .font(.screenTitle)
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(debtor.direction == .owedToMe ? "They owe you" : "You owe")
                        .font(.bodyText)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
                if let dueDate = debtor.dueDate {
                    Text("Due \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(debtor.isOverdue ? AppTheme.danger : AppTheme.success)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(debtor.isOverdue ? AppTheme.danger : AppTheme.success, lineWidth: 1)
                        )
                }
            }

            if debtor.unitType == .currency {
                Text(debtor.remainingAmount, format: .currency(code: debtor.currencyCode ?? "USD"))
                    .font(.balanceDisplay)
                    .foregroundStyle(debtor.direction == .owedToMe ? AppTheme.success : AppTheme.danger)
            } else {
                Text("\(debtor.itemEmoji ?? "") \(Int(debtor.remainingAmount)) \(debtor.itemName ?? "")")
                    .font(.balanceDisplay)
                    .foregroundStyle(debtor.direction == .owedToMe ? AppTheme.success : AppTheme.danger)
            }

            Text("Created on \(debtor.createdAt.formatted(date: .abbreviated, time: .omitted))")
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var statsRow: some View {
        HStack {
            statColumn(title: "Original amount", value: debtor.originalAmount, color: AppTheme.textPrimary)
            Divider().frame(height: 40).background(AppTheme.divider)
            statColumn(title: "Paid", value: debtor.totalPaid, color: AppTheme.success)
            Divider().frame(height: 40).background(AppTheme.divider)
            statColumn(title: "Remaining", value: debtor.remainingAmount, color: AppTheme.textPrimary)
        }
        .padding()
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func statColumn(title: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
            Text(value, format: .currency(code: debtor.currencyCode ?? "USD"))
                .font(.cardTitle)
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var paymentsTimeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Payments timeline")
                    .font(.cardTitle)
                    .foregroundStyle(AppTheme.textPrimary)
                Text("PRO")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.gold)
                Spacer()
                Button {
                    if purchaseManager.isPro {
                        isShowingAddPayment = true
                    } else {
                        isShowingPaywall = true
                    }
                } label: {
                    Label("Add payment", systemImage: "plus")
                        .font(.caption)
                }
            }

            if purchaseManager.isPro {
                if let payments = debtor.payments, !payments.isEmpty {
                    VStack(spacing: 10) {
                        ForEach(payments.sorted(by: { $0.date > $1.date }), id: \.id) { payment in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.success)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(payment.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(AppTheme.textSecondary)
                                    Text(payment.note?.isEmpty == false ? payment.note! : "Payment")
                                        .foregroundStyle(AppTheme.textPrimary)
                                }
                                Spacer()
                                Text(payment.amount, format: .currency(code: debtor.currencyCode ?? "USD"))
                                    .foregroundStyle(AppTheme.success)
                            }
                        }
                    }
                } else {
                    Text("No payments recorded yet.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            } else {
                Button {
                    isShowingPaywall = true
                } label: {
                    Label("Unlock payment history with Pro", systemImage: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.gold)
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func notesRow(_ notes: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: "note.text")
                .foregroundStyle(AppTheme.gold)
            VStack(alignment: .leading, spacing: 4) {
                Text("Notes")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
                Text(notes)
                    .foregroundStyle(AppTheme.textPrimary)
            }
            Spacer()
        }
        .padding()
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
