import SwiftUI
import Foundation

class SettingsManager: ObservableObject {
    @Published var baseString: String {
        didSet {
            UserDefaults.standard.set(baseString, forKey: "baseString")
        }
    }
    
    @Published var otpAuthURL: String {
        didSet {
            UserDefaults.standard.set(otpAuthURL, forKey: "otpAuthURL")
        }
    }
    
    init() {
        self.baseString = UserDefaults.standard.string(forKey: "baseString") ?? "Wequ3kahtee@ph9o"
        self.otpAuthURL = UserDefaults.standard.string(forKey: "otpAuthURL") ?? "otpauth://totp/andre.freire@OPNsense?secret=RGKFLVKQL4JLZROYKWVV4EWTKQJBLCXO"
    }
    
    func isValidOTPAuthURL(_ url: String) -> Bool {
        guard url.hasPrefix("otpauth://totp/") else { return false }
        guard let components = URLComponents(string: url),
              let queryItems = components.queryItems else { return false }
        
        // Check if secret parameter exists
        return queryItems.contains { $0.name.lowercased() == "secret" && $0.value != nil }
    }
}

struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @Environment(\.presentationMode) var presentationMode
    @State private var tempBaseString: String = ""
    @State private var tempOtpAuthURL: String = ""
    @State private var showingURLError = false
    @State private var showingSavedAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                Spacer()
                
                Text("Settings")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Save") {
                    saveSettings()
                }
                .disabled(tempBaseString.isEmpty || tempOtpAuthURL.isEmpty)
                .buttonStyle(BorderedButtonStyle())
                .foregroundColor(.white)
                .background(tempBaseString.isEmpty || tempOtpAuthURL.isEmpty ? Color.gray : Color.accentColor)
                .cornerRadius(6)
            }
            .padding()
            .background(Color(.windowBackgroundColor))
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Authentication Settings Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Authentication Settings")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.headline)
                            TextField("Enter your base password", text: $tempBaseString)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                            Text("This will be combined with the OTP code")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("OTP Auth URL")
                                .font(.headline)
                            TextField("otpauth://totp/...", text: $tempOtpAuthURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(maxWidth: .infinity)
                            Text("Scan QR code from your authenticator setup or paste the otpauth:// URL")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if showingURLError {
                                Text("❌ Invalid OTP Auth URL format")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                    
                    // Instructions Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How to get your OTP Auth URL:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("1. Go to your service's 2FA setup")
                                Text("2. When shown a QR code, look for 'Can't scan?' or 'Enter manually'")
                                Text("3. Copy the text that starts with 'otpauth://totp/'")
                                Text("4. Paste it in the field above")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.controlBackgroundColor)))
                    
                    Spacer()
                }
                .padding()
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .frame(maxWidth: 600, maxHeight: 600)
        .onAppear {
            tempBaseString = settingsManager.baseString
            tempOtpAuthURL = settingsManager.otpAuthURL
        }
        .alert(isPresented: $showingSavedAlert) {
            Alert(
                title: Text("Settings Saved"),
                message: Text("Your settings have been saved successfully."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func saveSettings() {
        showingURLError = false
        
        // Validate OTP Auth URL
        guard settingsManager.isValidOTPAuthURL(tempOtpAuthURL) else {
            showingURLError = true
            return
        }
        
        // Save settings
        settingsManager.baseString = tempBaseString
        settingsManager.otpAuthURL = tempOtpAuthURL
        
        showingSavedAlert = true
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settingsManager: SettingsManager())
    }
}