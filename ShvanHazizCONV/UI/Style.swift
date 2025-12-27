import SwiftUI

enum UIStyle {
    static let bgTop = Color.black
    static let bgBottom = Color(.systemGray6)
    static let cardRadius: CGFloat = 22
}

struct PremiumBackground: View {
    var body: some View {
        LinearGradient(colors: [UIStyle.bgTop, UIStyle.bgBottom],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct PremiumCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let content: Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            content
        }
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.33))
        .clipShape(RoundedRectangle(cornerRadius: UIStyle.cardRadius, style: .continuous))
        .shadow(radius: 18, y: 10)
    }
}

struct PrimaryCTAButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                Text(title).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.red.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .foregroundStyle(.white)
    }
}

struct SoftButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                Text(title).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.14))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .foregroundStyle(.white)
    }
}
