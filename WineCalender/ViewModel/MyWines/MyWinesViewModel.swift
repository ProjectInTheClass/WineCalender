//
//  MyWinesViewModel.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/10.
//

import Foundation

struct MyWinesViewModel {
    let postID: String
    let firstImageURL: URL
    let wineName: String
    let tastingDate: Date
    let rating: Int16?
    
    init (post: Post) {
        self.postID = post.postID
        self.firstImageURL = URL(string: post.postImageURL[0])! 
        self.wineName = post.tastingNote.wineName
        self.tastingDate = post.tastingNote.tastingDate
        self.rating = post.tastingNote.rating
    }
}
