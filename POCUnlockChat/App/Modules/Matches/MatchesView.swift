//
//  MatchesView.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 12/06/25.
//

import SwiftUI

struct MatchesView: View {

    // MARK: PROPERTIES
    @State private var initialAppear = false
    @State private var buttonClickChat = true
    @State private var buttonClickPending = false
    @State private var lastClickedTab: String? = nil
    @State private var isChatsAnimating = false
    @State private var isPendingAnimating = false

    @StateObject private var viewModel: ChatsViewModel

    @Namespace private var zoomNamespace
    @State private var selectedCard: CardsModel? = nil
    @State private var showDetail = false

    init(viewModel: ChatsViewModel = ChatsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        NavigationStack {
            ZStack {
                Color(hex: "#0A0B0D")
                    .ignoresSafeArea()

                ScrollView {
                    VStack {
                        CardsHeaderView(name: "Animation Version Copy",
                                        photo: viewModel.cards.first?.imageURL ?? "",
                                        count: 5)
                        .padding(.horizontal, 15)
                        .padding(.top, 30)

                        MatchesCollectionView(
                            cards: viewModel.cards,
                            initialAppear: $initialAppear,
                            zoomNamespace: zoomNamespace,
                            selectedCard: $selectedCard,
                            showDetail: $showDetail
                        )
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
                                // optional: selectedCard = nil
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

    // MARK: CHAT AND PENDING TABS
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

// MARK: CARDS STACK
struct MatchesCollectionView: View {

    var cards: [CardsModel]
    @Binding var initialAppear: Bool
    var zoomNamespace: Namespace.ID
    @Binding var selectedCard: CardsModel?
    @Binding var showDetail: Bool

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

