//
//  WineTastingNotes.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/17.
//

import Foundation
import UIKit

struct WineTastingNotes: Decodable {
    var tastingDate: Date
    var place: String?
    //var image: [UIImage]
    var wineName: String
    var category: String?
    var varieties: [String]?
    var producingCountry: String?
    var producer: String?
    var vintage: String?
    var price: Int32?
    var alcoholContent: Float?
    var sweet: Int16?
    var acidity: Int16?
    var tannin: Int16?
    var body: Int16?
    var aromasAndFlavors: [String]?
    var memo: String?
    var rating: Int16?
}


struct Post: Decodable {
    var authorUID: String
    var postingDate: Date
    var tastingNote: WineTastingNotes
    
    enum CodingKeys: String, CodingKey {
        case authorUID
        case postingDate
        case tastingNote
    }
        
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.authorUID = try valueContainer.decode(String.self, forKey: CodingKeys.authorUID)
        self.postingDate = try valueContainer.decode(Date.self, forKey: CodingKeys.postingDate)
        self.tastingNote = try valueContainer.decode(WineTastingNotes.self, forKey: CodingKeys.tastingNote)
    }
}
