import Foundation
import Observation

// MARK: - Timer State

enum TimerState: Equatable {
    case idle
    case running
    case paused
    case warning
    case finished
}

// MARK: - Timer Item Model

@Observable
class TimerItem: Identifiable {
    let id = UUID()
    var name: String
    var totalSeconds: Int
    var remainingSeconds: Int
    var state: TimerState = .idle
    var warningThresholdSeconds: Int

    @ObservationIgnored private var internalTimer: Timer?
    @ObservationIgnored private var lastTickDate: Date?

    init(name: String, totalSeconds: Int, warningThreshold: Int = 180) {
        self.name = name
        self.totalSeconds = totalSeconds
        self.remainingSeconds = totalSeconds
        self.warningThresholdSeconds = warningThreshold
    }

    // MARK: - Computed Properties

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(remainingSeconds) / Double(totalSeconds)
    }

    var displayTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var isActive: Bool {
        state == .running || state == .warning
    }

    // MARK: - Actions

    func start() {
        guard state == .idle || state == .paused else { return }

        // Determine initial state based on remaining time
        if remainingSeconds <= warningThresholdSeconds && remainingSeconds > 0 {
            state = .warning
        } else {
            state = .running
        }

        lastTickDate = Date()

        // Use Timer without scheduledTimer to add to .common mode
        // This ensures the timer fires even during UI interactions like window dragging
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer, forMode: .common)
        internalTimer = timer
    }

    func pause() {
        guard state == .running || state == .warning else { return }
        state = .paused
        internalTimer?.invalidate()
        internalTimer = nil
    }

    func reset() {
        internalTimer?.invalidate()
        internalTimer = nil
        remainingSeconds = totalSeconds
        state = .idle
    }

    func toggleStartPause() {
        switch state {
        case .idle, .paused:
            start()
        case .running, .warning:
            pause()
        case .finished:
            reset()
        }
    }

    // MARK: - Timer Tick

    private func tick() {
        guard let lastTick = lastTickDate else { return }
        let now = Date()
        let elapsed = now.timeIntervalSince(lastTick)

        guard elapsed >= 1.0 else { return }

        lastTickDate = now
        remainingSeconds = max(0, remainingSeconds - 1)

        if remainingSeconds <= 0 {
            // Timer finished
            state = .finished
            internalTimer?.invalidate()
            internalTimer = nil
            SoundService.shared.playFinish()
            NotificationService.shared.send(
                title: "⏰ Boost Timer",
                body: "\"\(name)\" — время вышло!"
            )
        } else if remainingSeconds <= warningThresholdSeconds && state == .running {
            // Entered warning zone
            state = .warning
            SoundService.shared.playWarning()
        }
    }

    deinit {
        internalTimer?.invalidate()
    }
}
