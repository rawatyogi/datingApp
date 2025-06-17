//
//  VoiceRecorderView.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 14/06/25.
//
import SwiftUI

struct VoiceRecorderView: View {
    
    //MARK: PROPERTIES
    var selectedCard: CardsModel
    @State private var selectedIndex = 0
    @State private var isSubmitted = false
    @State private var userPhotos = [String]()
    @State private var showSubmissionAlert = false
    @State private var showPermissionAlert = false
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = VoiceRecorderViewModel()
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    
    var namespace: Namespace.ID
    var onDismiss: () -> Void
    var voiceRecorderScreen: VoiceRecorderScreen = .cards
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()
                
                PhotosCarasoulView(geo: geo, userPhotos: selectedCard.uplaodedImages, selectedIndex: $selectedIndex, selectedCard: selectedCard, zoomNamespace: namespace)
                
                VStack {
                    PageIndicatorView(geo: geo, userPhotos: selectedCard.uplaodedImages, selectedIndex: $selectedIndex)
                        .animation(.easeInOut(duration: 0.25), value: selectedIndex)
                    
                    HeaderView(geo: geo, selectedCard: selectedCard, voiceRecorderScreen: self.voiceRecorderScreen, onDismiss: onDismiss)
                    Spacer()
                    VStack(spacing: 0) {
                        QuestionaireView(geo: geo, selectedCard: selectedCard)
                        timerAndLineView(geo: geo)
                            .padding(.top, geo.size.height * 0.05)
                        audioControls(geo: geo)
                            .padding(.top, geo.size.height * 0.03)
                        UnmatchView(presentationMode: self._presentationMode, voiceRecorderScreen: self.voiceRecorderScreen, onDismiss: onDismiss)
                    }
                    .padding(.bottom, geo.safeAreaInsets.bottom + 30)
                }
                .padding(.horizontal, 15)
                .padding(.top, geo.size.height * 0.05)
            }
            .onAppear {
                self.userPhotos = self.selectedCard.uplaodedImages
            }
        }
        .alert("Your recording submitted successfully!", isPresented: $showSubmissionAlert) {
            Button("OK", role: .cancel) {
                switch self.voiceRecorderScreen {
                case .cards:
                    presentationMode.wrappedValue.dismiss()
                case .matches:
                    withAnimation(.spring()) {
                      onDismiss()
                   }
                }
            }
        }
        .alert("Microphone Access Needed", isPresented: $showPermissionAlert) {
            Button("Go to Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable microphone access in Settings to use voice recording features.")
        }
        .onDisappear(perform: {
            viewModel.cleanupAudioSession()
        })
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    // MARK: Timer + Line View
    func timerAndLineView(geo: GeometryProxy) -> some View {
        VStack(spacing: geo.size.height * 0.032) {
            Text(viewModel.isPlaying
                 ? "\(viewModel.player.currentTime.stringFormatted()) / \(viewModel.player.audioPlayer?.duration.stringFormatted() ?? "00:00")"
                 : viewModel.elapsedTime.stringFormatted())
                .font(.footnote)
                .foregroundColor(Color(hex: "#AEADAF"))
            
            let isActive = viewModel.isRecording || viewModel.isPlaying
            WaveformView(isRecording: viewModel.isRecording, isPlaying: viewModel.isPlaying, barHeights: viewModel.barHeights, isActive: isActive)
                .frame(height: 30)
                .padding(.horizontal, geo.size.width * 0.1)
            
        }
    }
    
    // MARK: Audio Controls
    func audioControls(geo: GeometryProxy) -> some View {
        HStack(spacing: geo.size.width * 0.12) {
            Button("Delete") {
                switch self.voiceRecorderScreen {
                case .cards:
                    presentationMode.wrappedValue.dismiss()
                case .matches:
                    withAnimation(.spring()) {
                      onDismiss()
                   }
                }
            }
            .font(.body)
            .frame(width: 80, height: 40)
            .animation(.easeInOut(duration: 0.25), value: viewModel.hasStartedRecording)
            .disabled(!viewModel.hasStartedRecording)
            .foregroundColor(viewModel.hasStartedRecording ? .white : Color(hex: "#5C6770"))
            
          
            ZStack {
                RecordingProgressView(progress: min(viewModel.elapsedTime / viewModel.recorder.minDuration, 1.0), geo: geo)
                    .opacity(viewModel.isRecording ? 1 : 0)
                    .animation(.easeInOut(duration: 0.25), value: viewModel.elapsedTime)
                
                Button {
                    viewModel.requestMicrophonePermission { granted in
                        
                        if granted {
                            switch viewModel.state {
                                
                            case .readyToRecording:
                                viewModel.startRecording()
                                viewModel.updateWaveform()
                                debugPrint("Start recording")
                                
                            case .recording:
                                if viewModel.canStopRecording {
                                    viewModel.stopRecording()
                                }
                                debugPrint("Stop recording")
                                
                            case .recordingFinished:
                                viewModel.startPlayback()
                                debugPrint("Recording finished")
                                
                            case .playing:
                                viewModel.pausePlayback()
                                debugPrint("Pause Playback")
                                
                            case .paused:
                                viewModel.resumePlayback()
                                debugPrint("Playback pauesd")
                                
                            case .playbackFinished:
                                viewModel.startPlayback()
                                debugPrint("Playback finished")
                            }
                        } else {
                            showPermissionAlert = true
                        }
                    }
                   
                } label: {
                    Image(viewModel.iconName)
                        .resizable()
                        .frame(width:  geo.size.width * 0.12, height:  geo.size.width * 0.12)
                        .padding()
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
                .frame(width: 80, height: 80)
                .disabled(viewModel.isRecording && !viewModel.canStopRecording)
                .opacity(viewModel.isRecording && !viewModel.canStopRecording ? 0.5 : 1)
            }
            
            
            Button("Submit") {
                viewModel.cleanupAudioSession()
                showSubmissionAlert = true
            }
            .font(.body)
            .foregroundColor(viewModel.canStopRecording ? .white : Color(hex: "#5C6770"))
            .frame(width: 80, height: 40)
            .disabled(!viewModel.canStopRecording)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.canStopRecording)
            
        }
    }
}

