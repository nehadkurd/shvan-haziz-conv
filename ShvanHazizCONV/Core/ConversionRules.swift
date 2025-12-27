import Foundation

final class ConversionRules {

    static func targets(for family: FileFamily) -> [ConversionTarget] {
        switch family {

        case .txt:
            return [
                .init(id: "txt->rtf", format: .rtf, mode: .onDevice,
                      title: "RTF", subtitle: "Formatted text", systemIcon: "textformat"),
                .init(id: "txt->pdf", format: .pdf, mode: .onDevice,
                      title: "PDF", subtitle: "Share-ready document", systemIcon: "doc.richtext"),
            ]

        case .rtf:
            return [
                .init(id: "rtf->txt", format: .txt, mode: .onDevice,
                      title: "TXT", subtitle: "Plain text", systemIcon: "doc.plaintext"),
                .init(id: "rtf->pdf", format: .pdf, mode: .onDevice,
                      title: "PDF", subtitle: "Clean printable export", systemIcon: "doc.richtext"),
            ]

        case .pdf:
            return [
                .init(id: "pdf->txt", format: .txt, mode: .onDevice,
                      title: "TXT", subtitle: "Best-effort text extract", systemIcon: "doc.plaintext"),
            ]

        case .word:
            return [
                .init(id: "word->pdf", format: .pdf, mode: .secureCloud,
                      title: "PDF", subtitle: "Secure conversion (content only)", systemIcon: "lock.doc"),
                .init(id: "word->txt", format: .txt, mode: .secureCloud,
                      title: "TXT", subtitle: "Secure conversion (content only)", systemIcon: "lock.doc"),
            ]

        case .powerpoint:
            return [
                .init(id: "ppt->pdf", format: .pdf, mode: .secureCloud,
                      title: "PDF", subtitle: "Slides as a document", systemIcon: "lock.doc"),
                .init(id: "ppt->images", format: .images, mode: .secureCloud,
                      title: "Images", subtitle: "Each slide as PNG", systemIcon: "lock.doc"),
                .init(id: "ppt->mp4", format: .mp4, mode: .secureCloud,
                      title: "MP4", subtitle: "Slideshow video", systemIcon: "lock.doc"),
            ]

        case .unknown:
            return []
        }
    }

    static func note(for family: FileFamily) -> String {
        switch family {
        case .txt, .rtf, .pdf:
            return "On-device conversion. Fast, private."
        case .word, .powerpoint:
            return "Cloud conversion required for this format. Macros are never executed."
        case .unknown:
            return "This file type isn’t supported yet."
        }
    }
}
