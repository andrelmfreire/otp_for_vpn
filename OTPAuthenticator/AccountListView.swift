import SwiftUI

struct AccountListView: View {
    @ObservedObject var accountManager: AccountManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showingQRScanner = false
    @State private var showingManualEntry = false
    @State private var accountToDelete: Account?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Manage Accounts")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
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
                    
                    Text("Add your first OTP account by scanning a QR code or entering details manually")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 12) {
                        Button(action: { showingQRScanner = true }) {
                            HStack {
                                Image(systemName: "qrcode.viewfinder")
                                Text("Scan QR Code")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(6)
                        
                        Button(action: { showingManualEntry = true }) {
                            HStack {
                                Image(systemName: "keyboard")
                                Text("Enter Manually")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: 200)
                }
                .padding(40)
            } else {
                // Account list
                List {
                    ForEach(accountManager.accounts) { account in
                        AccountRowView(
                            account: account,
                            isSelected: accountManager.selectedAccountId == account.id,
                            onSelect: { accountManager.selectAccount(account) },
                            onDelete: { 
                                accountToDelete = account
                                showingDeleteAlert = true
                            }
                        )
                    }
                }
                .listStyle(PlainListStyle())
                
                // Add buttons
                HStack(spacing: 12) {
                    Button(action: { showingQRScanner = true }) {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Scan QR Code")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: { showingManualEntry = true }) {
                        HStack {
                            Image(systemName: "keyboard")
                            Text("Add Manually")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .frame(maxWidth: 700, maxHeight: 600)
        .sheet(isPresented: $showingQRScanner) {
            QRCodeEntryView(accountManager: accountManager)
        }
        .sheet(isPresented: $showingManualEntry) {
            ManualAccountEntryView(accountManager: accountManager)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Account"),
                message: Text(accountToDelete != nil ? "Are you sure you want to delete '\(accountToDelete!.displayName)'?" : ""),
                primaryButton: .destructive(Text("Delete")) {
                    if let account = accountToDelete {
                        accountManager.deleteAccount(account)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct AccountRowView: View {
    let account: Account
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .accentColor : .primary)
                
                if !account.issuer.isEmpty {
                    Text(account.issuer)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Text("\(account.digits) digits")
                    Text("•")
                    Text("\(account.period)s")
                    Text("•")
                    Text(account.algorithm)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

struct ManualAccountEntryView: View {
    @ObservedObject var accountManager: AccountManager
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var issuer = ""
    @State private var secret = ""
    @State private var basePassword = ""
    @State private var useBasePassword = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Account Manually")
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
                .disabled(name.isEmpty || secret.isEmpty)
            }
            .padding()
            
            Divider()
            
            // Form
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Account Name")
                        .font(.headline)
                    TextField("Account Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Issuer (optional)")
                        .font(.headline)
                    TextField("Issuer (optional)", text: $issuer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Secret Key")
                        .font(.headline)
                    SecureField("Secret Key", text: $secret)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Use base password", isOn: $useBasePassword)
                    
                    if useBasePassword {
                        SecureField("Base password", text: $basePassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 300)
        .alert(isPresented: $showingError) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func addAccount() {
        guard !name.isEmpty, !secret.isEmpty else {
            errorMessage = "Name and secret are required"
            showingError = true
            return
        }
        
        let account = Account(
            id: UUID(),
            name: name,
            issuer: issuer,
            secret: secret,
            basePassword: basePassword,
            useBasePassword: useBasePassword
        )
        
        accountManager.addAccount(account)
        presentationMode.wrappedValue.dismiss()
    }
}
