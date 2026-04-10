import AppKit

/// Service for playing system sounds. Uses macOS built-in sounds —
/// no need to bundle custom audio files.
class SoundService {
    static let shared = SoundService()

    /// Available macOS system sounds
    static let availableSounds = [
        "Basso", "Blow", "Bottle", "Frog", "Funk",
        "Glass", "Hero", "Morse", "Ping", "Pop",
        "Purr", "Sosumi", "Submarine", "Tink"
    ]

    private init() {}

    // MARK: - Sound Enabled Check

    /// Sound is enabled by default. If the key hasn't been set, treat as enabled.
    private var isSoundEnabled: Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "soundEnabled") == nil {
            return true
        }
        return defaults.bool(forKey: "soundEnabled")
    }

    // MARK: - Playback

    /// Play a system sound by name
    func play(_ soundName: String) {
        guard isSoundEnabled else { return }
        NSSound(named: NSSound.Name(soundName))?.play()
    }

    /// Play the warning chime (configurable in settings, default: Glass)
    func playWarning() {
        let soundName = UserDefaults.standard.string(forKey: "warningSound") ?? "Glass"
        play(soundName)
    }

    /// Play the finish alert (configurable in settings, default: Hero)
    func playFinish() {
        let soundName = UserDefaults.standard.string(forKey: "finishSound") ?? "Hero"
        play(soundName)
    }
}
