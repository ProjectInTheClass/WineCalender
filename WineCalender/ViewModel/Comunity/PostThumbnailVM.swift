//
//  PostVM.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/09/09.
//

import Foundation

struct PostThumbnailVM {
   let thumbnailImageURL : URL?
   let userName : String?
   let profileImageURL : URL?
   let postMainText : String?
   let postSubText : String?
   
   init(post:Post ) {
       let thumbnailURL = URL(string: post.postImageURL[0])
       
       self.thumbnailImageURL = thumbnailURL
       self.userName = "user.nickname"
       
       self.profileImageURL = URL(string: "user.profileImageURL")
       //Post모델에 User데이터 일부 넣기
       self.postMainText = post.tastingNote.wineName
       self.postSubText = post.tastingNote.memo

   }
}
