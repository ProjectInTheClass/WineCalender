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
    
    init(_ post: Post) {
        self.name = post.tastingNote.wineName
        
        self.category = post.tastingNote.category ?? ""
        self.varieties = (post.tastingNote.varieties ?? []).joined(separator: " | ")
        self.producingCountry = post.tastingNote.producingCountry ?? ""
        self.producer = post.tastingNote.producer ?? ""
        self.vintage = post.tastingNote.vintage ?? ""
        
        if let price = post.tastingNote.price {
            self.price = "₩ \(price)"
        } else {
            self.price = ""
        }
        
        if let alcoholContent = post.tastingNote.alcoholContent {
            self.alcoholContent = "\(alcoholContent) %"
        } else {
            self.alcoholContent = ""
        }
        
        self.aromasAndFlavors = (post.tastingNote.aromasAndFlavors ?? []).compactMap{$0}.joined(separator: ", ")
        self.sweet = Int((post.tastingNote.sweet ?? 6) - 1) % 6
        self.acidity = Int((post.tastingNote.acidity ?? 6) - 1) % 6
        self.tannin = Int((post.tastingNote.tannin ?? 6) - 1) % 6
        self.body = Int((post.tastingNote.body ?? 6) - 1) % 6
        
        self.memo = post.tastingNote.memo ?? ""
        self.rating = Int((post.tastingNote.rating ?? 6) - 1) % 6
    }
    
    init(_ tastingNote: WineTastingNote) {
        self.name = tastingNote.wineName
        
        self.category = tastingNote.category ?? ""
        self.varieties = (tastingNote.varieties ?? []).joined(separator: " | ")
        self.producingCountry = tastingNote.producingCountry ?? ""
        self.producer = tastingNote.producer ?? ""
        self.vintage = tastingNote.vintage ?? ""
        
        self.price = tastingNote.price > 0 ? "₩ \(tastingNote.price)" : ""
        if tastingNote.alcoholContent > 0 {
            self.alcoholContent = "\(tastingNote.alcoholContent) %"
        } else {
            self.alcoholContent = ""
        }
        
        self.aromasAndFlavors = (tastingNote.aromasAndFlavors ?? []).compactMap{$0}.joined(separator: ", ")
        
        if tastingNote.sweet > 0 {
            self.sweet = Int(tastingNote.sweet - 1)
        } else {
            self.sweet = 5
        }
        
        if tastingNote.acidity > 0 {
            self.acidity = Int(tastingNote.acidity - 1)
        } else {
            self.acidity = 5
        }
        
        if tastingNote.tannin > 0 {
            self.tannin = Int(tastingNote.tannin - 1)
        } else {
            self.tannin = 5
        }
        
        if tastingNote.body > 0 {
            self.body = Int(tastingNote.body - 1)
        } else {
            self.body = 5
        }
        
        self.memo = tastingNote.memo ?? ""
        
        if tastingNote.rating > 0 {
            self.rating = Int(tastingNote.rating - 1)
        } else {
            self.rating = 5
        }
    }
}
