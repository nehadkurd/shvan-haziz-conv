import SwiftUI

struct RootView: View {
    @StateObject private var history = HistoryStore()

    var body: some View {
        GeometryReader { geo in
            TabView {
                HomeView(containerSize: geo.size)
                    .environmentObject(history)
                    .tabItem { Label("Convert", systemImage: "sparkles") }

                HistoryView(containerSize: geo.size)
                    .environmentObject(history)
                    .tabItem { Label("History", systemImage: "clock") }
            }
            .tint(.red)
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
