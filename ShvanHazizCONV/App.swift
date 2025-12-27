import SwiftUI

@main
struct ShvanHazizCONVApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                PremiumBackground()   // 🔥 background at window level
                RootView()
            }
            .ignoresSafeArea()       // 🔥 true fullscreen
        }
    }
}
