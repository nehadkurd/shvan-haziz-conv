import Foundation
import PDFKit
import UIKit

enum FileKind: String {
    case word, powerpoint, pdf, rtf, txt, unknown
}

enum TargetFormat: String, CaseIterable {
    case pdf
    case txt
    case rtf
}

struct ConversionCapability {
    let kind: FileKind
    let possibleTargets: [TargetFormat]
    let note: String
}

final class ConversionEngine {

    static func detectKind(url: URL) -> FileKind {
        let ext = url.pathExtension.lowercased()

        // Word
        if ["docx","doc","docm","dotx","dotm"].contains(ext) { return .word }

        // PowerPoint
        if ["pptx","ppt","pptm","potx","potm","ppsx","ppsm"].contains(ext) { return .powerpoint }

        if ext == "pdf" { return .pdf }
        if ext == "rtf" { return .rtf }
        if ext == "txt" { return .txt }
        return .unknown
    }

    static func capability(for kind: FileKind) -> ConversionCapability {
        switch kind {
        case .txt:
            return .init(kind: kind, possibleTargets: [.rtf, .pdf], note: "Offline: txt → rtf/pdf supported.")
        case .rtf:
            return .init(kind: kind, possibleTargets: [.txt, .pdf], note: "Offline: rtf → txt/pdf supported.")
        case .pdf:
            return .init(kind: kind, possibleTargets: [.txt], note: "Offline: pdf → txt (best-effort) supported.")
        case .word:
            return .init(kind: kind, possibleTargets: [], note: "Offline Office conversion needs a conversion engine. Import/preview supported.")
        case .powerpoint:
            return .init(kind: kind, possibleTargets: [], note: "Offline Office conversion needs a conversion engine. Import/preview supported.")
        case .unknown:
            return .init(kind: kind, possibleTargets: [], note: "Unknown type.")
        }
    }

    // MARK: - Core conversions (offline, no servers)

    static func convert(inputURL: URL, to target: TargetFormat) throws -> URL {
        let kind = detectKind(url: inputURL)
        switch (kind, target) {
        case (.txt, .rtf):
            return try txtToRtf(inputURL: inputURL)
        case (.txt, .pdf):
            return try textLikeToPdf(inputURL: inputURL, kind: .txt)
        case (.rtf, .txt):
            return try rtfToTxt(inputURL: inputURL)
        case (.rtf, .pdf):
            return try textLikeToPdf(inputURL: inputURL, kind: .rtf)
        case (.pdf, .txt):
            return try pdfToTxt(inputURL: inputURL)
        default:
            throw NSError(domain: "ConversionEngine", code: 1, userInfo: [NSLocalizedDescriptionKey: "Conversion not supported offline for this type."])
        }
    }

    private static func outputURL(from inputURL: URL, ext: String) -> URL {
        let base = inputURL.deletingPathExtension().lastPathComponent
        let dir = FileManager.default.temporaryDirectory
        return dir.appendingPathComponent("\(base)-converted.\(ext)")
    }

    private static func txtToRtf(inputURL: URL) throws -> URL {
        let text = try String(contentsOf: inputURL, encoding: .utf8)
        let attr = NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 16)
        ])
        let data = try attr.data(from: NSRange(location: 0, length: attr.length),
                                 documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        let out = outputURL(from: inputURL, ext: "rtf")
        try data.write(to: out, options: .atomic)
        return out
    }

    private static func rtfToTxt(inputURL: URL) throws -> URL {
        let data = try Data(contentsOf: inputURL)
        let attr = try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.rtf],
                                          documentAttributes: nil)
        let out = outputURL(from: inputURL, ext: "txt")
        try attr.string.data(using: .utf8)?.write(to: out, options: .atomic)
        return out
    }

    private static func textLikeToPdf(inputURL: URL, kind: FileKind) throws -> URL {
        let attr: NSAttributedString

        switch kind {
        case .txt:
            let text = try String(contentsOf: inputURL, encoding: .utf8)
            attr = NSAttributedString(string: text, attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ])
        case .rtf:
            let data = try Data(contentsOf: inputURL)
            attr = try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.rtf],
                                          documentAttributes: nil)
        default:
            throw NSError(domain: "ConversionEngine", code: 2, userInfo: [NSLocalizedDescriptionKey: "Not text-like."])
        }

        let out = outputURL(from: inputURL, ext: "pdf")

        let page = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter-ish
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let inset = page.insetBy(dx: 36, dy: 36)
            attr.draw(in: inset)
        }
        try data.write(to: out, options: .atomic)
        return out
    }

    private static func pdfToTxt(inputURL: URL) throws -> URL {
        guard let doc = PDFDocument(url: inputURL) else {
            throw NSError(domain: "ConversionEngine", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot open PDF."])
        }
        var all = ""
        for i in 0..<doc.pageCount {
            if let page = doc.page(at: i), let s = page.string {
                all += s
                all += "\n"
            }
        }
        let out = outputURL(from: inputURL, ext: "txt")
        try all.data(using: .utf8)?.write(to: out, options: .atomic)
        return out
    }
}
