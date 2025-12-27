import SwiftUI

struct HomeView: View {
    let containerSize: CGSize
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

    private var horizontalPadding: CGFloat {
        max(16, containerSize.width * 0.05)
    }

    var body: some View {
        
            ZStack {
                PremiumBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {

                        header
                            .padding(.top, 12)

                        importCard

                        if let detected {
                            detectedCard(detected)
                            suggestionsCard
                        }

                        if let message {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.75))
                        }

                        if !history.items.isEmpty {
                            recentHeader
                            recentCarousel
                        }

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 32)
                }

                if isConverting {
                    convertingOverlay
                }
            }
            .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showPicker) {
            DocumentPicker { url in
                let d = FileDetector.detect(url: url)
                detected = d
                targets = ConversionRules.targets(for: d.family)
                note = ConversionRules.note(for: d.family)
                selectedTarget = targets.first
                message = note
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
                .font(.system(size: min(36, containerSize.width * 0.09), weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("Smart. Quiet. Powerful.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    private var importCard: some View {
        PremiumCard(
            title: "Ready when you are",
            subtitle: "Import a file — we’ll understand it instantly."
        ) {
            PrimaryCTAButton(title: "Import File", icon: "plus.circle.fill") {
                showPicker = true
            }
        }
    }

    private func detectedCard(_ d: DetectedFile) -> some View {
        PremiumCard(title: "Detected", subtitle: "We’ve got it.") {
            VStack(alignment: .leading, spacing: 10) {
                Text(d.fileName)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(d.family.rawValue.uppercased())
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))

                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
    }

    private var suggestionsCard: some View {
        PremiumCard(title: "Suggested conversions", subtitle: "Only what actually works.") {
            if targets.isEmpty {
                Text("No valid conversions available.")
                    .foregroundStyle(.white.opacity(0.75))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(targets) { t in
                            targetPill(t, selected: t.id == selectedTarget?.id)
                                .onTapGesture { selectedTarget = t }
                        }
                    }
                }

                if let selectedTarget {
                    if selectedTarget.mode == .onDevice {
                        SoftButton(title: "Convert Now", icon: "sparkles") {
                            runOnDeviceConversion(selectedTarget)
                        }
                    } else {
                        Text("Secure cloud conversion (coming soon).")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
            }
        }
    }

    private func targetPill(_ t: ConversionTarget, selected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(t.title)
                .fontWeight(.semibold)
            Text(t.subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(14)
        .frame(width: max(170, containerSize.width * 0.42))
        .background(selected ? Color.white.opacity(0.2) : Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .foregroundStyle(.white)
    }

    private var recentHeader: some View {
        Text("Recent")
            .font(.headline)
            .foregroundStyle(.white)
    }

    private var recentCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(history.items.prefix(10)) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.inputName)
                            .font(.subheadline)
                            .lineLimit(1)
                        Text("\(item.inputFamily.rawValue.uppercased()) → \(item.outputFormat.rawValue.uppercased())")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .padding(14)
                    .frame(width: max(220, containerSize.width * 0.55))
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .foregroundStyle(.white)
                }
            }
        }
    }

    private var convertingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            ProgressView("Converting…")
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .foregroundStyle(.white)
        }
    }

    private func runOnDeviceConversion(_ target: ConversionTarget) {
        guard let detected,
              let inputURL = FileDetector.resolveBookmark(detected.inputURLBookmark) else {
            message = "Unable to access the file."
            return
        }

        isConverting = true
        message = nil

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let out = try OnDeviceConverter.convert(
                    inputURL: inputURL,
                    inputFamily: detected.family,
                    to: target.format
                )
                DispatchQueue.main.async {
                    isConverting = false
                    outputURL = out
                    showShare = true
                    message = "Conversion complete."
                }
            } catch {
                DispatchQueue.main.async {
                    isConverting = false
                    message = error.localizedDescription
                }
            }
        }
}
