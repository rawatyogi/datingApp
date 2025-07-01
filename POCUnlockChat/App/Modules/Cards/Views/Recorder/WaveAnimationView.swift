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
    var progress: Double
    @GestureState private var dragOffset: CGFloat = 0
    var state: RecorderState = .readyToRecording
    var onSeek: ((Double) -> Void)? = nil
   
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let barCount = barHeights.count
            let progressWidth = CGFloat(progress) * totalWidth
            
            ZStack(alignment: .leading) {
                if  self.state == .readyToRecording || self.state == .recordingFinished {
                    Rectangle()
                        .fill(.gray)
                        .frame(height: 3)
                        .cornerRadius(12)
                        .padding(.top, 30)
                } else {
                    HStack(spacing: 5) {
                        ForEach(0..<barCount, id: \.self) { i in
                            Capsule()
                                .fill(
                                    isRecording
                                    ? LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "#FFFF00").opacity(0.3), .orange.opacity(0.7), Color(hex: "#FF0000"), .white.opacity(0.7)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ) : (CGFloat(i) / CGFloat(barHeights.count)) < progress ?
                                     LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "#FFFF00").opacity(0.3), Color(hex: "#FF0000")]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ) :
                                    LinearGradient(
                                        gradient: Gradient(colors: [.gray, .gray]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: barHeights[i] + 10)
                                .opacity(
                                    isRecording
                                    ? 1.0
                                    : (CGFloat(i) / CGFloat(barHeights.count)) < progress ? 1.0 : 0.5
                                )
                                .animation(.easeInOut(duration: 0.1), value: barHeights[i])

                        }
                    }
                    .padding(.top, 0)
                    
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "#FFFFFF").opacity(0.7), .green]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 25, height: isPlaying ? 25 : 0)
                        .offset(x: progressWidth - 5)
                        .animation(.easeOut(duration: 0.05), value: progress)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newProgress = min(max(0, value.location.x / totalWidth), 1)
                                    withAnimation(.linear(duration: 0.05)) {
                                            onSeek?(Double(newProgress))
                                        }
                                }
                        )
                        .padding(.top, 0)
                }
            }
        }
        .frame(height: 60)
    }
}
