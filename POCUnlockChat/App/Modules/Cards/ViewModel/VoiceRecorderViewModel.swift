//
//  VoiceRecorderViewModel.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 14/06/25.
//

import Combine
import Foundation

class VoiceRecorderViewModel: ObservableObject {
    
    @Published var recordedURL: URL?
    @Published var recordings: [URL] = []
    @Published var audioLevel: Float = 1.0
    @Published var recordedFiles: [URL] = []
    @Published var elapsedTime: TimeInterval = 0
    @Published var state: RecorderState = .readyToRecording
    @Published var barHeights: [CGFloat] = Array(repeating: 5, count: 20)
    
    @Published var isPlaying: Bool = false
    @Published var isRecording: Bool = false
    @Published var hasStartedRecording = false
    @Published var playerDuration: Double = 0.0
    @Published var recordingDuration: Double = 0.0
  
    @Published var canStopRecording: Bool = false
    @Published var isRecordingCompleted: Bool = false
    @Published var didFinishMaxRecording: Bool = false

    let player = AudioPlayerManager()
    let recorder = AudioRecorderLayer()
    var onRecordingFinished: (() -> Void)?
    private var cancellables = Set<AnyCancellable>()
    private var playbackTimer: AnyCancellable?

    private var progressTimer: Timer?
    private var waveformTimer: Timer?
    
    var iconName: String {
        switch state {
        case .readyToRecording: return "audio-record"
        case .recording: return "recording-stop"
        case .recordingFinished, .paused, .playbackFinished: return "audio-play"
        case .playing: return "audio-pause"
        }
    }
    
    init()  {
        recorder.$recordingSuccess
            .sink { [weak self] success in
                guard let self = self else { return }
                if success, let url = self.recorder.recordedURL {
                    print("Audio recorded")
                    self.recordedFiles.append(url)
                    self.recordedURL = url
                    self.state = .recordingFinished
                    self.stopWaveformAnimation()
                    self.stopProgressTimer()
                } else {
                    print("Recording failed")
                }
            }
            .store(in: &cancellables)
        
        recorder.$isRecording
            .sink { [weak self] isRecording in
                guard let self = self else { return }
                self.state = isRecording ? .recording : .readyToRecording
                self.isRecording = isRecording
            }
            .store(in: &cancellables)
        
        recorder.$elapsedTime
            .receive(on: RunLoop.main)
            .assign(to: &$elapsedTime)
        
        recorder.$audioLevel
            .receive(on: RunLoop.main)
            .assign(to: &$audioLevel)
        
        recorder.$didFinishMaxRecording
            .sink { [weak self] didFinish in
                guard let self = self else { return }
                if didFinish {
                    self.state = .recordingFinished
                    self.stopWaveformAnimation()
                    self.stopProgressTimer()
                }
            }
            .store(in: &cancellables)
        
        player.onPlaybackEnded = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.state = .playbackFinished
                self.stopPlayback()
                self.stopWaveformAnimation()
            }
        }
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
        stopProgressTimer()
        stopWaveformAnimation()
    }
    
    func startRecording() {
        guard state != .playing else { return }
        recorder.startAudioRecording()
        state = .recording
        canStopRecording = false
        startProgressTimer()
        startWaveformAnimation()
        hasStartedRecording = true
    }
    
    func stopRecording() {
        guard canStopRecording else { return }
        recorder.stopRecording()
        state = .recordingFinished
        stopProgressTimer()
        stopWaveformAnimation()
    }
    
    func cleanupAudioSession() {
        stopRecording()
        player.stopAudio()
        recorder.stopRecording()
        stopProgressTimer()
        stopWaveformAnimation()
        resetWaveform()
        state = .readyToRecording
        canStopRecording = false
        recordedURL = nil
    }
    
    func startPlayback() {
        guard let url = recordedURL else { return }
        player.playAudio(url: url)
        state = .playing
        self.isPlaying = true
        startWaveformAnimation()
        
        playbackTimer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.elapsedTime = self.player.audioPlayer?.currentTime ?? 0
            }
    }
    
    func stopPlayback() {
        player.stopAudio()
        state = .paused
        stopWaveformAnimation()
        
        playbackTimer?.cancel()
        playbackTimer = nil
    }
    
    func deleteRecording(at index: Int) {
        let url = recordings[index]
        try? FileManager.default.removeItem(at: url)
        recordings.remove(at: index)
    }
    
    func updateWaveform() {
        switch state {
        case .recording:
            let maxHeight = max(CGFloat(audioLevel) * 50, 10)
            barHeights = (0..<20).map { _ in CGFloat.random(in: 10...maxHeight) }
        case .playing:
            barHeights = (0..<20).map { _ in CGFloat.random(in: 10...50) }
        default:
            resetWaveform()
        }
    }
    
    func resetWaveform() {
        barHeights = Array(repeating: 5, count: 20)
    }
    
    private func startProgressTimer() {
        stopProgressTimer()
        var elapsed = 0.0
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            elapsed += 0.1
            if elapsed >= self.recorder.minDuration {
                self.canStopRecording = true
                timer.invalidate()
            }
        }
    }
    
    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    private func startWaveformAnimation() {
        stopWaveformAnimation()
        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateWaveform()
        }
    }
    
    private func stopWaveformAnimation() {
        waveformTimer?.invalidate()
        waveformTimer = nil
        resetWaveform()
    }
}
