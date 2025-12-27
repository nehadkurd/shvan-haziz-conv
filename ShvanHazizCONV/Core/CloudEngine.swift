import Foundation

struct CloudJobResponse: Codable {
    let jobId: String
}

struct CloudStatusResponse: Codable {
    let status: String
    let message: String?
    let downloadUrl: String?
}

enum CloudEngineError: LocalizedError {
    case notConfigured
    case invalidURL
    case http(Int)
    case server(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Cloud conversion is not configured yet."
        case .invalidURL:
            return "Invalid cloud service URL."
        case .http(let code):
            return "Cloud service error (\(code))."
        case .server(let msg):
            return msg
        }
    }
}

final class CloudEngine {

    static func convert(inputURL: URL, target: TargetFormat) async throws -> URL {
        guard AppConfig.apiBaseURL != "https://YOUR_BACKEND_DOMAIN" else {
            throw CloudEngineError.notConfigured
        }

        guard let base = URL(string: AppConfig.apiBaseURL) else {
            throw CloudEngineError.invalidURL
        }

        let convertURL = base.appendingPathComponent("convert")

        var request = URLRequest(url: convertURL)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let fileData = try Data(contentsOf: inputURL)

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"target\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(target.rawValue)\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(inputURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw CloudEngineError.http(-1)
        }
        guard (200..<300).contains(http.statusCode) else {
            throw CloudEngineError.http(http.statusCode)
        }

        let job = try JSONDecoder().decode(CloudJobResponse.self, from: data)

        let statusURL = base.appendingPathComponent("status").appendingPathComponent(job.jobId)

        for _ in 0..<120 {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            let (sd, sr) = try await URLSession.shared.data(from: statusURL)
            guard let sh = sr as? HTTPURLResponse, (200..<300).contains(sh.statusCode) else {
                continue
            }

            let status = try JSONDecoder().decode(CloudStatusResponse.self, from: sd)

            if status.status == "done", let durl = status.downloadUrl, let url = URL(string: durl) {
                return try await download(from: url, name: inputURL.deletingPathExtension().lastPathComponent, target: target)
            }

            if status.status == "error" {
                throw CloudEngineError.server(status.message ?? "Conversion failed.")
            }
        }

        throw CloudEngineError.server("Conversion timed out.")
    }

    private static func download(from url: URL, name: String, target: TargetFormat) async throws -> URL {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw CloudEngineError.http(-1)
        }

        let ext: String = {
            switch target {
            case .pdf: return "pdf"
            case .txt: return "txt"
            case .rtf: return "rtf"
            case .images: return "zip"
            case .mp4: return "mp4"
            }
        }()

        let out = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(name)-cloud.\(ext)")
        try data.write(to: out, options: .atomic)
        return out
    }
}
