//
//  ChatsViewModel.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 14/06/25.
//

import Foundation

class ChatsViewModel: ObservableObject {
    
    @Published var cards: [CardsModel] = []
    
    func fetchCardsData() {
        
        if let url = Bundle.main.url(forResource: "CardsData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                cards = try decoder.decode([CardsModel].self, from: data)
            } catch {
                print("Error loading JSON data: \(error)")
            }
        }
    }

}
