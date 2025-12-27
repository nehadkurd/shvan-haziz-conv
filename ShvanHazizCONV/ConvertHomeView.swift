if ConversionModel.supportsOffline(input: inputType, output: outputType) {
    resultURL = try LocalConverter.convert(
        inputURL: inputURL,
        input: inputType,
        output: outputType
    )
} else {
    resultURL = try await OnlineConverter.convert(
        inputURL: inputURL,
        output: outputType
    )
}
