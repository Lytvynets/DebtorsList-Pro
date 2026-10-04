

import Foundation

enum ExportService {

    static func csv(for debtors: [Debtor]) -> String {
        var lines = ["Name,Direction,Original Amount,Currency,Paid,Remaining,Status,Due Date,Created,Notes"]

        for debtor in debtors.sorted(by: { $0.createdAt < $1.createdAt }) {
            let unit = debtor.unitType == .currency ? (debtor.currencyCode ?? "") : (debtor.itemName ?? "")
            let dueDateText = debtor.dueDate?.formatted(date: .numeric, time: .omitted) ?? ""
            let createdText = debtor.createdAt.formatted(date: .numeric, time: .omitted)

            let fields = [
                debtor.name,
                debtor.direction == .owedToMe ? "They owe me" : "I owe",
                String(debtor.originalAmount),
                unit,
                String(debtor.totalPaid),
                String(debtor.remainingAmount),
                debtor.isSettled ? "Closed" : "Active",
                dueDateText,
                createdText,
                debtor.notes ?? ""
            ]

            lines.append(fields.map(csvField).joined(separator: ","))
        }

        return lines.joined(separator: "\n")
    }


    static func writeCSVFile(for debtors: [Debtor]) -> URL? {
        let csvText = csv(for: debtors)
        let fileName = "Debtors-\(fileTimestamp()).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvText.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            print("ExportService: failed to write CSV — \(error.localizedDescription)")
            return nil
        }
    }

    private static func fileTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter.string(from: .now)
    }


    private static func csvField(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"") || value.contains("\n") else {
            return value
        }
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(escaped)\""
    }
}
