//
//  ChatsViewModel.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 14/06/25.
//

import Foundation

class ChatsViewModel: ObservableObject {
    
    @Published var cards: [CardsModel] = []
    
    //This call need generally async execution but as its just a basic json so i have not added that , in that order we have to map all loader, error alerts and all things.
    //Currently we just needed data in the list so this function is intended that way
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
