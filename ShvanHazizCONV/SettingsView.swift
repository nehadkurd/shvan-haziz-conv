import SwiftUI

struct SettingsView: View {
    @Binding var endpoint: String
    @Binding var apiKey: String

    var body: some View {
        NavigationStack {
            Form {
                Section("Online Converter (Optional)") {
                    TextField("Endpoint URL (https://...)", text: $endpoint)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.URL)

                    SecureField("API Key / Token", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    Text("Local conversions work without any server. Formats like DOCX/ODT/PAGES require an online converter.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Bundle ID Note") {
                    Text("This app uses a neutral bundle id (com.example.shvanhazizconv) so anyone can re-sign the IPA with their own certificate and provisioning profile.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
