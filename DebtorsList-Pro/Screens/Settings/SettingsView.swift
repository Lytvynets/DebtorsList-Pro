

import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {

    @Query private var allDebtors: [Debtor]

    @EnvironmentObject private var purchaseManager: InAppPurchaseViewModel
    @EnvironmentObject private var appLock: AppLockManager
    @EnvironmentObject private var cloudKitSyncMonitor: CloudKitSyncMonitor

    @AppStorage(AppDefaults.displayCurrencyKey) private var displayCurrency: String = "USD"
    @AppStorage(AppDefaults.reminderMessageTemplateKey) private var reminderTemplate: String = "Hi! Just a friendly reminder about the debt. Thanks!"
    @AppStorage(AppDefaults.reminderHourKey) private var reminderHour: Int = 18
    @AppStorage(AppDefaults.reminderWeekdayKey) private var reminderWeekday: Int = 6

    @State private var isShowingPaywall = false
    @State private var isShowingCurrencyPicker = false
    @State private var notificationsEnabled = false
    @State private var isShowingNotificationsDeniedAlert = false
    @State private var isShowingExportSheet = false
    @State private var exportFileURL: URL?

    private var syncNeedsRestart: Bool {
        purchaseManager.isPro && !CloudKitAvailability.isEnabledThisSession
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Settings")
                        .font(.screenTitle)
                        .foregroundStyle(AppTheme.textPrimary)

                    proHero

                    SettingsCard(header: "General") {
                        Button {
                            if purchaseManager.isPro {
                                isShowingCurrencyPicker = true
                            } else {
                                isShowingPaywall = true
                            }
                        } label: {
                            SettingsRow(icon: "dollarsign", iconColor: AppTheme.primary, title: "Default Currency", subtitle: displayCurrency) {
                                proOrChevron()
                            }
                        }

                        SettingsRowDivider()
                    }

                    SettingsCard(header: "Reminders") {
                        SettingsRow(icon: "bell.badge.fill", iconColor: AppTheme.primary, title: "Notifications") {
                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                                .onChange(of: notificationsEnabled) { _, newValue in
                                    handleNotificationsToggle(newValue)
                                }
                        }

                        SettingsRowDivider()

                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: AppTheme.primary,
                            title: "Reminder Day & Time",
                            subtitle: reminderSummaryText
                        ) {
                            DatePicker("", selection: reminderTimeBinding, displayedComponents: [.hourAndMinute])
                                .labelsHidden()
                        }

                        SettingsRowDivider()

                        NavigationLink {
                            ReminderTemplateEditorView(template: $reminderTemplate)
                        } label: {
                            SettingsRow(
                                icon: "message.fill",
                                iconColor: AppTheme.primary,
                                title: "Reminder Message Template",
                                subtitle: reminderTemplate
                            ) {
                                Image(systemName: "chevron.right").foregroundStyle(AppTheme.textSecondary)
                            }
                        }
                    }

                    SettingsCard(header: "Security") {
                        SettingsRow(icon: "faceid", iconColor: AppTheme.success, title: "Face ID / Touch ID", subtitle: "Use biometrics to protect your data") {
                            Toggle("", isOn: $appLock.isEnabled)
                                .labelsHidden()
                        }
                    }

                    SettingsCard(header: "Sync") {
                        Button {
                            if !purchaseManager.isPro { isShowingPaywall = true }
                        } label: {
                            SettingsRow(icon: "icloud.fill", iconColor: AppTheme.primary, title: "iCloud Sync", subtitle: syncSubtitle) {
                                if !purchaseManager.isPro {
                                    proBadge
                                } else if cloudKitSyncMonitor.isSyncing {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(purchaseManager.isPro)
                    }

                    SettingsCard(header: "Data") {
                        Button {
                            if purchaseManager.isPro {
                                exportDebts()
                            } else {
                                isShowingPaywall = true
                            }
                        } label: {
                            SettingsRow(icon: "square.and.arrow.up.on.square.fill", iconColor: AppTheme.primary, title: "Export Debts (CSV)", subtitle: "Opens directly in Excel") {
                                proOrChevron()
                            }
                        }
                    }

                    SettingsCard {
                        Button("Restore Purchase") {
                            Task { await purchaseManager.restorePurchases() }
                        }
                        .foregroundStyle(AppTheme.primary)
                        .padding(.vertical, 10)
                    }

                    SettingsCard(header: "About") {
                        aboutLink(icon: "doc.text.fill", title: "Terms of Use", url: AppDefaults.termsOfUseURL)
                        SettingsRowDivider()
                        aboutLink(icon: "shield.fill", title: "Privacy Policy", url: AppDefaults.privacyPolicyURL)
                        SettingsRowDivider()
                        aboutLink(icon: "star.fill", title: "Rate the App", url: AppDefaults.writeReviewURL)
                        SettingsRowDivider()
                        aboutLink(icon: "square.grid.2x2.fill", title: "More Apps", url: AppDefaults.otherAppsURL)
                        SettingsRowDivider()
                        aboutLink(icon: "envelope.fill", title: "Contact Developer", url: "mailto:\(AppDefaults.email)")
                    }
                }
                .padding()
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $isShowingPaywall) {
                PaywallView(onClose: { isShowingPaywall = false })
            }
            .sheet(isPresented: $isShowingCurrencyPicker) {
                DisplayCurrencyPickerView(selectedCurrency: $displayCurrency)
            }
            .sheet(isPresented: $isShowingExportSheet) {
                if let exportFileURL {
                    ShareSheet(items: [exportFileURL])
                }
            }
            .task {
                await refreshNotificationsStatus()
            }
            .alert("Notifications Are Off", isPresented: $isShowingNotificationsDeniedAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Notifications for Debtors List Pro are turned off. Enable them in iOS Settings to receive reminders.")
            }
        }
    }


    private var proHero: some View {
        HStack(spacing: 14) {
            Image("crown-glow")
                .resizable()
                .frame(width: 64, height: 64)
                .background(AppTheme.surface)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(purchaseManager.isPro ? "You're using Pro" : "You're using Free")
                    .foregroundStyle(AppTheme.textPrimary)
                Text(purchaseManager.isPro ? "Thanks for supporting the app!" : "Upgrade to unlock all features and insights.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer(minLength: 8)

            if purchaseManager.isPro {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(AppTheme.success)
            } else {
                Button("Upgrade") { isShowingPaywall = true }
                    .buttonStyle(.borderedProminent)
                    .foregroundStyle(.black)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .tint(AppTheme.gold)
            }
        }
        .padding(14)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }


    private func proOrChevron() -> some View {
        Group {
            if purchaseManager.isPro {
                Image(systemName: "chevron.right").foregroundStyle(AppTheme.textSecondary)
            } else {
                proBadge
            }
        }
    }

    
    private var proBadge: some View {
        Text("PRO")
            .font(.caption2.bold())
            .foregroundStyle(AppTheme.gold)
    }
    

    private func aboutLink(icon: String, title: String, url: String, iconColor: Color = AppTheme.iconNeutral) -> some View {
        Group {
            if let linkURL = URL(string: url) {
                Link(destination: linkURL) {
                    SettingsRow(icon: icon, iconColor: iconColor, title: title) {
                        Image(systemName: "chevron.right").foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
    }

    
    private var syncSubtitle: String {
        if !purchaseManager.isPro {
            return "Keep your data available on all devices"
        } else if cloudKitSyncMonitor.isSyncing {
            return "Syncing…"
        } else if syncNeedsRestart {
            return "Restart the app to activate"
        } else if let lastSyncedAt = cloudKitSyncMonitor.lastSyncedAt {
            return "Last synced: \(lastSyncedAt.formatted(date: .abbreviated, time: .shortened))"
        } else {
            return "Waiting for iCloud…"
        }
    }

    
    private var reminderSummaryText: String {
        let weekdaySymbols = Calendar.current.weekdaySymbols
        let weekdayName = weekdaySymbols.indices.contains(reminderWeekday - 1) ? weekdaySymbols[reminderWeekday - 1] : "Friday"
        var components = DateComponents()
        components.hour = reminderHour
        let time = Calendar.current.date(from: components)?.formatted(date: .omitted, time: .shortened) ?? "6:00 PM"
        return "Every \(weekdayName) at \(time)"
    }
    

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = reminderHour
                return Calendar.current.date(from: components) ?? .now
            },
            set: { newDate in
                reminderHour = Calendar.current.component(.hour, from: newDate)
                Task {
                    await NotificationManager.shared.scheduleWeeklyReminder(weekday: reminderWeekday, hour: reminderHour)
                }
            }
        )
    }

    private func refreshNotificationsStatus() async {
        let status = await NotificationManager.shared.currentAuthorizationStatus()
        notificationsEnabled = (status == .authorized || status == .provisional)
    }


    private func handleNotificationsToggle(_ isOn: Bool) {
        guard isOn else { return }

        Task {
            let status = await NotificationManager.shared.currentAuthorizationStatus()
            switch status {
            case .notDetermined:
                let granted = await NotificationManager.shared.requestAuthorization()
                notificationsEnabled = granted
                if granted {
                    await NotificationManager.shared.scheduleWeeklyReminder(weekday: reminderWeekday, hour: reminderHour)
                }
            case .denied:
                notificationsEnabled = false
                isShowingNotificationsDeniedAlert = true
            default:
                break
            }
        }
    }

    private func exportDebts() {
        exportFileURL = ExportService.writeCSVFile(for: allDebtors)
        isShowingExportSheet = exportFileURL != nil
    }
}
