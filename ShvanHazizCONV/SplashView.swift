import SwiftUI

struct SplashView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.black,
                    Color.black.opacity(0.95),
                    Color(red: 0.08, green: 0.08, blue: 0.10)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.55), radius: 18, y: 10)
                    .scaleEffect(pulse ? 1.03 : 0.98)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulse)

                Text("shvan haziz CONV")
                    .font(.system(size: 28, weight: .heavy))
                    .tracking(0.5)

                Text("Simple. Heavy. Real.")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 24)
        }
        .onAppear { pulse = true }
    }
}
