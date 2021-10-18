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
    let memo : String?
    let wineName: String?
    
    init(_ post:Post,_ username:String,_ profileImageUrl:URL?,_ color:UIColor) {
        self.userName = username
        self.userProfileImage = profileImageUrl
        self.postCardColor = color
        self.memo = post.tastingNote.memo
        self.wineName = post.tastingNote.wineName
   }
}
