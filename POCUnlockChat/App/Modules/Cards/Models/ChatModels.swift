//
//  ChatModels.swift
//  POCUnlockChat
//
//  Created by Yogi Rawat on 12/06/25.
//

import Foundation


struct CardsModel: Identifiable, Codable, Hashable {
    var id = ""
    var age: String
    var name: String
    var imageURL: String
    var question: String
    var answer: String
    var uplaodedImages: [String]
}
