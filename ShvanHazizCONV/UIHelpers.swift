import SwiftUI

extension View {
    func card() -> some View {
        self
            .padding(14)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )
    }
}

struct PickedFile {
    let url: URL
    var friendlyType: String {
        let ext = url.pathExtension.lowercased()
        if ext.isEmpty { return "Unknown type" }
        return ext.uppercased()
    }
}
