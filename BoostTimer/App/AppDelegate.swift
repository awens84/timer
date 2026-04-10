import AppKit
import SwiftUI

// MARK: - Custom Floating Panel

/// NSPanel subclass that accepts first mouse click without requiring activation.
/// This ensures buttons in the floating panel work on the first click,
/// even when another application is focused.
class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func resignKey() {
        super.resignKey()
        level = .floating
    }

    // Send mouse events directly without requiring activation first
    override func sendEvent(_ event: NSEvent) {
        super.sendEvent(event)
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: FloatingPanel!
    private var viewModel = TimerListViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permissions
        NotificationService.shared.requestPermission()

        // Create the SwiftUI content view
        let contentView = MainView(viewModel: viewModel)

        // Create floating panel
        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 420),
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .nonactivatingPanel,
                .fullSizeContentView
            ],
            backing: .buffered,
            defer: false
        )

        // Panel configuration
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.isMovableByWindowBackground = true
        panel.hasShadow = true

        // Keep visible when app loses focus (critical for always-on-top behavior)
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = true

        // Size constraints
        panel.minSize = NSSize(width: 260, height: 200)
        panel.maxSize = NSSize(width: 400, height: 800)

        // Set SwiftUI content
        let hostingView = NSHostingView(rootView: contentView)
        panel.contentView = hostingView

        // Position at top-right of screen
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.maxX - 320
            let y = screenFrame.maxY - 440
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.makeKeyAndOrderFront(nil)

        // Quit app only when the main panel is closed (not when sheets are dismissed)
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: panel,
            queue: .main
        ) { _ in
            NSApp.terminate(nil)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Return false — we handle quit manually via willCloseNotification on the panel.
        // Returning true here causes the app to quit when SwiftUI sheets are dismissed,
        // because macOS counts sheet dismissal as "last window closed".
        return false
    }
}
