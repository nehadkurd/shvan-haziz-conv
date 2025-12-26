import SwiftUI

struct RootView: View {
    @AppStorage("converter.endpoint") private var endpoint: String = ""
    @AppStorage("converter.apikey") private var apiKey: String = ""

    var body: some View {
        TabView {
            ConvertView()
                .tabItem { Label("Convert", systemImage: "arrow.left.arrow.right") }

            SettingsView(endpoint: $endpoint, apiKey: $apiKey)
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}
