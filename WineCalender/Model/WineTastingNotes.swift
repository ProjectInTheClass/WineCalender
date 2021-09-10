//
//  WineTastingNotes.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/17.
//

import Foundation
import UIKit

struct WineTastingNotes: Decodable {
    let tastingDate: Date
    let place: String?
    let wineName: String
    let category: String?
    let varieties: [String]?
    let producingCountry: String?
    let producer: String?
    let vintage: String?
    let price: Int32?
    let alcoholContent: Float?
    let sweet: Int16?
    let acidity: Int16?
    let tannin: Int16?
    let body: Int16?
    let aromasAndFlavors: [String]?
    let memo: String?
    let rating: Int16?
}
