import UniformTypeIdentifiers

/// Simple helper model used by future phases (history/batch/pro).
struct ConversionModel {
    static func supportsOffline(input: UTType, output: UTType) -> Bool {
        LocalConverter.canHandle(input: input, output: output)
    }
}
