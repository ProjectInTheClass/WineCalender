//
//  Comment.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/10.
//

import Foundation

struct Comment {
    let uid: String
    let profileImageUrl: URL?
    let nickname: String
    let text: String
    let date: Date
    let commentID: String
    
    init(dictionary: [String: Any], url: URL?, nickname: String) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.profileImageUrl = url
        self.nickname = nickname
        self.text = dictionary["text"] as? String ?? ""
        if let date = dictionary["date"] as? Double {
            self.date = Date(timeIntervalSince1970: date)
        } else {
            self.date = Date()
        }
        self.commentID = dictionary["commentID"] as? String ?? ""
    }
}
