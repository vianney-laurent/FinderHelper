import Cocoa
import Carbon

class HotKeyManager {
    static let shared = HotKeyManager()
    
    // Expose Carbon constants
    static let carbonCommandKey = cmdKey
    static let carbonOptionKey = optionKey
    
    // Check type of eventHandler needed.
    // EventHandlerRef is an OpaquePointer.
    private var eventHandler: EventHandlerRef?
    
    // Map ID -> Action
    private var hotKeyActions: [UInt32: () -> Void] = [:]
    private var currentId: UInt32 = 0
    
    private init() {
        installEventHandler()
    }
    
    func registerHotKey(keyCode: Int, modifiers: Int, action: @escaping () -> Void) {
        let id = currentId
        currentId += 1
        
        hotKeyActions[id] = action
        
        let hotKeyID = EventHotKeyID(signature: OSType(1752460081), id: id) // 'hmgr' signature
        
        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(UInt32(keyCode),
                                         UInt32(modifiers),
                                         hotKeyID,
                                         GetApplicationEventTarget(),
                                         0,
                                         &hotKeyRef)
        
        if status != noErr {
            print("Failed to register hotkey: \(status)")
        } else {
             print("Registered hotkey ID: \(id)")
        }
    }
    
    private func installEventHandler() {
        let eventSpec = [
            EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        ]
        
        // We need a C callback. Swift closures can't be directly passed as C function pointers easily if they capture context,
        // but `InstallEventHandler` takes a function pointer.
        // We will define a global function or a static function for the callback.
        
        InstallEventHandler(GetApplicationEventTarget(),
                            GlobalHotKeyHandler,
                            1,
                            eventSpec,
                            UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                            &eventHandler)
    }
    
    func handleHotKey(id: UInt32) {
        if let action = hotKeyActions[id] {
            DispatchQueue.main.async {
                action()
            }
        }
    }
}

// Global C-function for the callback
func GlobalHotKeyHandler(handler: EventHandlerCallRef?, event: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
    guard let event = event else { return OSStatus(eventNotHandledErr) }
    
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(event,
                                   EventParamName(kEventParamDirectObject),
                                   EventParamType(typeEventHotKeyID),
                                   nil,
                                   MemoryLayout<EventHotKeyID>.size,
                                   nil,
                                   &hotKeyID)
    
    if status != noErr {
        return status
    }
    
    if let userData = userData {
        let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
        manager.handleHotKey(id: hotKeyID.id)
    }
    
    return noErr
}

// Helper constants for keys
enum KeyCode {
    static let i = 34
    static let a = 0
}

enum CarbonModifiers {
    static let cmd = cmdKey
    static let option = optionKey
}
