import Foundation
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
            return "Local supported: TXT/MD/RTF → PDF. Others need online endpoint."
        case .txt:
            return "Local supported: RTF → TXT."
        case .rtf:
            return "Local supported: TXT/MD → RTF."
        case .md:
            return "Local supported: TXT → MD."
        case .doc, .docx, .odt, .pages:
            return "Online endpoint required."
        }
    }
}

struct LocalConverter {
    static func convert(inputURL: URL, inputData: Data, to out: OutputFormat) throws -> URL? {
        let ext = inputURL.pathExtension.lowercased()

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

        if out == .pdf {
            if let s = try readString() {
                return try makePDF(from: s, suggestedName: inputURL.deletingPathExtension().lastPathComponent + ".pdf")
            }
            return nil
        }

        if out == .txt && ext == "rtf" {
            let attr = try NSAttributedString(data: inputData, options: [
                .documentType: NSAttributedString.DocumentType.rtf
            ], documentAttributes: nil)
            return try writeTemp(data: Data(attr.string.utf8), filename: inputURL.deletingPathExtension().lastPathComponent + ".txt")
        }

        if out == .rtf && (ext == "txt" || ext == "md") {
            guard let s = String(data: inputData, encoding: .utf8) ?? String(data: inputData, encoding: .utf16) else { return nil }
            let attr = NSAttributedString(string: s)
            let rtf = try attr.data(from: NSRange(location: 0, length: attr.length),
                                    documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
            return try writeTemp(data: rtf, filename: inputURL.deletingPathExtension().lastPathComponent + ".rtf")
        }

        if out == .md && ext == "txt" {
            guard let s = String(data: inputData, encoding: .utf8) ?? String(data: inputData, encoding: .utf16) else { return nil }
            return try writeTemp(data: Data(s.utf8), filename: inputURL.deletingPathExtension().lastPathComponent + ".md")
        }

        return nil
    }

    private static func makePDF(from text: String, suggestedName: String) throws -> URL {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let para = NSMutableParagraphStyle()
            para.lineBreakMode = .byWordWrapping

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .paragraphStyle: para
            ]
            let drawRect = pageRect.insetBy(dx: 36, dy: 36)
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
