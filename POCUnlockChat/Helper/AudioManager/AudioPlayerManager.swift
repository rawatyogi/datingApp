//
//  AudioPlayerManager.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 15/06/25.
//

import Foundation
import AVFoundation
import Combine

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
    private var timer: AnyCancellable?
    var audioPlayer: AVAudioPlayer?
    var onPlaybackEnded: (() -> Void)?
    
    func playAudio(url: URL) {
        stopAudio()
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            duration = audioPlayer?.duration ?? 0
            
            startTimer()
            
            DispatchQueue.main.async {
                self.isPlaying = true
            }
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func pauseAudio() {
        audioPlayer?.pause()
        stopTimer()
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        stopTimer()
        audioPlayer = nil
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentTime = 0
            self.duration = 0
        }
    }
    
    func resumeAudio() {
        guard let player = audioPlayer, !player.isPlaying else { return }
        player.play()
        startTimer()
        DispatchQueue.main.async {
            self.isPlaying = true
        }
    }
    
    private func startTimer() {
        stopTimer()
      
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let player = self.audioPlayer else { return }
                DispatchQueue.main.async {
                    self.currentTime = player.currentTime
                }
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isPlaying = false
        stopTimer()
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentTime = 0
        }
        onPlaybackEnded?()
    }
}
