import SwiftUI

@main
struct BoostTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Window is managed by AppDelegate (NSPanel)
        // Settings scene is a placeholder to satisfy Scene protocol
        Settings {
            EmptyView()
        }
    }
}
