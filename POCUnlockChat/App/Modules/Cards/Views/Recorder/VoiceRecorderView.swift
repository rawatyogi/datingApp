//
//  VoiceRecorderView.swift
//  POCUnlockChat
//
//  Created by Yogi Rawat on 14/06/25.
//
import SwiftUI

struct VoiceRecorderView: View {
    
    @State private var selectedIndex = 0
    @State private var userPhotos = [String]()
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = VoiceRecorderViewModel()
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    
    @State private var isRecording = false
    @State private var isSubmitted = false
    @State private var isPlaying = false
    @State private var showSubmissionAlert = false
    @State private var canStopRecording = false
    
    @State private var recordingDuration = 0.0
    @State private var playerDuration = 0.0
    @State private var timer: Timer? = nil
    @State private var waveformTimer: Timer? = nil
    @State private var waveformLevel: CGFloat = 0.0
    @State private var isRecordingCompleted = false

    var selectedCard: CardsModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                
                //--------------------------//
                TabView(selection: $selectedIndex) {
                    ForEach(0..<userPhotos.count, id: \.self) { index in
                        Image(userPhotos[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: Color.black, location: 0.0),
                                        .init(color: Color.black, location: 0.05),
                                        .init(color: Color.black, location: 0.32),
                                        .init(color: Color.black.opacity(0.35), location: 0.45),
                                        .init(color: Color.black.opacity(0.2), location: 0.5)
                                    ]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .ignoresSafeArea()
                    }
                }
                
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
                
                //--------------------------//
                VStack {
                    pageIndicatorView(geo: geo)
                    headerView(geo: geo)
                    Spacer()
                    VStack(spacing: 0) {
                        questionView(geo: geo)
                        timerAndLineView(geo: geo)
                            .padding(.top, geo.size.height * 0.06)
                        audioControls(geo: geo)
                            .padding(.top, geo.size.height * 0.06)
                        unmatchButton
                    }
                    .padding(.bottom, geo.safeAreaInsets.bottom + 30)
                }
                .padding(.horizontal, 15)
                .padding(.top, geo.size.height * 0.05)
            }
            .onAppear {
                self.userPhotos = self.selectedCard.uplaodedImages
                viewModel.onRecordingFinished = {
//                        DispatchQueue.main.async {
//                            stopWaveformAnimation()
//                            isRecording = false
//                            isRecordingCompleted = true
//                            isPlaying = false
//                        }
                    }
            }
            .onReceive(viewModel.$didFinishMaxRecording) { finished in
                if finished {
                 
                    viewModel.didFinishMaxRecording = false
                    stopWaveformAnimation()
                    isRecording = false
                    isRecordingCompleted = true
                    isPlaying = false
                }
            }
        }
        .alert("Your recording submitted successfully!", isPresented: $showSubmissionAlert) {
            Button("OK", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: Header View
    func headerView(geo: GeometryProxy) -> some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                cleanupAudioSession()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(geo.size.width * 0.025)
                    .background(.black.opacity(0.4))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("\(self.selectedCard.name), \(self.selectedCard.age)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#FFFFFF"))
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(geo.size.width * 0.025)
                    .background(.black.opacity(0.4))
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: Page Indicator
    func pageIndicatorView(geo: GeometryProxy) -> some View {
        HStack(spacing: 5) {
            ForEach(0..<userPhotos.count, id: \.self) { index in
                Rectangle()
                    .fill(index <= selectedIndex ? Color.white : Color.white.opacity(0.4))
                    .frame(height: 4)
                    .cornerRadius(2)
            }
        }
        .padding(.top, geo.size.height * 0.016)
    }
    
    // MARK: Question View
    func questionView(geo: GeometryProxy) -> some View {
        VStack(spacing: geo.size.height * 0.015) {
            
            VStack(spacing: -geo.size.height * 0.11) {
                
                Text("Stroll question")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "#FFFFFF"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#121518"))
                    .cornerRadius(12)
                
                ZStack {
                    Circle()
                        .fill(.red)
                        .frame(width: geo.size.width * 0.18)
                    Image(self.selectedCard.uplaodedImages.first ?? "")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width * 0.16, height: geo.size.width * 0.16)
                        .clipShape(Circle())
                }
            }
            
            VStack(spacing: 10) {
                Text(self.selectedCard.question)
                    .font(.system(size: geo.size.width * 0.055))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "#F5F5F5"))
                    .multilineTextAlignment(.center)
                
                Text(self.selectedCard.answer)
                    .font(.system(size: geo.size.width * 0.035).italic())
                    .foregroundColor(Color(hex: "##CBC9FF").opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 15)
            .padding(.top,geo.size.height * 0.03)
        }
    }
    
    // MARK: Timer + Line View
    func timerAndLineView(geo: GeometryProxy) -> some View {
        VStack(spacing: geo.size.height * 0.032) {
            Text(isPlaying
                 ? "\(playerDuration.stringFormatted()) / \(audioPlayerManager.audioPlayer?.duration.stringFormatted() ?? "00:00")"
                 : viewModel.elapsedTime.stringFormatted())
            .font(.footnote)
            .foregroundColor(Color(hex: "#AEADAF"))

                .font(.footnote)
                .foregroundColor(Color(hex: "#AEADAF"))
            
            WaveformView(isRecording: isRecording, isPlaying: isPlaying, barHeights: viewModel.barHeights)
                .frame(height: 30)
                .padding(.horizontal, geo.size.width * 0.1)
            
        }
    }
    
    // MARK: Audio Controls
    func audioControls(geo: GeometryProxy) -> some View {
        HStack(spacing: geo.size.width * 0.12) {
            Button("Delete") {
                cleanupAudioSession()
                presentationMode.wrappedValue.dismiss()
                viewModel.stopRecording()
            }
            .font(.body)
            .foregroundColor(viewModel.elapsedTime >= viewModel.recorder.minDuration ? .white : Color(hex: "#5C6770"))
            .disabled(viewModel.elapsedTime < viewModel.recorder.minDuration || isSubmitted)
            
            
            ZStack {
                if !self.isPlaying && !self.isSubmitted {
                    if viewModel.elapsedTime < viewModel.recorder.minDuration {
                        RecordingProgressView(progress: min(viewModel.elapsedTime / viewModel.recorder.minDuration, 1.0), geo: geo)
                    }
                }
                
                Button {
                    if isSubmitted {
                           startPlayer()
                       } else if isRecording {
                           if canStopRecording {
                               viewModel.stopRecording()
                               stopRecording()
                               isRecording = false
                               isRecordingCompleted = true
                           }
                       } else if isRecordingCompleted {
                           startPlayer()
                       } else {
                           viewModel.startRecording()
                           isRecording = true
                           isRecordingCompleted = false
                           startRecording()
                       }

                } label: {
                    Image(iconName())
                        .resizable()
                        .frame(width:  geo.size.width * 0.12, height:  geo.size.width * 0.12)
                        .padding()
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
                .disabled(isRecording && !canStopRecording)
                .opacity(isRecording && !canStopRecording ? 0.5 : 1)
            }
            
            
            Button("Submit") {
                 submitRecording()
            }

            .font(.body)
            .foregroundColor(viewModel.elapsedTime >= viewModel.recorder.minDuration ? .white : Color(hex: "#5C6770"))
            .disabled(viewModel.elapsedTime < viewModel.recorder.minDuration || isSubmitted)
            
        }
    }
    
    // MARK: Unmatch Button
    var unmatchButton: some View {
        Button("Unmatch") {
            cleanupAudioSession()
            presentationMode.wrappedValue.dismiss()
        }
        .font(.body)
        .foregroundColor(Color(hex: "#BE2020"))
        .padding(.vertical, 20)
    }
}


