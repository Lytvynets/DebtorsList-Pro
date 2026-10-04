

import SwiftUI

struct PrimaryButton: View {

    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.buttonLabel)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .background(AppTheme.primary)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .opacity(isDisabled ? 0.5 : 1)
        .disabled(isDisabled || isLoading)
    }
}
