import Foundation
import UniformTypeIdentifiers

final class FileDetector {

    static func detect(url: URL) -> DetectedFile {
        let ext = url.pathExtension.lowercased()
        let ut = UTType(filenameExtension: ext)
        let utid = ut?.identifier

        let family: FileFamily = {
            if ["docx","doc","docm","dotx","dotm"].contains(ext) { return .word }
            if ["pptx","ppt","pptm","potx","potm","ppsx","ppsm"].contains(ext) { return .powerpoint }
            if ext == "pdf" { return .pdf }
            if ext == "rtf" { return .rtf }
            if ext == "txt" { return .txt }
            // Extra: if UTType says PDF
            if ut?.conforms(to: .pdf) == true { return .pdf }
            if ut?.conforms(to: .plainText) == true { return .txt }
            if ut?.conforms(to: .rtf) == true { return .rtf }
            return .unknown
        }()

        let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init) ?? 0

        let bookmark = (try? url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)) ?? Data()

        return DetectedFile(
            id: UUID().uuidString,
            inputURLBookmark: bookmark,
            fileName: url.lastPathComponent,
            fileExtension: ext,
            utTypeIdentifier: utid,
            family: family,
            fileSizeBytes: size,
            detectedAt: Date()
        )
    }

    static func resolveBookmark(_ data: Data) -> URL? {
        var stale = false
        guard let url = try? URL(resolvingBookmarkData: data, options: [.withoutUI, .withoutMounting], relativeTo: nil, bookmarkDataIsStale: &stale) else {
            return nil
        }
        return url
    }
}
