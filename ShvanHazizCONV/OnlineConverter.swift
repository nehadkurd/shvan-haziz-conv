import Foundation
import UniformTypeIdentifiers

struct OnlineConverter {

    static let endpoint = URL(string: "https://your-backend.example/convert")!

    static func convert(inputURL: URL, output: UTType) async throws -> URL {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = try Data(contentsOf: inputURL)
        request.setValue(output.identifier, forHTTPHeaderField: "X-Target-Type")

        let (data, _) = try await URLSession.shared.data(for: request)

        let out = FileManager.default.temporaryDirectory
            .appendingPathComponent("output.\(output.preferredFilenameExtension ?? "bin")")

        try data.write(to: out)
        return out
    }
}
