import Foundation
import UniformTypeIdentifiers

/// Phase 2: Online fallback for formats that cannot be converted offline on iOS.
/// User does NOT configure anything.
/// You will later deploy a backend and replace `endpoint` with your real URL.
struct OnlineConverter {

    // TODO: Replace this with your real backend endpoint once deployed.
    static let endpoint = URL(string: "https://example.com/convert")!

    static func convert(inputURL: URL, output: UTType) async throws -> URL {
        // If you haven't deployed backend yet, fail with a clean message (no "needs endpoint").
        if endpoint.host == "example.com" {
            throw NSError(
                domain: "OnlineConverter",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Online conversion is not available yet. This format requires a server."]
            )
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 120

        let body = try Data(contentsOf: inputURL)
        request.httpBody = body
        request.setValue(output.identifier, forHTTPHeaderField: "X-Target-Type")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw NSError(
                domain: "OnlineConverter",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Server error: \(http.statusCode)"]
            )
        }

        let outExt = output.preferredFilenameExtension ?? "bin"
        let out = FileManager.default.temporaryDirectory.appendingPathComponent("output.\(outExt)")
        try data.write(to: out)
        return out
    }
}
