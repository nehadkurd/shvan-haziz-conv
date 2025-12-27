import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Convert anything.")
                    .font(.system(size: 34, weight: .bold))
                Text("We understand your files.")
                    .foregroundColor(.secondary)
                Button("Import File") {}
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
