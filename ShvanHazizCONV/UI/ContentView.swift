import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var showPicker = false
    @State private var pickedURL: URL?
    @State private var kind: FileKind = .unknown
    @State private var capability: ConversionCapability = .init(kind: .unknown, possibleTargets: [], note: "")
    @State private var selectedTarget: TargetFormat = .pdf
    @State private var outputURL: URL?
    @State private var showExport = false
    @State private var message: String?

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(.systemGray6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    actionCard

                    if let url = pickedURL {
                        fileCard(url: url)
                        convertCard
                    }

                    if let message {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showPicker) {
            DocumentPicker { url in
                pickedURL = url
                kind = ConversionEngine.detectKind(url: url)
                capability = ConversionEngine.capability(for: kind)
                message = capability.note

                // select first possible target by default
                if let first = capability.possibleTargets.first {
                    selectedTarget = first
                }
            }
        }
        .sheet(isPresented: $showExport) {
            if let outputURL {
                ExportSheet(url: outputURL)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shvan Haziz CONV")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Offline Converter • Clean UI • Re-sign friendly IPA")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.horizontal, 16)
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pick a file")
                .font(.headline)
                .foregroundStyle(.white)

            Text("We detect the type automatically and show only conversions that work offline.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))

            Button {
                showPicker = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Import File")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red.opacity(0.9))
                .cornerRadius(14)
            }
            .foregroundStyle(.white)
        }
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.35))
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }

    private func fileCard(url: URL) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Selected")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "doc.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.85))

                VStack(alignment: .leading, spacing: 4) {
                    Text(url.lastPathComponent)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text("Type: \(kind.rawValue.uppercased())")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
            }

            Text(capability.note)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.30))
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }

    private var convertCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Convert")
                .font(.headline)
                .foregroundStyle(.white)

            if capability.possibleTargets.isEmpty {
                Text("No offline conversion available for this type yet.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
            } else {
                Picker("Target", selection: $selectedTarget) {
                    ForEach(capability.possibleTargets, id: \.self) { t in
                        Text(t.rawValue.uppercased()).tag(t)
                    }
                }
                .pickerStyle(.segmented)

                Button {
                    guard let input = pickedURL else { return }
                    do {
                        let out = try ConversionEngine.convert(inputURL: input, to: selectedTarget)
                        outputURL = out
                        showExport = true
                        message = "Converted successfully. Export/share the output."
                    } catch {
                        message = "Conversion failed: \(error.localizedDescription)"
                    }
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Convert Now")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.16))
                    .cornerRadius(14)
                }
                .foregroundStyle(.white)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial.opacity(0.30))
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }
}
