import Foundation
import UIKit

enum OutputFormat: String, CaseIterable, Identifiable {
    case pdf, txt, rtf, md, doc, docx, odt, pages
    var id: String { rawValue }
}

struct LocalConverter {

    static func convert(inputURL: URL, inputData: Data, to out: OutputFormat) throws -> URL? {
        let ext = inputURL.pathExtension.lowercased()

        if out == .pdf, let text = String(data: inputData, encoding: .utf8) {
            return try makePDF(from: text, name: "output.pdf")
        }

        return nil
    }

    private static func makePDF(from text: String, name: String) throws -> URL {
        let page = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: page)

        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            let attrs = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
            ]
            text.draw(in: page.insetBy(dx: 32, dy: 32), withAttributes: attrs)
        }

        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent(name)
        try data.write(to: url)
        return url
    }
}
