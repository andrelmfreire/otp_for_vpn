import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var accountManager = AccountManager()
    private var menuBarManager = MenuBarManager()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Setup menu bar
        menuBarManager.setup(accountManager: accountManager)
        
        // Show in Applications but run primarily in menu bar
        NSApp.setActivationPolicy(.regular)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup if needed
    }
}
