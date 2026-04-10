import Foundation
import Observation

@Observable
class TimerListViewModel {
    var timers: [TimerItem] = []
    var showingAddSheet = false
    var showingSettings = false

    // MARK: - Timer Management

    func addTimer(name: String, seconds: Int) {
        let defaults = UserDefaults.standard
        let threshold = defaults.object(forKey: "warningThreshold") != nil
            ? defaults.integer(forKey: "warningThreshold")
            : 180

        let timer = TimerItem(
            name: name,
            totalSeconds: seconds,
            warningThreshold: max(threshold, 10)
        )
        timers.append(timer)
    }

    func removeTimer(_ timer: TimerItem) {
        timer.reset() // Invalidate internal timer
        timers.removeAll { $0.id == timer.id }
    }

    func resetAll() {
        for timer in timers {
            timer.reset()
        }
    }

    // MARK: - Computed

    var activeTimersCount: Int {
        timers.filter { $0.isActive }.count
    }

    var hasTimers: Bool {
        !timers.isEmpty
    }
}
