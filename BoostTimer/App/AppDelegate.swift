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
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NotificationService.shared.requestPermission()

        setupStatusBar()
        setupPanel()

        // Listen for resize requests from SwiftUI views
        NotificationCenter.default.addObserver(
            forName: .panelResize,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let size = notification.userInfo?["size"] as? NSSize else { return }
            self?.resizePanel(to: size)
        }

        // Listen for opacity changes from Settings
        NotificationCenter.default.addObserver(
            forName: .panelOpacityChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let opacity = notification.userInfo?["opacity"] as? Double else { return }
            self?.panel.animator().alphaValue = CGFloat(opacity)
        }

        // Apply saved opacity on launch
        let savedOpacity = UserDefaults.standard.double(forKey: "panelOpacity")
        panel.alphaValue = savedOpacity > 0 ? CGFloat(savedOpacity) : 0.85
    }

    // MARK: - Status Bar

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "bolt.fill", accessibilityDescription: "Boost Timer")
            button.image?.size = NSSize(width: 14, height: 14)
            button.action = #selector(statusBarClicked)
            button.target = self
            // Right-click sends same action on macOS, we'll use a menu for right-click
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func statusBarClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            // Right-click: show context menu
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: "Показать/Скрыть", action: #selector(togglePanel), keyEquivalent: ""))
            menu.addItem(.separator())
            menu.addItem(NSMenuItem(title: "Добавить таймер", action: #selector(addTimer), keyEquivalent: "n"))
            menu.addItem(NSMenuItem(title: "Настройки", action: #selector(openSettings), keyEquivalent: ","))
            menu.addItem(.separator())
            menu.addItem(NSMenuItem(title: "Выход", action: #selector(quitApp), keyEquivalent: "q"))
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            // Reset menu so left-click works again
            DispatchQueue.main.async { [weak self] in
                self?.statusItem.menu = nil
            }
        } else {
            // Left-click: toggle panel visibility
            togglePanel()
        }
    }

    @objc private func togglePanel() {
        if panel.isVisible {
            panel.orderOut(nil)
        } else {
            panel.orderFrontRegardless()
        }
    }

    @objc private func addTimer() {
        viewModel.expandedScreen = .addTimer
        viewModel.isExpanded = true
        panel.orderFrontRegardless()
        // Trigger resize
        NotificationCenter.default.post(
            name: .panelResize,
            object: nil,
            userInfo: ["size": NSSize(width: 200, height: 310)]
        )
    }

    @objc private func openSettings() {
        viewModel.expandedScreen = .settings
        viewModel.isExpanded = true
        panel.orderFrontRegardless()
        NotificationCenter.default.post(
            name: .panelResize,
            object: nil,
            userInfo: ["size": NSSize(width: 200, height: 490)]
        )
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    // MARK: - Panel Setup

    private func setupPanel() {
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
            let y = sf.minY + 50
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.orderFrontRegardless()
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
