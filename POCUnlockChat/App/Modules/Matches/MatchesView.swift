//
//  MatchesView.swift
//  POCUnlockChat
//
//  Created by Yogi Rawat on 12/06/25.
//

import SwiftUI

struct MatchesView: View {
    @ObservedObject var viewModel =  VoiceRecorderViewModel()
    @StateObject var audioPlayer = AudioPlayerManager()
    
    var body: some View {
        NavigationStack {
            List(viewModel.recordedFiles, id: \.self) { fileURL in
                HStack {
                    Text(fileURL.lastPathComponent)
                        .foregroundColor(.white)
                    Spacer()
                    Button("Play") {
                        audioPlayer.playAudio(url: fileURL)
                    }
                    .foregroundColor(.blue)
                    
                    Button("Pause") {
                        audioPlayer.stopAudio()
                    }
                    .foregroundColor(.black)
                }
            }

            .navigationTitle("Recorded Audios")
        }
    }
}
