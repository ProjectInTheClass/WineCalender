//
//  PostVM.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/09/09.
//

import Foundation

struct PostThumbnailVM {
    let thumbnailImageURL : URL?
    let userName : String
    let profileImageURL : URL?
    let postMainText : String
    let postSubText : String
    let postSubTextIsHidden : Bool
    
    init(_ post:Post,_ username:String,_ profileImageUrl:URL?) {
       let thumbnailURL = URL(string: post.postImageURL[0])
       
       self.thumbnailImageURL = thumbnailURL
       self.userName = username
       self.profileImageURL = profileImageUrl
       self.postMainText = post.tastingNote.wineName
       self.postSubText = post.tastingNote.memo ?? ""
       
       self.postSubTextIsHidden = post.tastingNote.memo == nil ? true : false
   }
}
