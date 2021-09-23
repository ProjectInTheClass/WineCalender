//
//  PostDetailVM.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/09/14.
//
import Foundation
import UIKit

struct PostDetailVM {
//    let profileImage : String?
//    let userName : String?
    let postImages : [String]?
    let wineName : String?
//    let memoText : String?
    
    init(post:Post){
        self.wineName = post.tastingNote.wineName
        self.postImages = post.postImageURL
    }
}

