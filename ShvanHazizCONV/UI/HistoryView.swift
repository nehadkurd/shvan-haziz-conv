import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var history: HistoryStore
    @State private var shareURL: URL?
    @State private var showShare = false
    @State private var message: String?

    var body: some View {
        ZStack {
            PremiumBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("History")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)

                    if history.items.isEmpty {
                        PremiumCard(title: "Nothing yet", subtitle: "Your conversions will appear here.") {
                            Text("Start by importing a file.")
                                .foregroundStyle(.white.opacity(0.75))
                        }
                        .padding(.horizontal, 16)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(history.items) { item in
                                historyCard(item)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }

                    if let message {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.75))
                            .padding(.horizontal, 16)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.bottom, 28)
            }
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
