import SwiftUI

struct OTPDashboardView: View {
    @ObservedObject var accountManager: AccountManager
    @State private var otpCodes: [UUID: String] = [:]
    @State private var timeRemaining: [UUID: Int] = [:]
    @State private var showCopiedAlert = false
    @State private var copiedAccountName = ""
    @State private var showingAccountList = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("OTP Dashboard")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { showingAccountList = true }) {
                    HStack {
                        Image(systemName: "person.2")
                        Text("Manage Accounts")
                    }
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .padding()
            
            Divider()
            
            if accountManager.accounts.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No Accounts Yet")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Add your first OTP account to get started")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    Button(action: { showingAccountList = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Account")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(6)
                    .frame(maxWidth: 200)
                }
                .padding(40)
            } else {
                // OTP Cards
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 250, maximum: 350), spacing: 12)
                    ], spacing: 12) {
                        ForEach(accountManager.accounts) { account in
                            OTPCardView(
                                account: account,
                                otpCode: otpCodes[account.id] ?? "--- ---",
                                timeRemaining: timeRemaining[account.id] ?? 0,
                                onCopy: { copyOTP(for: account) }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: updateAllOTPs)
        .onReceive(timer) { _ in
            updateAllOTPs()
        }
        .onReceive(accountManager.$accounts) { _ in
            updateAllOTPs()
        }
        .animation(.easeInOut(duration: 0.3), value: showCopiedAlert)
        .sheet(isPresented: $showingAccountList) {
            AccountListView(accountManager: accountManager)
        }
        .overlay(
            // Copy confirmation
            Group {
                if showCopiedAlert {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("\(copiedAccountName) OTP copied!")
                                .font(.headline)
                        }
                        .padding()
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        )
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
        
        copiedAccountName = account.displayName
        showCopiedAlert = true
        
        // Play bell sound
        NSSound(named: "Ping")?.play()
        
        // Hide alert after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopiedAlert = false
        }
    }
}

struct OTPCardView: View {
    let account: Account
    let otpCode: String
    let timeRemaining: Int
    let onCopy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Account header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(account.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if !account.issuer.isEmpty {
                        Text(account.issuer)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Account settings indicator
                if account.useBasePassword {
                    Image(systemName: "key.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            
            // OTP Code
            Text(otpCode)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.controlBackgroundColor))
                )
            
            // Timer and Copy button on same line
            HStack {
                // Timer
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(timeRemaining <= 5 ? .red : .secondary)
                        .font(.caption)
                    Text("\(timeRemaining)s")
                        .font(.caption)
                        .foregroundColor(timeRemaining <= 5 ? .red : .secondary)
                }
                
                Spacer()
                
                // Algorithm info
                Text("\(account.algorithm) • \(account.digits)d")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Copy button
                Button(action: onCopy) {
                    HStack(spacing: 4) {
                        Image(systemName: "scissors")
                            .font(.caption)
                        Text(account.useBasePassword ? "Pwd" : "OTP")
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(otpCode == "--- ---")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct OTPDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        let accountManager = AccountManager()
        return OTPDashboardView(accountManager: accountManager)
    }
}
