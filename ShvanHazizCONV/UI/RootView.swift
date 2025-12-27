import SwiftUI

struct RootView: View {
    @StateObject private var history = HistoryStore()

    var body: some View {
        TabView {
            HomeView()
                .environmentObject(history)
                .tabItem { Label("Convert", systemImage: "sparkles") }

            HistoryView()
                .environmentObject(history)
                .tabItem { Label("History", systemImage: "clock") }
        }
        .tint(.red)
    }
}
