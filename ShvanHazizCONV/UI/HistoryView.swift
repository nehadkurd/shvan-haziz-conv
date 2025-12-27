import SwiftUI

struct HistoryView: View {
    let containerSize: CGSize
    @EnvironmentObject private var history: HistoryStore
    @State private var shareURL: URL?
    @State private var showShare = false
    @State private var message: String?

    private var horizontalPadding: CGFloat {
        max(16, containerSize.width * 0.05)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PremiumBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("History")
                            .font(.system(size: min(36, containerSize.width * 0.09), weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top, 14)

                        if history.items.isEmpty {
                            PremiumCard(title: "Nothing yet", subtitle: "Your conversions will appear here.") {
                                Text("Start by importing a file.")
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                        } else {
                            VStack(spacing: 12) {
                                ForEach(history.items) { item in
                                    historyCard(item)
                                }
                            }
                        }

                        if let message {
                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.75))
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 28)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .sheet(isPresented: $showShare) {
            if let shareURL {
                ShareSheet(url: shareURL)
            }
        }
    }

    private func historyCard(_ item: HistoryItem) -> some View {
        PremiumCard(
            title: item.inputName,
            subtitle: "\(item.inputFamily.rawValue.uppercased()) → \(item.outputFormat.rawValue.uppercased())"
        ) {
            HStack {
                Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
                Spacer()
                SoftButton(title: "Share", icon: "square.and.arrow.up") {
                    if let url = FileDetector.resolveBookmark(item.outputURLBookmark) {
                        shareURL = url
                        showShare = true
                    } else {
                        message = "Couldn’t access that output anymore."
                    }
                }
                .frame(width: 140)
            }
        }
    }
}
