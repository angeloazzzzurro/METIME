import AVFoundation

final class SoundscapeManager {
    static let shared = SoundscapeManager()
    private init() {}

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let mixer  = AVAudioMixerNode()
    private var started = false

    // MARK: - Public API

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
        let track = AudioResource.Ambient.track(for: mood)
        playLoop(resource: track)
    }

    func playBell() {
        let sfx = AudioResource.SFX.gentleBell
        guard let url = Bundle.main.url(forResource: sfx.rawValue,
                                        withExtension: AudioResource.SFX.ext),
              let file = try? AVAudioFile(forReading: url),
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
                                            frameCapacity: AVAudioFrameCount(file.length))
        else { return }

        try? file.read(into: buffer)
        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        if !player.isPlaying { player.play() }
    }

    // MARK: - Private

    private func setupGraph() {
        engine.attach(player)
        engine.attach(mixer)
        engine.connect(player, to: mixer, format: nil)
        engine.connect(mixer, to: engine.mainMixerNode, format: nil)
        mixer.outputVolume = 0.6
    }

    private func setupSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func playLoop(resource: AudioResource.Ambient) {
        guard let url = Bundle.main.url(forResource: resource.rawValue,
                                        withExtension: AudioResource.Ambient.ext),
              let file = try? AVAudioFile(forReading: url),
              let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat,
                                            frameCapacity: AVAudioFrameCount(file.length))
        else { return }

        try? file.read(into: buffer)
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: [.loops], completionHandler: nil)
        player.play()
    }
}
