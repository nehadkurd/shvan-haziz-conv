import SwiftUI

struct RootView: View {
    @StateObject private var history = HistoryStore()

    var body: some View {
        TabView {
            GeometryReader { geo in
                HomeView(containerSize: geo.size)
                    .environmentObject(history)
            }
            .tabItem { Label("Convert", systemImage: "sparkles") }

            GeometryReader { geo in
                HistoryView(containerSize: geo.size)
                    .environmentObject(history)
            }
            .tabItem { Label("History", systemImage: "clock") }
        }
        .tint(.red)
    }
}
