import Foundation
import PDFKit
import UIKit
import UniformTypeIdentifiers

/// Phase 1: Real offline conversions using native iOS frameworks.
/// Supported offline:
/// - PDF -> TXT
/// - TXT/MD -> PDF
/// - RTF -> TXT
/// - TXT -> RTF
/// - Image -> PDF
struct LocalConverter {

    static func canHandle(input: UTType, output: UTType) -> Bool {
        if input == .pdf && output == .plainText { return true }
        if (input == .plainText || input == .markdown) && output == .pdf { return true }
        if input == .rtf && output == .plainText { return true }
        if input == .plainText && output == .rtf { return true }
        if input.conforms(to: .image) && output == .pdf { return true }
        return false
    }

    static func convert(inputURL: URL, input: UTType, output: UTType) throws -> URL {
        if input == .pdf && output == .plainText {
            return try convertPDFToText(inputURL)
        }
        if (input == .plainText || input == .markdown) && output == .pdf {
            return try convertTextToPDF(inputURL)
        }
        if input == .rtf && output == .plainText {
            return try convertRTFToText(inputURL)
        }
        if input == .plainText && output == .rtf {
            return try convertTextToRTF(inputURL)
        }
        if input.conforms(to: .image) && output == .pdf {
            return try convertImageToPDF(inputURL)
        }
        throw NSError(domain: "LocalConverter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Offline conversion not supported."])
    }

    private static func convertPDFToText(_ inputURL: URL) throws -> URL {
        guard let pdf = PDFDocument(url: inputURL) else {
            throw NSError(domain: "LocalConverter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid PDF file."])
        }
        let text = (0..<pdf.pageCount)
            .compactMap { pdf.page(at: $0)?.string }
            .joined(separator: "\n")

        let out = temp("output.txt")
        try text.write(to: out, atomically: true, encoding: .utf8)
        return out
    }

    private static func convertTextToPDF(_ inputURL: URL) throws -> URL {
        let text = try String(contentsOf: inputURL, encoding: .utf8)
        let out = temp("output.pdf")

        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        try renderer.writePDF(to: out) { ctx in
            ctx.beginPage()
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .paragraphStyle: paragraphStyle
            ]
            let inset: CGFloat = 24
            let drawRect = pageRect.insetBy(dx: inset, dy: inset)
            (text as NSString).draw(in: drawRect, withAttributes: attrs)
        }

        return out
    }

    private static func convertRTFToText(_ inputURL: URL) throws -> URL {
        let attr = try NSAttributedString(url: inputURL, options: [:], documentAttributes: nil)
        let out = temp("output.txt")
        try attr.string.write(to: out, atomically: true, encoding: .utf8)
        return out
    }

    private static func convertTextToRTF(_ inputURL: URL) throws -> URL {
        let text = try String(contentsOf: inputURL, encoding: .utf8)
        let attr = NSAttributedString(string: text)
        let data = try attr.data(
            from: NSRange(location: 0, length: attr.length),
            documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
        )
        let out = temp("output.rtf")
        try data.write(to: out)
        return out
    }

    private static func convertImageToPDF(_ inputURL: URL) throws -> URL {
        let data = try Data(contentsOf: inputURL)
        guard let img = UIImage(data: data) else {
            throw NSError(domain: "LocalConverter", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid image file."])
        }

        let out = temp("output.pdf")
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        try renderer.writePDF(to: out) { ctx in
            ctx.beginPage()
            let maxRect = pageRect.insetBy(dx: 24, dy: 24)
            let fitted = AVMakeRect(aspectRatio: img.size, insideRect: maxRect)
            img.draw(in: fitted)
        }
        return out
    }

    private static func temp(_ name: String) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(name)
    }
}
