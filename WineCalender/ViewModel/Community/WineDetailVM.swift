//
//  WineDetailVM.swift
//  WineCalender
//
//  Created by Susan Kim on 2021/12/17.
//

import Foundation

struct WineDetailVM {
    let name: String
    let category: String
    let varieties: String
    let producingCountry: String
    let producer: String
    let vintage: String
    let price: String
    let alcoholContent: String
    let aromasAndFlavors: String
    let sweet: Int
    let acidity: Int
    let tannin: Int
    let body: Int
    let memo: String
    let rating: Int
    
    init(_ tastingNote: WineTastingNote) {
        self.name = tastingNote.wineName
        
        self.category = tastingNote.category ?? ""
        self.varieties = (tastingNote.varieties ?? []).joined(separator: " | ")
        self.producingCountry = tastingNote.producingCountry ?? ""
        self.producer = tastingNote.producer ?? ""
        self.vintage = tastingNote.vintage ?? ""
        
        self.price = tastingNote.price > 0 ? "₩ \(tastingNote.price)" : ""
        self.alcoholContent = "\(tastingNote.alcoholContent) %"
        
        self.aromasAndFlavors = (tastingNote.aromasAndFlavors ?? []).compactMap{$0}.joined(separator: ", ")
        self.sweet = Int(tastingNote.sweet)
        self.acidity = Int(tastingNote.acidity)
        self.tannin = Int(tastingNote.tannin)
        self.body = Int(tastingNote.body)
        
        self.memo = tastingNote.memo ?? ""
        self.rating = Int((tastingNote.rating - 1) % 6)
    }
}
