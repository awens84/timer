import AppKit
import SwiftUI

// MARK: - Custom Floating Panel

/// Borderless NSPanel subclass for the micro timer pill.
/// No title bar, no window buttons — just the SwiftUI content.
class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    override func resignKey() {
        super.resignKey()
        level = .floating
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: FloatingPanel!
    private var viewModel = TimerListViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationService.shared.requestPermission()

        let contentView = MainView(viewModel: viewModel)

        // Create borderless floating panel — small, no chrome
        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 64, height: 28),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        // Panel behavior
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false            // SwiftUI handles shadows
        panel.hidesOnDeactivate = false    // Stay visible when app loses focus
        panel.becomesKeyOnlyIfNeeded = true
        panel.isMovableByWindowBackground = true

        // Set SwiftUI content
        let hostingView = NSHostingView(rootView: contentView)
        panel.contentView = hostingView

        // Position at bottom-right of screen
        if let screen = NSScreen.main {
            let sf = screen.visibleFrame
            let x = sf.maxX - 90
            let y = sf.minY + 20
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.orderFrontRegardless()

        // Listen for resize requests from SwiftUI views
        NotificationCenter.default.addObserver(
            forName: .panelResize,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let size = notification.userInfo?["size"] as? NSSize else { return }
            self?.resizePanel(to: size)
        }
    }

    /// Resize panel keeping bottom-right corner anchored
    private func resizePanel(to size: NSSize) {
        let current = panel.frame
        let newFrame = NSRect(
            x: current.maxX - size.width,   // Keep right edge
            y: current.origin.y,             // Keep bottom edge
            width: size.width,
            height: size.height
        )
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            panel.animator().setFrame(newFrame, display: true)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
