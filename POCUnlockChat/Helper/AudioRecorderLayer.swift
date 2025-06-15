//
//  AudioRecorderLayer.swift
//  POCUnlockChat
//
//  Created by Yogi Rawat on 14/06/25.
//

import Foundation
import AVFoundation
import Combine

class AudioRecorderLayer: NSObject, ObservableObject, AVAudioRecorderDelegate {
    
    // PROPERTIES
    private var audioRecorder: AVAudioRecorder?
    private let session = AVAudioSession.sharedInstance()
    
    @Published var isRecording = false
    @Published var recordedURL: URL?
    @Published var elapsedTime: TimeInterval = 0
    @Published var recordingSuccess: Bool = false
    @Published var audioLevel: Float = 0.0
    
    private var cancellable: AnyCancellable?
    
    let maxDuration: TimeInterval = 3 * 60
    let minDuration: TimeInterval = 5
    
    func startAudioRecording() {
        stopRecording()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to setup session: \(error.localizedDescription)")
            return
        }
        
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = directory.appendingPathComponent("recording.m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            recordedURL = fileURL
            isRecording = true
            startTimer()
        } catch {
            print("Recording failed: \(error.localizedDescription)")
        }
    }
    
    private func startTimer() {
        elapsedTime = 0
        cancellable = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.audioRecorder?.updateMeters()
                self.elapsedTime += 0.05

                if let level = self.audioRecorder?.averagePower(forChannel: 0) {
                    let normalized = max(0.0, min(1.0, (level + 160) / 160))
                    self.audioLevel = normalized
                }

                if self.elapsedTime >= self.maxDuration {
                    self.stopRecording()
                }
            }
    }

    
    func stopRecording() {
        audioRecorder?.stop()
        print("Audio file saved at: \(audioRecorder?.url)")
        print("File exists: \(FileManager.default.fileExists(atPath: audioRecorder?.url.path.description ?? ""))")

        cancellable?.cancel()
        isRecording = false
    }
}

extension AudioRecorderLayer {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print(flag ? "Audio recorded successfully" : "Recording failed")
        recordingSuccess = flag

        guard let url = recordedURL else { return }

        let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
        print("Recorded file size: \(fileSize) bytes")

        if elapsedTime < minDuration {
            try? FileManager.default.removeItem(at: url)
            recordedURL = nil
            print("Recording deleted — too short (\(elapsedTime)s)")
        } else {
            print("Recording saved at: \(url)")
        }
    }

    func canPlayRecording() -> Bool {
        guard let url = recordedURL else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func getAudioFileURL() -> URL? {
        return recordedURL
    }
}
