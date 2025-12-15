import SwiftUI
import AppKit

@main
struct FinderHelperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status item in the menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            // Use a system icon. 'magnifyingglass' or 'folder' or something related.
            // 'bolt.circle' represents action/power.
            button.image = NSImage(systemSymbolName: "bolt.circle", accessibilityDescription: "FinderHelper")
        }
        
        setupMenu()
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        let iTermItem = NSMenuItem(title: "Open in iTerm", action: #selector(openInITerm), keyEquivalent: "i")
        menu.addItem(iTermItem)
        
        let antigravityItem = NSMenuItem(title: "Open in Antigravity", action: #selector(openInAntigravity), keyEquivalent: "a")
        menu.addItem(antigravityItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit FinderHelper", action: #selector(quitApp), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc func openInITerm() {
        if let path = FinderBridge.shared.getActiveFinderPath() {
            print("Opening in iTerm: \(path)")
            FinderBridge.shared.openInITerm(path: path)
        } else {
            showAlert(message: "Could not determine active Finder path. Make sure permissions are granted.")
        }
    }
    
    @objc func openInAntigravity() {
        if let path = FinderBridge.shared.getActiveFinderPath() {
            print("Opening in Antigravity: \(path)")
            FinderBridge.shared.openInAntigravity(path: path)
        } else {
            showAlert(message: "Could not determine active Finder path. Make sure permissions are granted.")
        }
    }
    
    func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
