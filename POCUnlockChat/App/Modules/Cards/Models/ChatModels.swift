//
//  ChatModels.swift
//  POCUnlockChat
//
//  Created by Anuj Garg on 12/06/25.
//

import Foundation

struct CardsModel: Identifiable, Codable, Hashable {
    var id : String
    var age: String
    var name: String
    var imageURL: String
    var question: String
    var answer: String
    var uplaodedImages: [String]
}
