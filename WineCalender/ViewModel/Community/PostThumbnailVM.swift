//
//  PostVM.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/09/09.
//

import Foundation
import UIKit

let postCardColorSet = [
    UIColor.init(red: 255/255.0, green: 181/255.0, blue: 181/255.0, alpha: 1),
    UIColor.init(red: 225/255.0, green: 181/255.0, blue: 255/255.0, alpha: 1),
    UIColor.init(red: 158/255.0, green: 251/255.0, blue: 255/255.0, alpha: 1),
    UIColor.init(red: 158/255.0, green: 255/255.0, blue: 190/255.0, alpha: 1),
    UIColor.init(red: 255/255.0, green: 234/255.0, blue: 158/255.0, alpha: 1),
    UIColor.init(red: 255/255.0, green: 158/255.0, blue: 192/255.0, alpha: 1),
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
       self.color = postCardColorSet[index % postCardColorSet.count]
       
       self.postSubTextIsHidden = post.tastingNote.memo == nil ? true : false
   }
}
