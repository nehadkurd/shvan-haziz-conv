import Foundation
import UniformTypeIdentifiers

enum FileFamily: String, Codable {
    case word
    case powerpoint
    case pdf
    case rtf
    case txt
    case unknown
}

enum TargetFormat: String, Codable, CaseIterable {
    case pdf
    case txt
    case rtf
    case images
    case mp4
}

enum ConversionMode: String, Codable {
    case onDevice
    case secureCloud
}

struct ConversionTarget: Identifiable, Codable, Hashable {
    let id: String
    let format: TargetFormat
    let mode: ConversionMode
    let title: String
    let subtitle: String
    let systemIcon: String
}

struct DetectedFile: Identifiable, Codable {
    let id: String
    let inputURLBookmark: Data
    let fileName: String
    let fileExtension: String
    let utTypeIdentifier: String?
    let family: FileFamily
    let fileSizeBytes: Int64
    let detectedAt: Date
}

struct HistoryItem: Identifiable, Codable {
    let id: String
    let inputName: String
    let inputFamily: FileFamily
    let outputFormat: TargetFormat
    let outputURLBookmark: Data
    let createdAt: Date
}
