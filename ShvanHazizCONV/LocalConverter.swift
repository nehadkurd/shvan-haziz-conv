import Foundation
import UIKit

struct LocalConverter {
    static func convert(inputURL: URL, inputData: Data, to out: OutputFormat) throws -> URL? {
        let ext = inputURL.pathExtension.lowercased()

        func readString() throws -> String? {
            if ext == "txt" || ext == "md" {
                return String(data: inputData, encoding: .utf8) ?? String(data: inputData, encoding: .utf16)
            }
            if ext == "rtf" {
                let attr = try NSAttributedString(
                    data: inputData,
                    options: [.documentType: NSAttributedString.DocumentType.rtf],
                    documentAttributes: nil
                )
                return attr.string
            }
            return nil
        }

        // TXT/MD/RTF -> PDF (UIKit renderer)
        if out == .pdf {
            if let s = try readString() {
                return try makePDF(from: s, suggestedName: inputURL.deletingPathExtension().lastPathComponent + ".pdf")
            }
            return nil
        }

        // RTF -> TXT
        if out == .txt && ext == "rtf" {
            let attr = try NSAttributedString(
                data: inputData,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
            )
            return try writeTemp(data: Data(attr.string.utf8),
                                 filename: inputURL.deletingPathExtension().lastPathComponent + ".txt")
        }

        // TXT/MD -> RTF
        if out == .rtf && (ext == "txt" || ext == "md") {
            guard let s = String(data: inputData, encoding: .utf8) ?? String(data: inputData, encoding: .utf16) else { return nil }
            let attr = NSAttributedString(string: s)
            let rtf = try attr.data(from: NSRange(location: 0, length: attr.length),
                                    documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
            return try writeTemp(data: rtf,
                                 filename: inputURL.deletingPathExtension().lastPathComponent + ".rtf")
        }

        // TXT -> MD
        if out == .md && ext == "txt" {
            guard let s = String(data: inputData, encoding: .utf8) ?? String(data: inputData, encoding: .utf16) else { return nil }
            return try writeTemp(data: Data(s.utf8),
                                 filename: inputURL.deletingPathExtension().lastPathComponent + ".md")
        }

        return nil
    }

    private static func makePDF(from text: String, suggestedName: String) throws -> URL {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .paragraphStyle: paragraphStyle
            ]

            (text as NSString).draw(in: pageRect.insetBy(dx: 36, dy: 36), withAttributes: attrs)
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
