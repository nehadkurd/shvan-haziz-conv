import SwiftUI

struct ConvertHomeView: View {
    @AppStorage("converter.endpoint") private var endpoint: String = ""
    @AppStorage("converter.apikey") private var apiKey: String = ""

    @State private var showPicker = false
    @State private var picked: PickedFile?
    @State private var target: OutputFormat = .pdf

    @State private var status: String = "Pick a file to start."
    @State private var working = false
    @State private var outputURL: URL?

    @State private var showShare = false
    @State private var shareItem: URL?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        hero
                        chooseCard
                        outputCard
                        actionCard

                        if let url = outputURL {
                            resultCard(url)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
            }
            .navigationTitle("Convert")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showPicker = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
            }
            .sheet(isPresented: $showPicker) {
                DocumentPicker { url in
                    if let url {
                        picked = PickedFile(url: url)
                        status = "Selected: \(url.lastPathComponent)"
                        outputURL = nil
                    } else {
                        status = "No file selected."
                    }
                }
            }
            .sheet(isPresented: $showShare) {
                if let item = shareItem {
                    ShareSheet(items: [item])
                }
            }
        }
        .preferredColorScheme(.dark)
        .tint(AppTheme.accent)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppTheme.stroke, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("shvan haziz CONV")
                        .font(.system(size: 20, weight: .heavy))
                    Text("Netflix-style converter")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppTheme.muted2)
                }
                Spacer()
            }

            Text("Local: TXT/MD/RTF → PDF, TXT ↔ RTF. Online: DOC/DOCX/ODT/PAGES via endpoint.")
                .font(.footnote)
                .foregroundStyle(AppTheme.muted2)
        }
        .netflixCard()
    }

    private var chooseCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose file").font(.system(size: 16, weight: .bold))

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(picked?.url.lastPathComponent ?? "No file selected")
                        .lineLimit(1)
                        .font(.system(size: 14, weight: .semibold))
                    Text(picked?.friendlyType ?? "—")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.muted2)
                }
                Spacer()
                Button { showPicker = true } label: {
                    Text("Upload")
                        .font(.system(size: 14, weight: .bold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .netflixCard()
    }

    private var outputCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Output format").font(.system(size: 16, weight: .bold))
            Picker("Output", selection: $target) {
                ForEach(OutputFormat.allCases) { f in
                    Text(f.label).tag(f)
                }
            }
            .pickerStyle(.menu)

            Text(target.note)
                .font(.footnote)
                .foregroundStyle(AppTheme.muted2)
        }
        .netflixCard()
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Convert").font(.system(size: 16, weight: .bold))

            Text(status).font(.footnote).foregroundStyle(AppTheme.muted2)

            Button {
                Task { await convertNow() }
            } label: {
                HStack(spacing: 10) {
                    if working { ProgressView() }
                    Text(working ? "Working..." : "Convert now")
                        .font(.system(size: 15, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .disabled(working || picked == nil)
        }
        .netflixCard()
    }

    private func resultCard(_ url: URL) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Result").font(.system(size: 16, weight: .bold))
            Text(url.lastPathComponent).font(.footnote).foregroundStyle(AppTheme.muted2)

            HStack {
                Button("Share") {
                    shareItem = url
                    showShare = true
                }
                .buttonStyle(.bordered)

                Spacer()

                Button("Open") {
                    shareItem = url
                    showShare = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .netflixCard()
    }

    private func convertNow() async {
        guard let picked else { return }
        working = true
        defer { working = false }

        do {
            status = "Reading..."
            let data = try Data(contentsOf: picked.url)

            status = "Converting..."
            if let localOut = try LocalConverter.convert(inputURL: picked.url, inputData: data, to: target) {
                outputURL = localOut
                status = "Done (local)."
                return
            }

            // needs online endpoint
            let ep = endpoint.trimmingCharacters(in: .whitespacesAndNewlines)
            if ep.isEmpty {
                status = "Needs online endpoint (Settings)."
                return
            }

            status = "Uploading..."
            let out = try await OnlineConverter.convert(endpoint: ep, apiKey: apiKey, inputURL: picked.url, inputData: data, outputExt: target.fileExtension)
            outputURL = out
            status = "Done (online)."
        } catch {
            status = "Error: \(error.localizedDescription)"
        }
    }
}
