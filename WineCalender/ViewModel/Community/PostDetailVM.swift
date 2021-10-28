//
//  PostDetailVM.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/10/18.
//

import Foundation
import UIKit

struct PostDetailVM {
    let userName : String?
    let userProfileImage : URL?
    let postCardColor : UIColor?
//    let isMine : Bool?
//    let postImages : [URL]?
    let memo : String?
    let wineName: String?
    let addPostDate: Date?
    
    init(_ post:Post,_ username:String,_ profileImageUrl:URL?,_ color:UIColor) {
        self.userName = username
        self.userProfileImage = profileImageUrl
//        self.postImages =
        self.postCardColor = color
        self.memo = post.tastingNote.memo
        self.wineName = post.tastingNote.wineName
        self.addPostDate = post.tastingNote.tastingDate
   }
}
