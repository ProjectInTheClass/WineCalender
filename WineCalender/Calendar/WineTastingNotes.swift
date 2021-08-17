//
//  WineTastingNotes.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/17.
//

import Foundation
import UIKit

struct WineTastingNotes {
    var date: Date?
    var place: String?
    var image: [UIImage]?
    var name: String?
    var category: String?
    var varieties: [String]?
    var producingCountry: String?
    var producer: String?
    var vintage: String?
    var price: Int32
    var alcoholContent: Float
    var sweet: Int16
    var acidity: Int16
    var tannin: Int16
    var body: Int16
    var aromasAndFlavors: [String]?
    var memo: String?
    var rating: Int16
}
