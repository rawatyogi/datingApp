//
//  WaveAnimationView.swift
//  POCUnlockChat
//
//  Created by Yogi Rawat on 14/06/25.
//

import SwiftUI

struct WaveformView: View {
    var isRecording: Bool
    var isPlaying: Bool
    var barHeights: [CGFloat]

    var body: some View {
        HStack {
            ForEach(0..<barHeights.count, id: \.self) { index in
                Capsule()
                    .fill((isRecording || isPlaying) ? Color.init(hex: "#B5B2FF") : Color.gray.opacity(0.8))
                    .frame(width: 3, height: barHeights[index])
            }
        }
        .animation(.easeOut(duration: 0.05), value: barHeights)
    }
}
