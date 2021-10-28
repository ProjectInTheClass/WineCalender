//
//  PostVM.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/09/09.
//

import Foundation
import UIKit

let postCardColorSet = [
    UIColor(named:"postCard0"),
    UIColor(named:"postCard1"),
    UIColor(named:"postCard2"),
    UIColor(named:"postCard3"),
    UIColor(named:"postCard4")
]

struct PostThumbnailVM {
    let thumbnailImageURL : URL?
    let userName : String
    let profileImageURL : URL?
    let postMainText : String
    let postSubText : String
    let postSubTextIsHidden : Bool
    let color : UIColor
    
    init(_ post:Post,_ username:String,_ profileImageUrl:URL?,_ index: Int) {
        let thumbnailURL = URL(string: post.postImageURL[0])
       
       self.thumbnailImageURL = thumbnailURL
       self.userName = username
       self.profileImageURL = profileImageUrl
       self.postMainText = post.tastingNote.wineName
       self.postSubText = post.tastingNote.memo ?? ""
        self.color = postCardColorSet[index % postCardColorSet.count]!
       
       self.postSubTextIsHidden = post.tastingNote.memo == nil ? true : false
   }
}
