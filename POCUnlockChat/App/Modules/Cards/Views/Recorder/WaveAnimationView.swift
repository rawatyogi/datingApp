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
        if isActive {
            HStack {
                ForEach(0..<barHeights.count, id: \.self) { index in
                    Capsule()
                        .fill((isRecording || isPlaying) ? Color.init(hex: "#B5B2FF") : Color.gray.opacity(0.8))
                        .frame(width: 3, height: barHeights[index])
                }
            }
            .animation(.easeOut(duration: 0.05), value: barHeights)
        }else {
            Rectangle()
                .fill(Color.gray.opacity(0.4))
                .frame(height: 2)
                .padding(.horizontal, 20)
        }
    }
}
