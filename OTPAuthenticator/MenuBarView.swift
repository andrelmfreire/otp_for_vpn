import SwiftUI

struct MenuBarView: View {
    @ObservedObject var accountManager: AccountManager
    @State private var otpCodes: [UUID: String] = [:]
    @State private var timeRemaining: [UUID: Int] = [:]
    @State private var showingMenuBar = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("OTP Codes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { showingMenuBar = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.controlBackgroundColor))
            
            Divider()
            
            if accountManager.accounts.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("No Accounts")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Add accounts in the main app")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
            } else {
                // OTP List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(accountManager.accounts) { account in
                            MenuBarOTPRow(
                                account: account,
                                otpCode: otpCodes[account.id] ?? "--- ---",
                                timeRemaining: timeRemaining[account.id] ?? 0,
                                onCopy: { copyOTP(for: account) }
                            )
                            
                            if account.id != accountManager.accounts.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxHeight: 400)
            }
            
            Divider()
            
            // Footer
            HStack {
                Button("Open App") {
                    NSApp.activate(ignoringOtherApps: true)
                    showingMenuBar = false
                }
                .buttonStyle(PlainButtonStyle())
                .font(.caption)
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(PlainButtonStyle())
                .font(.caption)
                .foregroundColor(.red)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.controlBackgroundColor))
        }
        .frame(minWidth: 280, maxWidth: 350)
        .background(Color(.windowBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 8)
        .onAppear(perform: updateAllOTPs)
        .onReceive(timer) { _ in
            updateAllOTPs()
        }
        .onReceive(accountManager.$accounts) { _ in
            updateAllOTPs()
        }
    }
    
    private func showSettingsWindow() {
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        settingsWindow.title = "OTP Authenticator Settings"
        settingsWindow.center()
        settingsWindow.setFrameAutosaveName("Settings")
        
        let settingsView = AccountListView(accountManager: accountManager)
        settingsWindow.contentView = NSHostingView(rootView: settingsView)
        
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func updateAllOTPs() {
        for account in accountManager.accounts {
            if let code = account.generateOTP() {
                otpCodes[account.id] = code
            }
            timeRemaining[account.id] = account.period - Int(Date().timeIntervalSince1970) % account.period
        }
    }
    
    private func copyOTP(for account: Account) {
        let finalPassword: String
        if account.useBasePassword && !account.basePassword.isEmpty {
            finalPassword = "\(account.basePassword)\(otpCodes[account.id] ?? "")"
        } else {
            finalPassword = otpCodes[account.id] ?? ""
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(finalPassword, forType: .string)
        
        // Play bell sound
        NSSound(named: "Ping")?.play()
    }
}

struct MenuBarOTPRow: View {
    let account: Account
    let otpCode: String
    let timeRemaining: Int
    let onCopy: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            // Account info
            VStack(alignment: .leading, spacing: 2) {
                Text(account.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(timeRemaining <= 5 ? .red : .secondary)
                    Text("\(timeRemaining)s")
                        .font(.caption2)
                        .foregroundColor(timeRemaining <= 5 ? .red : .secondary)
                    
                    if account.useBasePassword {
                        Image(systemName: "key.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // OTP Code
            Text(otpCode)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .frame(minWidth: 60)
            
            // Copy button
            Button(action: onCopy) {
                Image(systemName: "scissors")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(otpCode == "--- ---")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onCopy()
        }
    }
}

struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
        let accountManager = AccountManager()
        return MenuBarView(accountManager: accountManager)
    }
}
