import SwiftUI
import AppKit

class MenuBarManager: ObservableObject {
    @Published var isMenuBarVisible = false
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var accountManager: AccountManager?
    
    func setup(accountManager: AccountManager) {
        self.accountManager = accountManager
        
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "key.fill", accessibilityDescription: "OTP Authenticator")
            button.action = #selector(toggleMenuBar)
            button.target = self
        }
        
        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarView(accountManager: accountManager))
    }
    
    @objc private func toggleMenuBar() {
        guard let popover = popover, let button = statusItem?.button else { return }
        
        if popover.isShown {
            popover.performClose(nil)
            isMenuBarVisible = false
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            isMenuBarVisible = true
        }
    }
    
    func hideMenuBar() {
        popover?.performClose(nil)
        isMenuBarVisible = false
    }
}
