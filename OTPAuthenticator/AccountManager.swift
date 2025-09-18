import Foundation
import SwiftUI

class AccountManager: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var selectedAccountId: UUID?
    
    private let accountsKey = "savedAccounts"
    private let selectedAccountKey = "selectedAccountId"
    
    init() {
        loadAccounts()
        loadSelectedAccount()
    }
    
    var selectedAccount: Account? {
        guard let selectedId = selectedAccountId else { return nil }
        return accounts.first { $0.id == selectedId }
    }
    
    func addAccount(_ account: Account) {
        accounts.append(account)
        saveAccounts()
        
        // Auto-select if this is the first account
        if accounts.count == 1 {
            selectedAccountId = account.id
            saveSelectedAccount()
        }
    }
    
    func updateAccount(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
            saveAccounts()
        }
    }
    
    func deleteAccount(_ account: Account) {
        accounts.removeAll { $0.id == account.id }
        saveAccounts()
        
        // If we deleted the selected account, select another one
        if selectedAccountId == account.id {
            selectedAccountId = accounts.first?.id
            saveSelectedAccount()
        }
    }
    
    func selectAccount(_ account: Account) {
        selectedAccountId = account.id
        saveSelectedAccount()
    }
    
    private func saveAccounts() {
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: accountsKey)
        }
    }
    
    private func loadAccounts() {
        if let data = UserDefaults.standard.data(forKey: accountsKey),
           let decoded = try? JSONDecoder().decode([Account].self, from: data) {
            accounts = decoded
        }
    }
    
    private func saveSelectedAccount() {
        if let selectedId = selectedAccountId {
            UserDefaults.standard.set(selectedId.uuidString, forKey: selectedAccountKey)
        } else {
            UserDefaults.standard.removeObject(forKey: selectedAccountKey)
        }
    }
    
    private func loadSelectedAccount() {
        if let uuidString = UserDefaults.standard.string(forKey: selectedAccountKey),
           let uuid = UUID(uuidString: uuidString) {
            selectedAccountId = uuid
        }
    }
}