//MARK: PHOTOS VIEW
struct PhotosCarasoulView : View {
    
    var geo: GeometryProxy
    var userPhotos: [String]
    @Binding var selectedIndex : Int
    var selectedCard: CardsModel
    var zoomNamespace: Namespace.ID
    
    var body: some View {
    
        TabView(selection: $selectedIndex) {
            ForEach(0..<userPhotos.count, id: \.self) { index in
                GeometryReader { geo in
                    let minX = geo.frame(in: .global).minX
                    Image(userPhotos[index])
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .scaleEffect(1 - abs(minX / geo.size.width) * 0.1)
                        .rotation3DEffect(
                            .degrees(minX / -20),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.black, location: 0.0),
                                    .init(color: Color.black, location: 0.05),
                                    .init(color: Color.black, location: 0.2),
                                    .init(color: Color.black.opacity(0.35), location: 0.45),
                                    .init(color: Color.black.opacity(0.2), location: 0.5)
                                ]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .transition(.opacity)
                        .id(userPhotos[index])
                        .ignoresSafeArea()
                }
            }
        }
        .matchedGeometryEffect(id: "zoom-\(selectedCard.id)", in: zoomNamespace)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }
}

//MARK: PAGE INDICATOR VIEW
struct PageIndicatorView : View {
  
    var geo: GeometryProxy
    var userPhotos: [String]
    @Binding var selectedIndex : Int
    
    var body: some View {
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
}

// MARK: Header View
struct HeaderView : View {
    
    var geo: GeometryProxy
    var selectedCard: CardsModel
    var voiceRecorderScreen: VoiceRecorderScreen
    var onDismiss: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        HStack {
            
            Button(action: {
                switch voiceRecorderScreen {
                case .cards:
                    presentationMode.wrappedValue.dismiss()
                case .matches:
                    withAnimation(.spring()) {
                      onDismiss()
                   }
                }
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
}

// MARK: Question View
struct QuestionaireView : View {
    
    var geo: GeometryProxy
    var selectedCard: CardsModel
    
    var body: some View {
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
                        .fill(.black)
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
}


//MARK: UNMATCH BUTTON
struct UnmatchView : View {
    
    @Environment(\.presentationMode) var presentationMode
    var voiceRecorderScreen: VoiceRecorderScreen
    var onDismiss: () -> Void
    
    var body: some View {
        Button("Unmatch") {
            switch voiceRecorderScreen {
            case .cards:
                presentationMode.wrappedValue.dismiss()
            case .matches:
                withAnimation(.spring()) {
                  onDismiss()
               }
            }
           
        }
        .font(.body)
        .foregroundColor(Color(hex: "#BE2020"))
        .padding(.top, 10)
        .padding(.bottom, 8)
    }
}
