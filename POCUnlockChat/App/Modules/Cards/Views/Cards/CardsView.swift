//
//  CardsView.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 12/06/25.
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

    @StateObject private var viewModel : ChatsViewModel
 
    init(viewModel: ChatsViewModel = ChatsViewModel()) {
            _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                Color.init(hex: "#0A0B0D")
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    VStack {
                        CardsHeaderView(name: viewModel.cards.first?.name ?? "", photo: viewModel.cards.first?.imageURL ?? "", count: 5)
                            .padding(.horizontal, 15)
                            .padding(.top, 30)
                        
                        CardsCollectionView(cards: viewModel.cards, initialAppear: self.$initialAppear)
                            .padding(.leading, 5)
                            .padding(.top, 18)
                        
                        chatTabsView
                            .padding(.top, 10)
                            .padding(.horizontal, 15)
                        
                        RectangleView()
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

    //MARK: TABS CHAT AND PENDING
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

//MARK: HEADER VIEW
struct CardsHeaderView: View {
    let name: String
    let photo: String
    let count: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 20) {
                Text(name)
                    .foregroundStyle(.white)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.leading)
                CountView(count: 5)
                Spacer()
                VStack(alignment: .trailing) {
                    CardProfileView(name: name, photo: photo, count: count)
                }
            }
            Text("Make You move, they are waiting")
                .foregroundStyle(.white.opacity(0.7))
                .font(.system(size: 15.0).italic())
                .multilineTextAlignment(.leading)
        }
    }
}


//MARK: COUNT VIEW
struct CountView: View {
    let count: Int
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#CFCFFE"))
                .frame(width: 25.0, height: 25.0)
            Text("\(count)")
                .foregroundStyle(.black)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
    }
}

//MARK: PROFILE VIEW
struct UserProfileView : View {
    
    let count: Int
    var profilePicture: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.red)
                .frame(width: 55.0, height: 55.0)
            
            Image(profilePicture)
                .resizable()
                .scaledToFill()
                .frame(width: 45.0, height: 45.0)
                .cornerRadius(18)
            
            Rectangle()
                .fill(Color(hex: "#12161F"))
                .frame(width: 55.0, height: 25.0)
                .cornerRadius(12)
                .padding(.top, 50)
            
            Text("\(count)")
                .foregroundStyle(.white.opacity(0.7))
                .font(.headline)
                .multilineTextAlignment(.leading)
                .padding(.top, 50)
        }
    }
}

//MARK: CARDS STACK
struct CardsCollectionView : View {
    let cards: [CardsModel]
    @Binding var initialAppear: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(Array(cards.enumerated()), id: \.element) { index, card in
                    NavigationLink(destination: VoiceRecorderView(selectedCard: card)) {
                        UserPhotoView(selectedIndex: index, initialAppear: initialAppear, data: card)
                    }
                }
            }
            .padding(.horizontal, 0)
        }
        .coordinateSpace(name: "scroll")
        .scrollIndicators(.hidden)
        .onAppear {
            initialAppear = true
        }
    }
}

// MARK: REACTANGLE
struct RectangleView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: "#D9D9D9"))
                .cornerRadius(12)
                .frame(height: 370)
        }
    }
}

struct CardProfileView : View {
    var name : String
    var photo: String
    var count : Int
    var body: some View {
        ZStack {
            Circle()
                .fill(.red)
                .frame(width: 55.0, height: 55.0)
            
            Image(photo)
                .resizable()
                .scaledToFill()
                .frame(width: 45.0, height: 45.0)
                .cornerRadius(18)
            
            Rectangle()
                .fill(Color(hex: "#12161F"))
                .frame(width: 55.0, height: 25.0)
                .cornerRadius(12)
                .padding(.top, 50)
            
            Text("\(count)")
                .foregroundStyle(.white.opacity(0.7))
                .font(.headline)
                .multilineTextAlignment(.leading)
                .padding(.top, 50)
        }
    }
}


#Preview {
    CardsView()
}

