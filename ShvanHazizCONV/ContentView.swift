import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)

                Text("shvan haziz CONV")
                    .font(.largeTitle)
                    .bold()

                Text("Convert any document to any format.")
                    .foregroundStyle(.secondary)

                Button("Upload File") {}
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
