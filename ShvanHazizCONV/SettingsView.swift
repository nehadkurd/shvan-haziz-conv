import SwiftUI

struct SettingsView: View {
    @AppStorage("converter.endpoint") private var endpoint: String = ""
    @AppStorage("converter.apikey") private var apiKey: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                Form {
                    Section("Online Converter (Optional)") {
                        TextField("Endpoint URL (https://...)", text: $endpoint)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .keyboardType(.URL)

                        SecureField("API Key / Token", text: $apiKey)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)

                        Text("Local conversions work without internet. DOC/DOCX/ODT/PAGES require online endpoint.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Section("Re-sign friendly") {
                        Text("This build uses a neutral bundle id. Re-signers must set a bundle id that matches their provisioning profile (or wildcard).")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
        }
        .preferredColorScheme(.dark)
        .tint(AppTheme.accent)
    }
}
