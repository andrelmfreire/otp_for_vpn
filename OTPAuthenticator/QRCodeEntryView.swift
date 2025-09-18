import SwiftUI

struct QRCodeEntryView: View {
    @ObservedObject var accountManager: AccountManager
    @Environment(\.presentationMode) var presentationMode
    @State private var qrCodeText = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Account from QR Code")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                Button("Add") {
                    addAccount()
                }
                .buttonStyle(BorderedButtonStyle())
                .foregroundColor(.white)
                .background(Color.accentColor)
                .cornerRadius(6)
                .disabled(qrCodeText.isEmpty)
            }
            .padding()
            
            Divider()
            
            // Content
            VStack(alignment: .leading, spacing: 20) {
                Text("Paste your OTP Auth URL here:")
                    .font(.headline)
                
                TextEditor(text: $qrCodeText)
                    .frame(minHeight: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Text("Example: otpauth://totp/AccountName?secret=YOUR_SECRET&issuer=ServiceName")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("💡 Tip: Copy the text from your authenticator app's 'Manual Entry' or 'Can't scan?' option")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 400)
        .alert(isPresented: $showingError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func addAccount() {
        guard !qrCodeText.isEmpty else {
            errorMessage = "Please enter a QR code URL"
            showingError = true
            return
        }
        
        guard let account = Account.fromOTPAuthURL(qrCodeText) else {
            errorMessage = "Invalid OTP Auth URL format. Please check the URL and try again."
            showingError = true
            return
        }
        
        accountManager.addAccount(account)
        presentationMode.wrappedValue.dismiss()
    }
}
