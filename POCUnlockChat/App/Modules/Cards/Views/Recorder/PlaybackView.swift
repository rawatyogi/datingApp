//
//  PlaybackView.swift
//  POCUnlockChat
//
//  Created by Yogi Rawat on 19/06/25.
//

import SwiftUI

struct PlaybackWaveformView: View {
    var barHeights: [CGFloat]
    var progress: Double
    var isPlaying: Bool
    var onSeek: (Double) -> Void
    
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let barCount = barHeights.count
            let barWidth = width / CGFloat(barCount)
            let progressWidth = CGFloat(progress) * width
            
            ZStack(alignment: .leading) {
                
                // Base waveform (gray)
                HStack(spacing: 2) {
                    ForEach(0..<barCount, id: \.self) { i in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: barWidth, height: barHeights[i])
                    }
                }
                
                // Progress waveform (highlight)
                HStack(spacing: 2) {
                    ForEach(0..<barCount, id: \.self) { i in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: barWidth, height: barHeights[i])
                    }
                }
                .mask(
                    Rectangle()
                        .frame(width: progressWidth)
                )
                
                // Progress indicator (thumb)
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .offset(x: progressWidth - 5)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newProgress = min(max(0, value.location.x / width), 1)
                                onSeek(newProgress)
                            }
                    )
            }
        }
        .frame(height: 30)
    }
}
