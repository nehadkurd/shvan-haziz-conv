import Foundation

enum OnlineConverterError: LocalizedError {
    case invalidEndpoint
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidEndpoint: return "Invalid endpoint URL."
        case .serverError(let s): return s
        }
    }
}

/// Generic contract:
/// POST {endpoint}
/// - optional header: Authorization: Bearer <apiKey>
/// - multipart: file, output (e.g. "docx")
/// Response: binary output file
struct OnlineConverter {
    static func convert(endpoint: String, apiKey: String, inputURL: URL, inputData: Data, outputExt: String) async throws -> URL {
        guard let url = URL(string: endpoint) else { throw OnlineConverterError.invalidEndpoint }

        let boundary = "Boundary-\(UUID().uuidString)"
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if !apiKey.isEmpty {
            req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()

        func addField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        func addFile(name: String, filename: String, data: Data) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            body.append(data)
            body.append("\r\n".data(using: .utf8)!)
        }

        addField(name: "output", value: outputExt)
        addFile(name: "file", filename: inputURL.lastPathComponent, data: inputData)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        req.httpBody = body

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw OnlineConverterError.serverError("No HTTP response.") }
        guard (200...299).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw OnlineConverterError.serverError(msg)
        }

        let base = inputURL.deletingPathExtension().lastPathComponent
        let outName = base + "." + outputExt

        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("shvanhazizconv", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let outURL = dir.appendingPathComponent(outName)
        try data.write(to: outURL, options: .atomic)
        return outURL
    }
}
