

import SwiftUI

struct ReminderTemplateEditorView: View {

    @Binding var template: String

    var body: some View {
        Form {
            Section("Message") {
                TextField("Reminder message", text: $template, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Reminder Template")
        .navigationBarTitleDisplayMode(.inline)
    }
}
