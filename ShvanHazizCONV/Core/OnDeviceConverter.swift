import Foundation
import PDFKit
import UIKit

enum ConversionError: LocalizedError {
    case unsupported
    case cannotOpen
    case writeFailed

    var errorDescription: String? {
        switch self {
        case .unsupported: return "This conversion isn’t available on-device yet."
        case .cannotOpen: return "We couldn’t open this file."
        case .writeFailed: return "We couldn’t save the converted file."
        }
    }
}

final class OnDeviceConverter {

    static func convert(inputURL: URL, inputFamily: FileFamily, to target: TargetFormat) throws -> URL {
        switch (inputFamily, target) {
        case (.txt, .rtf):
            return try txtToRtf(inputURL)
        case (.txt, .pdf):
            return try textLikeToPdf(inputURL, isRTF: false)
        case (.rtf, .txt):
            return try rtfToTxt(inputURL)
        case (.rtf, .pdf):
            return try textLikeToPdf(inputURL, isRTF: true)
        case (.pdf, .txt):
            return try pdfToTxt(inputURL)
        default:
            throw ConversionError.unsupported
        }
    }

    private static func outputURL(for inputURL: URL, ext: String) -> URL {
        let base = inputURL.deletingPathExtension().lastPathComponent
        return FileManager.default.temporaryDirectory.appendingPathComponent("\(base)-converted.\(ext)")
    }

    private static func txtToRtf(_ url: URL) throws -> URL {
        let text = try String(contentsOf: url, encoding: .utf8)
        let attr = NSAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 16)
        ])
        let data = try attr.data(from: NSRange(location: 0, length: attr.length),
                                 documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        let out = outputURL(for: url, ext: "rtf")
        try data.write(to: out, options: .atomic)
        return out
    }

    private static func rtfToTxt(_ url: URL) throws -> URL {
        let data = try Data(contentsOf: url)
        let attr = try NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.rtf],
            documentAttributes: nil
        )
        let out = outputURL(for: url, ext: "txt")
        guard let d = attr.string.data(using: .utf8) else { throw ConversionError.writeFailed }
        try d.write(to: out, options: .atomic)
        return out
    }

    private static func textLikeToPdf(_ url: URL, isRTF: Bool) throws -> URL {
        let attr: NSAttributedString
        if isRTF {
            let data = try Data(contentsOf: url)
            attr = try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
            )
        } else {
            let text = try String(contentsOf: url, encoding: .utf8)
            attr = NSAttributedString(string: text, attributes: [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.label
            ])
        }

        let out = outputURL(for: url, ext: "pdf")
        let page = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: page)

        let pdf = renderer.pdfData { ctx in
            ctx.beginPage()
            let inset = page.insetBy(dx: 36, dy: 36)
            attr.draw(in: inset)
        }

        try pdf.write(to: out, options: .atomic)
        return out
    }

    private static func pdfToTxt(_ url: URL) throws -> URL {
        guard let doc = PDFDocument(url: url) else { throw ConversionError.cannotOpen }
        var all = ""
        for i in 0..<doc.pageCount {
            if let page = doc.page(at: i), let s = page.string {
                all += s + "\n"
            }
        }
        let out = outputURL(for: url, ext: "txt")
        guard let d = all.data(using: .utf8) else { throw ConversionError.writeFailed }
        try d.write(to: out, options: .atomic)
        return out
    }
}
