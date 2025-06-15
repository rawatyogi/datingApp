//
//  CardsView.swift
//  POCUnlockChat
//
//  Created by Yogi Rawat on 12/06/25.
//

import SwiftUI

struct CardsView: View {
    
    //MARK: PROPERTIES
    @State private var initialAppear = false
    @State private var buttonClickChat = true
    @State private var buttonClickPending = false
    @State private var lastClickedTab: String? = nil
    @State private var isChatsAnimating = false
    @State private var isPendingAnimating = false

    @StateObject private var viewModel = ChatsViewModel()
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                Color.init(hex: "#0A0B0D")
                    .ignoresSafeArea()
                ScrollView {
                    VStack{
                        cardsHeaderView
                            .padding(.horizontal, 15)
                        cardsCollectionsView
                            .padding(.top, 20)
                            .padding(.leading, 5)
                        chatTabsView
                            .padding(.top, 12)
                            .padding(.horizontal, 15)
                        rectangleView
                            .padding(.top, 0)
                            .padding(.horizontal, 0)
                    }
                    .toolbar(.hidden)
                }
            }
        }
        .onAppear {
            viewModel.fetchCardsData()
        }
    }
    
    //MARK: HEADER VIEW
    var cardsHeaderView: some View {
        VStack(alignment: .leading, spacing: -10) {
            HStack(spacing: 20) {
                Text("Yogendra")
                    .foregroundStyle(.white)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.leading)
                yourTurnCountView
                Spacer()
                VStack(alignment: .trailing) {
                    profileView
                }
            }
            Text("Make You move, they are waiting")
                .foregroundStyle(.white.opacity(0.7))
                .font(.system(size: 15.0).italic())
                .multilineTextAlignment(.leading)
        }
    }
    
    //MARK: COUNT VIEW
    var yourTurnCountView: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#CFCFFE"))
                .frame(width: 25.0, height: 25.0)
            Text("7")
                .foregroundStyle(.black)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
    }
    
    //MARK: PROFILE VIEW
    var profileView: some View {
        ZStack {
            Circle()
                .fill(.red)
                .frame(width: 55.0, height: 55.0)
            
            Image("robb")
                .resizable()
                .scaledToFill()
                .frame(width: 45.0, height: 45.0)
                .cornerRadius(18)
            
            Rectangle()
                .fill(Color(hex: "#12161F"))
                .frame(width: 55.0, height: 25.0)
                .cornerRadius(12)
                .padding(.top, 50)
            
            Text("7")
                .foregroundStyle(.white.opacity(0.7))
                .font(.headline)
                .multilineTextAlignment(.leading)
                .padding(.top, 50)
        }
    }
    
    //MARK: CARDS HORIZONTAL LIST
    var cardsCollectionsView: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 8) {
                ForEach(Array(viewModel.cards.enumerated()), id: \.element) { index, data in
                    NavigationLink(destination: VoiceRecorderView(selectedCard: data)) {
                        UserPhotoView(selectedIndex: index, initialAppear: self.initialAppear, data: data)
                    }
                }
            }
            .padding(.leading, 20)
        }
        .coordinateSpace(name: "scroll")
        .scrollIndicators(.hidden)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                initialAppear = true
            }
        }
    }

    //MARK: DEMO VIEW AT BOTTOM
    var rectangleView: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: "#D9D9D9"))
                .cornerRadius(12)
                .padding(.bottom, 0)
                .frame(height: 370)
        }
    }
    
    //MARK: CHAT AND PENDING TABS
    var chatTabsView: some View {
        HStack(spacing: 12) {
            chatTab(title: "Chats", isSelected: buttonClickChat, animate: isChatsAnimating)
                .onTapGesture {
                    buttonClickChat = true
                    buttonClickPending = false
                    animateTabClick("Chats")
                }
            
            chatTab(title: "Pending", isSelected: buttonClickPending, animate: isPendingAnimating)
                .onTapGesture {
                    buttonClickPending = true
                    buttonClickChat = false
                    animateTabClick("Pending")
                }
            
            Spacer()
        }
    }
    
    func chatTab(title: String, isSelected: Bool, animate: Bool) -> some View {
        
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 20))
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .white : Color(hex: "#5F5F60"))
                .padding(.horizontal, 10)
                .scaleEffect(lastClickedTab == title ? 1.1 : 1.0)
                .opacity(lastClickedTab == title ? 1.0 : 0.9)
                .animation(.easeOut(duration: 0.25), value: lastClickedTab)
            
            Rectangle()
                .fill(isSelected ? Color.white : Color.clear)
                .frame(height: 2)
                .cornerRadius(1)
        }
        .fixedSize()
    }
    
    func animateTabClick(_ title: String) {
        withAnimation {
            lastClickedTab = title
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            lastClickedTab = nil
        }
    }
}

#Preview {
    CardsView()
}
