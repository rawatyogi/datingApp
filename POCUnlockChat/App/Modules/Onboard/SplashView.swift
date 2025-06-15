//
//  SplashView.swift
//  POCUnlockChat
//
//  Created by Yogi Rawat on 13/06/25.
//

import SwiftUI

struct SplashView: View {
    
    //MAR: PROPERTIES
    @State private var isActive = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Color.init(hex: "#0A0B0D")
                    .ignoresSafeArea()
                Image("splash")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                NavigationLink(destination: ChatTabView(), isActive: $isActive) {
                    EmptyView()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isActive = true
            }
        }
    }
}

#Preview {
    SplashView()
}
