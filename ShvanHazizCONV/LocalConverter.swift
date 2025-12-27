import Foundation
import PDFKit
import UIKit
import UniformTypeIdentifiers

struct LocalConverter {

    static func canHandle(input: UTType, output: UTType) -> Bool {
        if input == .pdf && output == .plainText { return true }
        if input == .plainText && output == .pdf { return true }
        if input == .rtf && output == .plainText { return true }
        if input == .plainText && output == .rtf { return true }
        if input.conforms(to: .image) && output == .pdf { return true }
        return false
    }

    static func convert(inputURL: URL, input: UTType, output: UTType) throws -> URL {

        if input == .pdf && output == .plainText {
            let pdf = PDFDocument(url: inputURL)!
            let text = (0..<pdf.pageCount)
                .compactMap { pdf.page(at: $0)?.string }
                .joined(separator: "\n")

            let out = temp("output.txt")
            try text.write(to: out, atomically: true, encoding: .utf8)
            return out
        }

        if input == .plainText && output == .pdf {
            let text = try String(contentsOf: inputURL)
            let out = temp("output.pdf")

            let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
            try renderer.writePDF(to: out) { ctx in
                ctx.beginPage()
                text.draw(
                    in: CGRect(x: 20, y: 20, width: 572, height: 752),
                    withAttributes: [.font: UIFont.systemFont(ofSize: 14)]
                )
            }
            return out
        }

        if input == .rtf && output == .plainText {
            let attr = try NSAttributedString(
                url: inputURL,
                options: [:],
                documentAttributes: nil
            )
            let out = temp("output.txt")
            try attr.string.write(to: out, atomically: true, encoding: .utf8)
            return out
        }

        if input == .plainText && output == .rtf {
            let text = try String(contentsOf: inputURL)
            let attr = NSAttributedString(string: text)
            let data = try attr.data(
                from: NSRange(location: 0, length: attr.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
            )
            let out = temp("output.rtf")
            try data.write(to: out)
            return out
        }

        throw NSError(domain: "LocalConverter", code: 1)
    }

    private static func temp(_ name: String) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(name)
    }
}
