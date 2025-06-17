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
    
    @State private var showDetail = false
    @Namespace var zoomNamespace: Namespace.ID
    @State private var selectedCard: CardsModel? = nil
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
                            .padding(.top, 10)
                        
                        CardsCollectionView(cards: viewModel.cards, showDetail: self.$showDetail, zoomNamespace: zoomNamespace, initialAppear: $initialAppear, selectedCard: $selectedCard)
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
                
                // MARK: Zoomed Detail View Overlay
                if showDetail, let selectedCard = selectedCard {
                    VoiceRecorderView(
                        selectedCard: selectedCard,
                        namespace: zoomNamespace,
                        onDismiss: {
                            withAnimation(.spring()) {
                                showDetail = false
                            }
                        }, voiceRecorderScreen: .matches)
                    .transition(.opacity)
                    .zIndex(1)
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
            HStack(spacing: 8) {
                Text(name)
                    .foregroundStyle(.white)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.leading)
                CountView(count: 5)
                Spacer()
                VStack(alignment: .trailing) {
                    CardProfileView(name: name, photo: photo, count: count, progress: 0.8)
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
                .fill(Color(hex: "#B49AD1"))
                .frame(width: 25.0, height: 25.0)
            Text("\(count)")
                .foregroundStyle(.black)
                .font(.subheadline)
                .fontWeight(.medium)
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
    @Binding var showDetail: Bool
    var zoomNamespace: Namespace.ID
    @Binding var initialAppear: Bool
    @Binding var selectedCard: CardsModel?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                
                ForEach(Array(cards.enumerated()), id: \.element) { index, card in
                    UserPhotoView(selectedIndex: index, initialAppear: initialAppear, data: card)
                        .matchedGeometryEffect(id: "zoom-\(card.id)", in: zoomNamespace)
                        .opacity(selectedCard?.id == card.id && showDetail ? 0 : 1)
                        .onTapGesture {
                            selectedCard = card
                            withAnimation(.spring()) {
                                showDetail = true
                            }
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

import SwiftUI

struct CardProfileView: View {
    
    var name: String
    var photo: String
    var count: Int
    var progress: Double
    var size: CGFloat = 60  // adjustable size parameter
    
    var body: some View {
        ZStack {
            
            Circle()
                .trim(from: 0.0, to: 0.72)
                .stroke(Color(hex: "#363636"), style: StrokeStyle(lineWidth: size * 0.085, lineCap: .round))
                .rotationEffect(.degrees(140))
            
            Circle()
                .trim(from: 0.0, to: 0.7 * progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(hex: "#4C8D25").opacity(0.0), location: 0.0),
                            .init(color: Color(hex: "#36631A"), location: 0.15),
                            .init(color: Color(hex: "#36631A"), location: 0.85),
                            .init(color: Color(hex: "#36631A").opacity(0.0), location: 1.0)
                        ]),
                        center: .center,
                        startAngle: .degrees(140),
                        endAngle: .degrees(140 + 259.2)
                    ),
                    style: StrokeStyle(lineWidth: size * 0.085, lineCap: .round)
                )
                .rotationEffect(.degrees(140))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            Image(photo)
                .resizable()
                .scaledToFill()
                .frame(width: size * 0.75, height: size * 0.75)
                .clipShape(Circle())
            
            GeometryReader { geo in
                let geoSize = geo.size
                let lineWidth = size * 0.085
                let radius = (geoSize.width - lineWidth) / 2
                let startAngle = 140.0
                let arcSpan = 259.2
                let currentAngle = startAngle + (progress * arcSpan)
                let angleInRadians = CGFloat(Angle(degrees: currentAngle).radians)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#B5B2FF").opacity(0.0),
                                Color(hex: "#B5B2FF"),
                                Color(hex: "#B5B2FF"),
                                Color(hex: "#B5B2FF").opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size * 0.11, height: size * 0.23)
                    .rotationEffect(.degrees(currentAngle + 90))
                    .position(
                        x: (geoSize.width + 5) / 2 + radius * cos(angleInRadians),
                        y: geoSize.height / 2 + radius * sin(angleInRadians)
                    )
            }
            .frame(width: size, height: size)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#121620"))
                    .frame(width: size * 0.8, height: size * 0.35)
                
                Text("\(Int(progress * 100))")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: size * 0.25, weight: .medium))
            }
            .offset(y: size * 0.55)
            
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    CardsView()
}
