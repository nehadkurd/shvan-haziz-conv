import SwiftUI
import UniformTypeIdentifiers

struct ConvertView: View {
    @AppStorage("converter.endpoint") private var endpoint: String = ""
    @AppStorage("converter.apikey") private var apiKey: String = ""

    @State private var pickedFile: PickedFile?
    @State private var isPicking = false

    @State private var targetFormat: OutputFormat = .pdf
    @State private var status: String = "Pick a file to start."
    @State private var isWorking = false
    @State private var outputURL: URL?

    @State private var showShare = false
    @State private var shareItem: URL?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header

                    fileCard

                    formatCard

                    actionCard

                    if let outputURL {
                        resultCard(outputURL)
                    }
                }
                .padding()
            }
            .navigationTitle("shvan haziz CONV")
            .sheet(isPresented: $isPicking) {
                DocumentPicker { url in
                    if let url {
                        self.pickedFile = PickedFile(url: url)
                        self.status = "Selected: \(url.lastPathComponent)"
                        self.outputURL = nil
                    } else {
                        self.status = "No file selected."
                    }
                }
            }
            .sheet(isPresented: $showShare) {
                if let shareItem {
                    ShareSheet(items: [shareItem])
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 52))
                .symbolRenderingMode(.hierarchical)

            Text("Convert your files")
                .font(.title2).bold()
            Text("Local: TXT/MD/RTF → PDF, TXT ↔ RTF. Online: DOC/DOCX/ODT/PAGES/PDF via endpoint.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 6)
    }

    private var fileCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("1) Choose file").font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pickedFile?.url.lastPathComponent ?? "No file selected")
                        .lineLimit(1)
                    Text(pickedFile?.friendlyType ?? "—")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Pick") { isPicking = true }
                    .buttonStyle(.borderedProminent)
            }
        }
        .card()
    }

    private var formatCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("2) Output format").font(.headline)

            Picker("Output", selection: $targetFormat) {
                ForEach(OutputFormat.allCases) { f in
                    Text(f.label).tag(f)
                }
            }
            .pickerStyle(.menu)

            Text(targetFormat.note)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .card()
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("3) Convert").font(.headline)

            Text(status)
                .font(.footnote)
                .foregroundStyle(isWorking ? .secondary : .secondary)

            Button {
                Task { await convertNow() }
            } label: {
                HStack {
                    if isWorking { ProgressView().padding(.trailing, 6) }
                    Text(isWorking ? "Working..." : "Convert")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isWorking || pickedFile == nil)
        }
        .card()
    }

    private func resultCard(_ url: URL) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Result").font(.headline)

            Text(url.lastPathComponent)
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack {
                Button("Share") {
                    shareItem = url
                    showShare = true
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Open in Files") {
                    // share sheet works as "open"
                    shareItem = url
                    showShare = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .card()
    }

    private func convertNow() async {
        guard let pickedFile else { return }
        isWorking = true
        defer { isWorking = false }

        do {
            status = "Reading file..."
            let inputData = try Data(contentsOf: pickedFile.url)

            // LOCAL conversions that work without server
            if let localOut = try LocalConverter.convert(
                inputURL: pickedFile.url,
                inputData: inputData,
                to: targetFormat
            ) {
                outputURL = localOut
                status = "Done (local)."
                return
            }

            // Online conversions if local not supported
            guard !endpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                status = "This conversion needs an online endpoint. Set it in Settings."
                return
            }

            status = "Uploading to online converter..."
            let out = try await OnlineConverter.convert(
                endpoint: endpoint,
                apiKey: apiKey,
                inputURL: pickedFile.url,
                inputData: inputData,
                outputExt: targetFormat.fileExtension
            )
            outputURL = out
            status = "Done (online)."
        } catch {
            status = "Error: \(error.localizedDescription)"
        }
    }
}
