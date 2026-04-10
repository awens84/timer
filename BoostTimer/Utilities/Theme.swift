import SwiftUI

// MARK: - Timer State Colors

extension Color {
    /// Accent color for idle/running timers
    static let timerAccent = Color.cyan

    /// Warning color when timer is below threshold
    static let timerWarning = Color.orange

    /// Finished color when timer reaches zero
    static let timerFinished = Color.red
}

// MARK: - Timer State Color Helper

extension TimerState {
    /// The display color for this timer state
    var color: Color {
        switch self {
        case .idle, .paused:
            return .timerAccent.opacity(0.7)
        case .running:
            return .timerAccent
        case .warning:
            return .timerWarning
        case .finished:
            return .timerFinished
        }
    }

    /// Whether this state should show alert animations (pulsing, glow)
    var isAlert: Bool {
        self == .warning || self == .finished
    }
}
