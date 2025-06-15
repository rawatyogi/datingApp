//
//  UserPhotoView.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 15/06/25.
//

import SwiftUI

struct UserPhotoView: View {
    
    var  selectedIndex: Int
    var initialAppear: Bool
    var data: CardsModel
    
    var body: some View {
        GeometryReader { geo in
            let frame = geo.frame(in: .named("scroll"))
            let screenWidth = UIScreen.main.bounds.width
            let cardVisibleWidth = frame.maxX > 0 ? min(frame.width, screenWidth - max(0, frame.minX)) : 0
            let visibleRatio = cardVisibleWidth / frame.width
            let isVisible = visibleRatio > 0.1

            let shouldAnimate = isVisible && initialAppear

            ZStack {
                
                ZStack {
                    Image(data.imageURL)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 155, height: 205)
                        .cornerRadius(18)
                    
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "#0F1110"), location: 0.0),
                            .init(color:Color(hex: "#0F1110"), location: 0.15),
                            .init(color: Color.black.opacity(0.6), location: 0.35),
                            .init(color: Color.black.opacity(0.3), location: 0.55),
                            .init(color: Color.clear, location: 0.8)
                        ]),
                        startPoint: .bottom, endPoint: .top
                    )
                }
                .frame(height: 205)
                .cornerRadius(18.0)

                VStack(spacing: 5) {
                    Spacer()
                    Text("\(data.name), \(data.age)")
                        .font(.system(size: 15))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .multilineTextAlignment(.center)

                    Text(data.question)
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundStyle(Color(hex: "#CFCFFE"))
                        .padding(.horizontal, 10)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 135)
                        .padding(.bottom, 20)
                }
            }
            .scaleEffect(shouldAnimate ? 1 : 0.9)
            .opacity(shouldAnimate ? 1 : 0.6)
            .animation(.easeOut(duration: 0.45), value: shouldAnimate)
        }
        .frame(width: 155, height: 205)
    }
}

#Preview {
    //UserPhotoView()
}
