import Foundation

struct PickedFile {
    let url: URL
    var extLower: String { url.pathExtension.lowercased() }
    var friendlyType: String {
        let e = extLower
        return e.isEmpty ? "Unknown" : e.uppercased()
    }
}

enum OutputFormat: String, CaseIterable, Identifiable {
    case pdf, txt, rtf, md, doc, docx, odt, pages

    var id: String { rawValue }
    var fileExtension: String { rawValue }

    var label: String {
        switch self {
        case .pdf: return "PDF (.pdf)"
        case .txt: return "Plain Text (.txt)"
        case .rtf: return "Rich Text (.rtf)"
        case .md: return "Markdown (.md)"
        case .doc: return "Word (.doc) (online)"
        case .docx: return "Word (.docx) (online)"
        case .odt: return "OpenDocument (.odt) (online)"
        case .pages: return "Apple Pages (.pages) (online)"
        }
    }

    var note: String {
        switch self {
        case .pdf:
            return "Local: TXT/MD/RTF → PDF. Other inputs need online endpoint."
        case .txt:
            return "Local: RTF → TXT."
        case .rtf:
            return "Local: TXT/MD → RTF."
        case .md:
            return "Local: TXT → MD."
        case .doc, .docx, .odt, .pages:
            return "Online endpoint required."
        }
    }
}
