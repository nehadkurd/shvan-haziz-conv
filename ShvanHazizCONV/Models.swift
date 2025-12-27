import UniformTypeIdentifiers

struct ConversionModel {

    static func supportsOffline(input: UTType, output: UTType) -> Bool {
        LocalConverter.canHandle(input: input, output: output)
    }
}
