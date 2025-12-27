import UniformTypeIdentifiers

/// Phase 3: Smart format engine.
/// - Suggests possible outputs based on input
/// - Marks which ones are offline vs online
struct FormatRegistry {

    struct OutputOption: Identifiable {
        let id: String
        let type: UTType
        let title: String
        let isOffline: Bool
    }

    static func detectInputType(for url: URL) -> UTType {
        let ext = url.pathExtension.lowercased()
        if let t = UTType(filenameExtension: ext) { return t }
        return .data
    }

    static func outputOptions(for input: UTType) -> [OutputOption] {
        // Offline-capable options
        var opts: [OutputOption] = []

        if input == .pdf {
            opts.append(OutputOption(id: "txt", type: .plainText, title: "Text (.txt)", isOffline: true))
            // Online options
            opts.append(OutputOption(id: "docx", type: UTType("org.openxmlformats.wordprocessingml.document") ?? .data, title: "Word (.docx) — Online", isOffline: false))
        }

        if input == .plainText {
            opts.append(OutputOption(id: "pdf", type: .pdf, title: "PDF (.pdf)", isOffline: true))
            opts.append(OutputOption(id: "rtf", type: .rtf, title: "RTF (.rtf)", isOffline: true))
        }

        if input == .markdown {
            opts.append(OutputOption(id: "pdf", type: .pdf, title: "PDF (.pdf)", isOffline: true))
        }

        if input == .rtf {
            opts.append(OutputOption(id: "txt", type: .plainText, title: "Text (.txt)", isOffline: true))
        }

        if input.conforms(to: .image) {
            opts.append(OutputOption(id: "pdf", type: .pdf, title: "PDF (.pdf)", isOffline: true))
        }

        // Online common: DOC/DOCX/ODT/Pages -> PDF
        let docx = UTType("org.openxmlformats.wordprocessingml.document") ?? .data
        let doc  = UTType("com.microsoft.word.doc") ?? .data
        let odt  = UTType("org.oasis-open.opendocument.text") ?? .data
        let pages = UTType("com.apple.iwork.pages.pages") ?? .data

        if input == docx || input == doc || input == odt || input == pages {
            opts.append(OutputOption(id: "pdf_online", type: .pdf, title: "PDF (.pdf) — Online", isOffline: false))
        }

        if opts.isEmpty {
            // Default: allow online-only "convert to PDF" (server required)
            opts.append(OutputOption(id: "pdf_online_fallback", type: .pdf, title: "PDF (.pdf) — Online", isOffline: false))
        }

        return opts
    }
}
