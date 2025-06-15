//
//  RecordingProgressView.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 14/06/25.
//

import SwiftUI
//#4F4CB1 -1st
//#CFCFFE - 2nd
//#21204B  -3rd
struct RecordingProgressView: View {
    
    var progress: Double
    var geo: GeometryProxy
    var body: some View {
        ZStack {
           
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(gradient: Gradient(colors: [Color.init(hex: "#4F4CB1"), Color.init(hex: "#21204B"), Color.init(hex: "#CFCFFE")]),
                                    center: .center),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
                .frame(width: geo.size.width * 0.12, height: geo.size.width * 0.12)
        }
    }
}
