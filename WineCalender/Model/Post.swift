//
//  Post.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/10.
//

import Foundation

struct Post: Decodable {
    let postID: String
    let authorUID: String
    let postingDate: Date
    let updatedDate: Date?
    let postImageURL: [String]
    let tastingNote: WineTastingNotes
    let likes: [String]?
    let comments: [Comment]?
}

//func getUserForUID() {
//    
//}
