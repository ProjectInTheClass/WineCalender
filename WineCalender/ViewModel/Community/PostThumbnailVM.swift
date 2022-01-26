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
    UIColor(named:"postCard4"),
]

struct PostThumbnailVM {
    // 바로 알 수 있는 것
    let postID: String
    let authorID: String
    let thumbnailImageURL : URL?
    let mainText : String
    let subText : String
    let subTextIsHidden : Bool
    let color : UIColor
    let likeCount: String
    let commentCount: String
    let isReported: Bool?
    
    // 받아와야 하는 것
    let userName : String
    let profileImageURL : URL?

    init(_ post:Post,_ username:String,_ profileImageUrl:URL?,_ index: Int) {
        self.postID = post.postID
        self.authorID = post.authorUID
        self.thumbnailImageURL = URL(string: post.postImageURL[0])
        self.userName = username
        self.profileImageURL = profileImageUrl
        self.mainText = post.tastingNote.wineName
        self.subText = post.tastingNote.memo ?? ""
        self.color = postCardColorSet[index % postCardColorSet.count]!
        
        self.subTextIsHidden = post.tastingNote.memo == nil ? true : false
        
        self.likeCount = "\(post.likeCount ?? 0)"
        self.commentCount = "\(post.commentCount ?? 0)"
        
        self.isReported = post.isReported
    }
    
    func profileImage(completion: (User)->()) {
        
    }
}
