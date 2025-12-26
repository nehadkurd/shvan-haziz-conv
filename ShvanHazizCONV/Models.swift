import Foundation

struct PickedFile {
    let url: URL
    var friendlyType: String {
        let ext = url.pathExtension.lowercased()
        return ext.isEmpty ? "Unknown" : ext.uppercased()
    }
}
