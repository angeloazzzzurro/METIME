import AVFoundation

final class SoundscapeManager {
    static let shared = SoundscapeManager()
    private init() {}

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let mixer = AVAudioMixerNode()
    private var started = false

    func start(mood: PetMood) {
        if !started {
            setupGraph()
            setupSession()
            try? engine.start()
            started = true
        }
        transition(to: mood)
    }

    func transition(to mood: PetMood) {
        let filename: String
        switch mood {
        case .calm: filename = "ambient_calm"
        case .happy, .evolving: filename = "ambient_happy"
        case .anxious: filename = "ambient_anxious"
        case .sleepy: filename = "ambient_sleepy"
        case .sick: filename = "ambient_sick"
        }
        playLoop(named: filename)
    }

    func playBell() {
        guard let url = Bundle.main.url(forResource: "gentle_bell", withExtension: "caf"),
              let file = try? AVAudioFile(forReading: url),
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) else { return }
        try? file.read(into: buffer)
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying { player.play() }
    }

    private func setupGraph() {
        engine.attach(player)
        engine.attach(mixer)
        engine.connect(player, to: mixer, format: nil)
        engine.connect(mixer, to: engine.mainMixerNode, format: nil)
        mixer.outputVolume = 0.6
    }

    private func setupSession() {
        let s = AVAudioSession.sharedInstance()
        try? s.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? s.setActive(true)
    }

    private func playLoop(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a"),
              let file = try? AVAudioFile(forReading: url),
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length)) else { return }
        try? file.read(into: buffer)
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: [.loops], completionHandler: nil)
        player.play()
    }
}
