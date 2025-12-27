import SwiftUI

/// Phase 4: Responsive helpers.
/// Works on iPhone SE -> Pro Max -> iPad -> Split View.
struct AdaptiveLayout {
    static func columns(for width: CGFloat) -> [GridItem] {
        if width >= 900 {
            return Array(repeating: GridItem(.flexible(), spacing: 14), count: 4)
        } else if width >= 600 {
            return Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)
        } else if width >= 380 {
            return Array(repeating: GridItem(.flexible(), spacing: 14), count: 2)
        } else {
            return [GridItem(.flexible(), spacing: 14)]
        }
    }
}
