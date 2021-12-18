//
//  PostDetailVM.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/10/18.
//

import Foundation
import UIKit

struct PostDetailVM {
    let backgroundColor : UIColor?
    
    let userName : String?
    let userProfileImage : URL?
    
    let date: String
    
    let isMoreButtonHidden: Bool
    let isLikeHidden: Bool
    
    let postImageUrls: [URL]
    let imageCount: Int
    let memo: String
    
    let wineName: String
    let producingCountry: String
    let vintage: String
    
    init(_ post: Post, _ username: String, _ profileImageUrl: URL?, _ color: UIColor) {
        self.backgroundColor = color
        
        self.userName = username
        self.userProfileImage = profileImageUrl
        
        let formatter = DateComponentsFormatter()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_kr")
        formatter.calendar = calendar
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.minute, .second, .hour, .day, .month, .calendar]
        formatter.maximumUnitCount = 1
        let timeDifference = post.postingDate.distance(to: Date())
        if let diff = formatter.string(from: timeDifference) {
            self.date = "\(diff) 전"
        } else {
            self.date = DateFormatter().string(from: post.postingDate)
        }
        
        self.isMoreButtonHidden = false
        self.isLikeHidden = false
        
        self.postImageUrls = post.postImageURL.compactMap { URL(string: $0) }
        self.imageCount = postImageUrls.count
        self.memo = post.tastingNote.memo ?? ""
        
        self.wineName = post.tastingNote.wineName
        self.producingCountry = post.tastingNote.producingCountry ?? "--"
        self.vintage = post.tastingNote.vintage ?? "--"
   }
}
