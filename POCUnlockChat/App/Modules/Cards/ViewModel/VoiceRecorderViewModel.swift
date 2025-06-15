//
//  VoiceRecorderViewModel.swift
//  POCUnlockChat
//
//  Created by Yogi Rawat on 14/06/25.
//

import Foundation
import Combine

class VoiceRecorderViewModel: ObservableObject {
    
    @Published var isRecording = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var recordedURL: URL?
    @Published var recordings: [URL] = []
    @Published var recordedFiles: [URL] = []
    @Published var audioLevel: Float = 1.0
    @Published var barHeights: [CGFloat] = Array(repeating: 5, count: 20)
    @Published var isMinDurationReached = false
    @Published var didFinishMaxRecording = false

    let recorder = AudioRecorderLayer()
    private var cancellables = Set<AnyCancellable>()
    var onRecordingFinished: (() -> Void)?
    
    init() {
        
        recorder.$recordingSuccess
            .sink { [weak self] success in
                guard let self = self else { return }
                
                if success, let url = self.recorder.recordedURL {
                    print("Audio recorded")
                    self.recordedFiles.append(url)
                } else {
                    print("not saved")
                }
            }
            .store(in: &cancellables)
        
        recorder.$isRecording
            .receive(on: RunLoop.main)
            .assign(to: &$isRecording)
        
        recorder.$elapsedTime
            .receive(on: RunLoop.main)
            .assign(to: &$elapsedTime)
        
        recorder.$recordedURL
            .receive(on: RunLoop.main)
            .assign(to: &$recordedURL)
        
        recorder.$audioLevel
                .receive(on: RunLoop.main)
                .assign(to: &$audioLevel)
        
        recorder.$didFinishMaxRecording
            .receive(on: RunLoop.main)
            .assign(to: &$didFinishMaxRecording)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }

    func startRecording() {
        isMinDurationReached = false
        recorder.startAudioRecording()
    }
    
    func stopRecording() {
        recorder.stopRecording()
    }
    
    func deleteRecording(at index: Int) {
        let url = recordings[index]
        try? FileManager.default.removeItem(at: url)
        recordings.remove(at: index)
    }
    
    
    func updateWaveformForPlaying() {
        barHeights = (0..<20).map { _ in CGFloat.random(in: 10...50) }
    }

    func updateWaveformForRecording() {
        barHeights = (0..<20).map { _ in
            CGFloat.random(in: 10...(CGFloat(audioLevel) * 50))
        }
    }
    
    func resetWaveform() {
        barHeights = Array(repeating: 5, count: 20)
    }

}