extension VoiceRecorderView {
    func iconName() -> String {
        if isSubmitted {
              return isPlaying ? "audio-pause" : "audio-play"
          } else if isRecording {
              return "recording-stop"
          } else if isRecordingCompleted {
              return isPlaying ? "audio-pause" : "audio-play"
          } else {
              return "audio-record"
          }
    }
    
    func getAudioFileURL() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("recording.m4a")
    }
    
    func startRecording() {
        isRecordingCompleted = false
        isRecording = true
        startRecordingTimer()
        startWaveformAnimation()
    }
    
    func stopRecording() {
        isRecording = false
        stopRecordingTimer()
        stopWaveformAnimation()
    }
    
    func submitRecording() {
        
        cleanupAudioSession()
        
//        viewModel.resetWaveform()
//        stopRecording()
//        stopWaveformAnimation()
//        stopPlayerTimer()
//        stopRecordingTimer()
//
//        playerDuration = 0
//        recordingDuration = 0
//        isPlaying = false
//        waveformLevel = 0.0
//
//        viewModel.stopRecording()
//        viewModel.elapsedTime = 0
//        viewModel.audioLevel = 0.0
//
//        isSubmitted = true
        showSubmissionAlert = true
    }

    
    func startPlayer() {
        if let player = audioPlayerManager.audioPlayer {
            if player.isPlaying {
                pausePlayer()
            } else {
                player.play()
                startPlayerTimer()
                isPlaying = true
                startWaveformAnimation()
            }
        } else if let url = getAudioFileURL() {
            audioPlayerManager.playAudio(url: url)
            startPlayerTimer()
            isPlaying = true
            startWaveformAnimation()
            audioPlayerManager.onPlaybackEnded = {
                stopPlayerTimer()
                viewModel.resetWaveform()
                stopWaveformAnimation()
                isPlaying = false
                playerDuration = 0
            }
        }
    }

    func pausePlayer() {
        audioPlayerManager.pauseAudio()
        stopPlayerTimer()
        stopWaveformAnimation()
        isPlaying = false
    }

    
    func startRecordingTimer() {
        timer?.invalidate()
        recordingDuration = 0
        canStopRecording = false
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingDuration += 1
            if recordingDuration >= viewModel.recorder.minDuration {
                 canStopRecording = true
            }
        }
    }
    
    func stopRecordingTimer() {
        timer?.invalidate()
    }
    
    func startPlayerTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let player = self.audioPlayerManager.audioPlayer {
                self.playerDuration = player.currentTime
                if player.currentTime >= player.duration {
                    self.pausePlayer()
                    self.playerDuration = 0
                    self.isPlaying = false
                }
            }
        }
    }

    
    func stopPlayerTimer() {
        timer?.invalidate()
    }
    
    func startWaveformAnimation() {
        waveformTimer?.invalidate()

        waveformTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.isRecording {
                    // UPDATE: call recording waveform update
                    self.viewModel.updateWaveformForRecording()
                } else if self.isPlaying {
                    self.viewModel.updateWaveformForPlaying()
                } else {
                    self.viewModel.resetWaveform()
                }
            }
        }
    }


    func stopWaveformAnimation() {
        waveformTimer?.invalidate()
        waveformLevel = 0.0
    }
    
    func cleanupAudioSession() {
        stopRecording()
        stopPlayerTimer()
        stopWaveformAnimation()
        viewModel.stopRecording()
        audioPlayerManager.stopAudio()
        isRecording = false
        isPlaying = false
        viewModel.recorder.stopRecording()
    }

}

#Preview {
    // VoiceRecorderView()
}
