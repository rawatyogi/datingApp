//
//  AudioPlayerManager.swift
//  POCUnlockChat
//
//  Created by Yogi Rawat on 15/06/25.
//

import Foundation
import AVFoundation

class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var isPlaying = false
    
     var audioPlayer: AVAudioPlayer?
     var onPlaybackEnded: (() -> Void)?
    
    func playAudio(url: URL) {
        stopAudio()
        
        print("Trying to play file at: \(url.path)")
        print("File exists: \(FileManager.default.fileExists(atPath: url.path))")

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            DispatchQueue.main.async {
                self.isPlaying = true
            }

        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    
    func pauseAudio() {
        audioPlayer?.pause()
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
         onPlaybackEnded?()
    }
}
