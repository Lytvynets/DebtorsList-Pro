

import Foundation
import CoreData
import Combine

@MainActor
final class CloudKitSyncMonitor: ObservableObject {

    @Published private(set) var isSyncing = false
    @Published private(set) var lastSyncedAt: Date?
    @Published private(set) var lastSyncError: String?

    private let lastSyncedAtKey = "cloudKitLastSyncedAt"
    private var observer: NSObjectProtocol?

    init() {
        lastSyncedAt = UserDefaults.standard.object(forKey: lastSyncedAtKey) as? Date

        observer = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                as? NSPersistentCloudKitContainer.Event else { return }
            Task { @MainActor [weak self] in
                self?.handle(event)
            }
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func handle(_ event: NSPersistentCloudKitContainer.Event) {
        guard event.endDate != nil else {
            isSyncing = true
            return
        }

        isSyncing = false

        if let error = event.error {
            lastSyncError = error.localizedDescription
        } else {
            lastSyncError = nil
            lastSyncedAt = event.endDate
            UserDefaults.standard.set(event.endDate, forKey: lastSyncedAtKey)
        }
    }
}
