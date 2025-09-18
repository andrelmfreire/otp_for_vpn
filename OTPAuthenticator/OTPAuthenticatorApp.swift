import SwiftUI

@main
struct OTPAuthenticatorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, maxWidth: 500, minHeight: 300, maxHeight: 400)
        }
        .windowStyle(.hiddenTitleBar)
    }
} 