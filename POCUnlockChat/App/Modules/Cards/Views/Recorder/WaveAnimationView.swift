//
//  WaveAnimationView.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 14/06/25.
//

import SwiftUI

struct WaveformView: View {
    var isRecording: Bool
    var isPlaying: Bool
    var barHeights: [CGFloat]
    var isActive: Bool

    var body: some View {
        ZStack {
          
            Rectangle()
                .fill(Color.gray.opacity(0.4))
                .frame(height: 2)
                .padding(.horizontal, 20)
                .opacity(isActive ? 0 : 1)
                .animation(.easeInOut(duration: 0.25), value: isActive)
            
            HStack {
                ForEach(0..<barHeights.count, id: \.self) { index in
                    Capsule()
                        .fill((isRecording || isPlaying) ? Color(hex: "#B5B2FF") : Color.gray.opacity(0.8))
                        .frame(width: 3, height: barHeights[index])
                }
            }
            .opacity(isActive ? 1 : 0)
            .animation(.easeInOut(duration: 0.25), value: isActive)
            .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: barHeights)
        }
    }
}
