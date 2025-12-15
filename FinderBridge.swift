import Foundation
import AppKit

class FinderBridge {
    static let shared = FinderBridge()
    
    private init() {}
    
    func getActiveFinderPath() -> String? {
        let appleScript = """
        tell application "Finder"
            try
                set theSelection to selection
                if theSelection is not {} then
                    set targetItem to item 1 of theSelection
                    -- Convert to text (HFS path) first to avoid alias coercion issues with some references
                    return POSIX path of (targetItem as text)
                else
                    try
                        set targetWindow to target of front window
                        return POSIX path of (targetWindow as text)
                    on error
                        return POSIX path of (path to desktop folder)
                    end try
                end if
            on error
                return POSIX path of (path to desktop folder)
            end try
        end tell
        """
        
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: appleScript) {
            let output = scriptObject.executeAndReturnError(&error)
            if let path = output.stringValue {
                // If the selected item is a file, we usually want its container folder script logic?
                // The prompt said "From a folder". If I select a file, user might expect the folder OF that file.
                // But current logic opens the file path itself in iTerm? iTerm usually handles a directory path.
                // If path is a file, 'cd /path/to/file' fails.
                // Let's check in Swift if it's a folder.
                return path
            }
        }
        
        if let err = error {
            print("AppleScript error: \(err)")
        }
        
        return nil
    }
    
    func openInITerm(path: String) {
        var path = path
        // Check if path is a directory, if not get parent
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            if !isDir.boolValue {
                path = (path as NSString).deletingLastPathComponent
            }
        }
        
        runShellCommand("open -a iTerm \(path.quoted)")
    }
    
    func openInAntigravity(path: String) {
        // Antigravity might also expect a folder
        var path = path
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            if !isDir.boolValue {
                path = (path as NSString).deletingLastPathComponent
            }
        }
        
        // Assuming Antigravity is an installed Application
        runShellCommand("open -a Antigravity \(path.quoted)")
    }
    
    private func runShellCommand(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]
        task.launch()
    }
}

extension String {
    var quoted: String {
        return "'" + self.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
