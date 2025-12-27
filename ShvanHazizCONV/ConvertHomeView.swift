import SwiftUI
import UniformTypeIdentifiers

struct ConvertHomeView: View {

    @State private var showPicker = false
    @State private var inputURL: URL?
    @State private var inputType: UTType = .data

    @State private var outputs: [FormatRegistry.OutputOption] = []
    @State private var selectedOutput: FormatRegistry.OutputOption?

    @State private var isWorking = false
    @State private var resultURL: URL?
    @State private var showShare = false

    @State private var errorMessage: String?

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    header

                    fileCard

                    if let _ = inputURL {
                        outputsSection(width: geo.size.width)
                    }

                    if let url = resultURL {
                        resultSection(url: url)
                    }

                    if let err = errorMessage {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(16)
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
            }
        }
        .sheet(isPresented: $showPicker) {
            DocumentPicker { url in
                inputURL = url
                inputType = FormatRegistry.detectInputType(for: url)
                outputs = FormatRegistry.outputOptions(for: inputType)
                selectedOutput = outputs.first
                resultURL = nil
                errorMessage = nil
                showPicker = false
            }
        }
        .sheet(isPresented: $showShare) {
            if let url = resultURL {
                ShareSheet(items: [url])
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("shvan haziz CONV")
                .font(.system(size: 28, weight: .bold))
            Text("Convert files offline when possible. Online only when needed.")
                .foregroundStyle(.secondary)
        }
    }

    private var fileCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("File")
                        .font(.headline)
                    Text(inputURL?.lastPathComponent ?? "No file selected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
                Button {
                    showPicker = true
                } label: {
                    Text(inputURL == nil ? "Upload" : "Change")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.primary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private func outputsSection(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Convert to")
                .font(.headline)

            LazyVGrid(columns: AdaptiveLayout.columns(for: width), spacing: 14) {
                ForEach(outputs) { opt in
                    let isSelected = opt.id == selectedOutput?.id
                    Button {
                        selectedOutput = opt
                        errorMessage = nil
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(opt.title)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(2)

                            Text(opt.isOffline ? "Offline" : "Online")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, minHeight: 62, alignment: .leading)
                        .padding(12)
                        .background(isSelected ? Color.primary.opacity(0.12) : Color.primary.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                Task { await convertNow() }
            } label: {
                HStack {
                    if isWorking {
                        ProgressView()
                            .padding(.trailing, 6)
                    }
                    Text(isWorking ? "Converting..." : "Convert")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.primary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(isWorking || inputURL == nil || selectedOutput == nil)
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private func resultSection(url: URL) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Result")
                .font(.headline)
            Text(url.lastPathComponent)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                showShare = true
            } label: {
                Text("Share / Save")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.primary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @MainActor
    private func convertNow() async {
        guard let inputURL, let selectedOutput else { return }
        isWorking = true
        errorMessage = nil
        resultURL = nil

        do {
            let outType = selectedOutput.type
            if LocalConverter.canHandle(input: inputType, output: outType) {
                let out = try LocalConverter.convert(inputURL: inputURL, input: inputType, output: outType)
                resultURL = out
            } else {
                let out = try await OnlineConverter.convert(inputURL: inputURL, output: outType)
                resultURL = out
            }
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }

        isWorking = false
    }
}
