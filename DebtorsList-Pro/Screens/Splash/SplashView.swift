

import SwiftUI

struct SplashView: View {

    let onFinish: () -> Void

    @State private var iconScale: CGFloat = 0.85
    @State private var iconOpacity: Double = 0
    @State private var titleOpacity: Double = 0

    var body: some View {
        ZStack {
            AppTheme.splashGradient.ignoresSafeArea()

            VStack(spacing: 16) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .foregroundStyle(.white)
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)

                (Text("Debtors List ").foregroundColor(.white) + Text("Pro").foregroundColor(Color(hex: "C4B5FD")))
                    .font(.screenTitle)
                    .opacity(titleOpacity)
            }
        }
        .onAppear(perform: playAnimation)
    }

    private func playAnimation() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
            iconScale = 1.0
            iconOpacity = 1.0
        }
        withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
            titleOpacity = 1.0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            onFinish()
        }
    }
}
