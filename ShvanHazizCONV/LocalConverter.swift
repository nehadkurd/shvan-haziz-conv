import Foundation
import UniformTypeIdentifiers
import PDFKit
import UIKit

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
            return "Local: TXT/MD/RTF → PDF supported. Other inputs require online endpoint."
        case .txt:
            return "Local: RTF → TXT supported."
        case .rtf:
            return "Local: TXT/MD → RTF supported."
        case .md:
            return "Local: TXT → MD (keeps text)."
        case .doc, .docx, .odt, .pages:
            return "Online endpoint required."
        }
    }
}

struct LocalConverter {
    static func convert(inputURL: URL, inputData: Data, to out: OutputFormat) throws -> URL? {
        let ext = inputURL.pathExtension.lowercased()

        // Determine basic text from inputs we can read locally
        func readString() throws -> String? {
            if ext == "txt" || ext == "md" {
                return String(data: inputData, encoding: .utf8) ?? String(data: inputData, encoding: .utf16)
            }
            if ext == "rtf" {
                let attr = try NSAttributedString(data: inputData, options: [
                    .documentType: NSAttributedString.DocumentType.rtf
                ], documentAttributes: nil)
                return attr.string
            }
            return nil
        }

        // Local TXT/MD/RTF -> PDF
        if out == .pdf {
            if let s = try readString() {
                return try makePDF(from: s, suggestedName: inputURL.deletingPathExtension().lastPathComponent + ".pdf")
            }
            return nil
        }

        // Local RTF -> TXT
        if out == .txt && ext == "rtf" {
            let attr = try NSAttributedString(data: inputData, options: [
                .documentType: NSAttributedString.DocumentType.rtf
            ], documentAttributes: nil)
            return try writeTemp(data: Data(attr.string.utf8), filename: inputURL.deletingPathExtension().lastPathComponent + ".txt")
        }

        // Local TXT/MD -> RTF
        if out == .rtf && (ext == "txt" || ext == "md") {
            guard let s = String(data: inputData, encoding: .utf8) ?? String(data: inputData, encoding: .utf16) else { return nil }
            let attr = NSAttributedString(string: s)
            let rtf = try attr.data(from: NSRange(location: 0, length: attr.length),
                                    documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
            return try writeTemp(data: rtf, filename: inputURL.deletingPathExtension().lastPathComponent + ".rtf")
        }

        // Local TXT -> MD (keep as text)
        if out == .md && ext == "txt" {
            guard let s = String(data: inputData, encoding: .utf8) ?? String(data: inputData, encoding: .utf16) else { return nil }
            return try writeTemp(data: Data(s.utf8), filename: inputURL.deletingPathExtension().lastPathComponent + ".md")
        }

        // Otherwise: not supported locally
        return nil
    }

    private static func makePDF(from text: String, suggestedName: String) throws -> URL {
        // Render simple PDF using UIGraphicsPDFRenderer
        let fmt = UIGraphicsPDFRendererFormat()
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter points
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: fmt)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .paragraphStyle: paragraphStyle
            ]
            let inset: CGFloat = 36
            let drawRect = pageRect.insetBy(dx: inset, dy: inset)
            (text as NSString).draw(in: drawRect, withAttributes: attrs)
        }

        return try writeTemp(data: data, filename: suggestedName)
    }

    private static func writeTemp(data: Data, filename: String) throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("shvanhazizconv", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let outURL = dir.appendingPathComponent(filename)
        try data.write(to: outURL, options: .atomic)
        return outURL
    }
}
