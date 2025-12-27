import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var history: HistoryStore
    @State private var showPicker = false
    @State private var detected: DetectedFile?
    @State private var targets: [ConversionTarget] = []
    @State private var note: String = ""
    @State private var selectedTarget: ConversionTarget?
    @State private var isConverting = false
    @State private var outputURL: URL?
    @State private var showShare = false
    @State private var message: String?

    var body: some View {
        ZStack {
            PremiumBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {

                    header

                    PremiumCard(
                        title: "Ready when you are",
                        subtitle: "Import a file — we’ll understand it instantly."
                    ) {
                        PrimaryCTAButton(title: "Import File", icon: "plus.circle.fill") {
                            showPicker = true
                        }
                    }
                    .padding(.horizontal, 16)

                    if let detected {
                        detectedCard(detected)
                            .padding(.horizontal, 16)

                        suggestionsCard
                            .padding(.horizontal, 16)
                    }

                    if let message {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.75))
                            .padding(.horizontal, 16)
                    }

                    if !history.items.isEmpty {
                        recentHeader
                            .padding(.horizontal, 16)

                        recentCarousel
                            .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.top, 14)
                .padding(.bottom, 28)
            }

            if isConverting {
                convertingOverlay
            }
        }
        .sheet(isPresented: $showPicker) {
            DocumentPicker { url in
                let d = FileDetector.detect(url: url)
                detected = d
                targets = ConversionRules.targets(for: d.family)
                note = ConversionRules.note(for: d.family)
                selectedTarget = targets.first
                message = note
            }
        }
        .sheet(isPresented: $showShare) {
            if let outputURL {
                ShareSheet(url: outputURL)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Shvan Haziz CONV")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Smart. Quiet. Powerful.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.horizontal, 16)
    }

    private func detectedCard(_ d: DetectedFile) -> some View {
        PremiumCard(title: "Detected", subtitle: "We’ve got it.") {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: icon(for: d.family))
                        .font(.system(size: 26))
                        .foregroundStyle(.white.opacity(0.9))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(d.fileName)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                        Text(d.family.rawValue.uppercased())
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    Spacer()
                }

                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
    }

    private var suggestionsCard: some View {
        PremiumCard(title: "Suggested conversions", subtitle: "Only what actually works.") {

            if targets.isEmpty {
                Text("No valid conversions for this file yet.")
                    .foregroundStyle(.white.opacity(0.75))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(targets) { t in
                            targetPill(t, selected: t.id == selectedTarget?.id)
                                .onTapGesture { selectedTarget = t }
                        }
                    }
                    .padding(.vertical, 2)
                }

                if let selectedTarget {
                    if selectedTarget.mode == .secureCloud {
                        Text("This conversion requires secure cloud processing. (Backend not added yet.)")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.75))
                    } else {
                        SoftButton(title: "Convert Now", icon: "sparkles") {
                            runOnDeviceConversion(selectedTarget)
                        }
                    }
                }
            }
        }
    }

    private func targetPill(_ t: ConversionTarget, selected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: t.systemIcon)
                Text(t.title).fontWeight(.semibold)
            }
            .foregroundStyle(.white)

            Text(t.subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))

            Text(t.mode == .onDevice ? "On-device" : "Secure cloud")
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.12))
                .clipShape(Capsule())
                .foregroundStyle(.white.opacity(0.85))
        }
        .padding(12)
        .frame(width: 180)
        .background(selected ? Color.white.opacity(0.18) : Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var convertingOverlay: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                Text("Converting…")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Just a moment.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(18)
            .background(.ultraThinMaterial.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private var recentHeader: some View {
        HStack {
            Text("Recent")
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
        }
    }

    private var recentCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(history.items.prefix(10)) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.inputName)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text("\(item.inputFamily.rawValue.uppercased()) → \(item.outputFormat.rawValue.uppercased())")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                        Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.65))
                    }
                    .padding(12)
                    .frame(width: 220)
                    .background(Color.white.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
    }

    private func runOnDeviceConversion(_ target: ConversionTarget) {
        guard let detected else { return }
        guard let inputURL = FileDetector.resolveBookmark(detected.inputURLBookmark) else {
            message = "We couldn’t access the file. Please import again."
            return
        }

        isConverting = true
        message = nil

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let out = try OnDeviceConverter.convert(inputURL: inputURL, inputFamily: detected.family, to: target.format)

                let outBookmark = (try? out.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)) ?? Data()
                let historyItem = HistoryItem(
                    id: UUID().uuidString,
                    inputName: detected.fileName,
                    inputFamily: detected.family,
                    outputFormat: target.format,
                    outputURLBookmark: outBookmark,
                    createdAt: Date()
                )

                DispatchQueue.main.async {
                    self.isConverting = false
                    self.outputURL = out
                    self.showShare = true
                    self.message = "Conversion complete."
                    self.history.add(historyItem)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isConverting = false
                    self.message = "Conversion failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func icon(for family: FileFamily) -> String {
        switch family {
        case .word: return "doc.text.fill"
        case .powerpoint: return "rectangle.3.group.fill"
        case .pdf: return "doc.richtext.fill"
        case .rtf: return "textformat"
        case .txt: return "doc.plaintext.fill"
        case .unknown: return "questionmark.folder.fill"
        }
    }
}
