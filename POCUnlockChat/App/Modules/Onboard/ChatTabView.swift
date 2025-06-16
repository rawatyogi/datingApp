//
//  ChatTabView.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 12/06/25.
//

import SwiftUI

struct ChatTabView: View {
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.init(hex: "B5B2FF")]
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    @State private var selectedTab = 0
  
    var body: some View {
        TabView {
            
            CardsView().tabItem {
                Image("poker")
                    .renderingMode(.template)
                    .foregroundColor(selectedTab == 0 ? Color.init(hex: "#B5B2FF") : Color.init(hex: "#5F5F60"))
                Text("Cards")
                    .foregroundStyle(Color(hex: "#5F5F60"))
            }
            .tag(0)
            
            BonefireView().tabItem {
                Image("bonefire")
                    .renderingMode(.template)
                    .foregroundColor(selectedTab == 1 ? Color.init(hex: "#B5B2FF") : Color.init(hex: "#5F5F60"))
                Text("Bonefire")
                    .foregroundStyle(Color(hex: "#5F5F60"))
            }
            .tag(1)
            
            MatchesView().tabItem {
                Image("messages")
                    .renderingMode(.template)
                    .foregroundColor(selectedTab == 2 ? Color.init(hex: "#B5B2FF") : Color.init(hex: "#5F5F60"))
                Text("Matches")
                    .foregroundStyle(Color(hex: "#5F5F60"))
            }
            .tag(2)
            
            ProfileView().tabItem {
                Image("profile")
                    .renderingMode(.template)
                    .foregroundColor(selectedTab == 3 ? Color.init(hex: "#B5B2FF") : Color.init(hex: "#5F5F60"))
                Text("Profile")
                    .foregroundStyle(Color(hex: "#5F5F60"))
            }
            .tag(3)
        }
    }
}

#Preview {
    ChatTabView()
}
