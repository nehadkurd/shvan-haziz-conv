import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ConvertHomeView()
                .tabItem { Label("Convert", systemImage: "arrow.left.arrow.right") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(AppTheme.accent)
    }
}
