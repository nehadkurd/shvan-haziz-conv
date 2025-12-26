import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.90, green: 0.12, blue: 0.20) // Netflix-ish red
    static let bg = Color.black
    static let card = Color.white.opacity(0.06)
    static let stroke = Color.white.opacity(0.10)
    static let muted = Color.white.opacity(0.70)
    static let muted2 = Color.white.opacity(0.55)
}

extension View {
    func neonCard() -> some View {
        self
            .padding(16)
            .background(AppTheme.card)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(AppTheme.stroke, lineWidth: 1)
            )
    }
}
