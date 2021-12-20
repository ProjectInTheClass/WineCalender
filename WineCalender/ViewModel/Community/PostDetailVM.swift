//
//  PostDetailVM.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/10/18.
//

import Foundation
import UIKit
import FirebaseAuth

struct PostDetailVM {
    let backgroundColor : UIColor?
    
    let userName : String?
    let profileImageURL : URL?
    
    let date: String
    
    let isMoreButtonHidden: Bool
    let isLikeHidden: Bool
    
    let postImageUrls: [URL]?
    let postImages: [UIImage]?
    let imageCount: Int
    let memo: String
    
    let wineName: String
    let producingCountry: String
    let vintage: String
    
    let isCoreData: Bool
    
    init(_ post: Post, _ username: String, _ profileImageUrl: URL?, _ color: UIColor) {
        self.backgroundColor = color
        
        self.userName = username
        self.profileImageURL = profileImageUrl
        
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
        
        self.isMoreButtonHidden = Auth.auth().currentUser?.uid != post.authorUID
        self.isLikeHidden = false
        
        self.postImageUrls = post.postImageURL.compactMap { URL(string: $0) }
        self.postImages = nil
        self.imageCount = postImageUrls?.count ?? 0
        self.memo = post.tastingNote.memo ?? ""
        
        self.wineName = post.tastingNote.wineName
        self.producingCountry = post.tastingNote.producingCountry ?? "--"
        self.vintage = post.tastingNote.vintage ?? "--"
        
        self.isCoreData = false
    }

    init(_ tastingNote: WineTastingNote, _ color: UIColor) {
        self.backgroundColor = color
        
        self.userName = "비회원"
        self.profileImageURL = nil
        
        let formatter = DateComponentsFormatter()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_kr")
        formatter.calendar = calendar
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.minute, .second, .hour, .day, .month, .calendar]
        formatter.maximumUnitCount = 1
        let timeDifference = tastingNote.postingDate.distance(to: Date())
        if let diff = formatter.string(from: timeDifference) {
            self.date = "\(diff) 전"
        } else {
            self.date = DateFormatter().string(from: tastingNote.postingDate)
        }
        
        self.isMoreButtonHidden = false
        self.isLikeHidden = true
        
        self.postImageUrls = nil
        self.postImages = tastingNote.image
        self.imageCount = postImages?.count ?? 0
        self.memo = tastingNote.memo ?? ""
        
        self.wineName = tastingNote.wineName
        self.producingCountry = tastingNote.producingCountry ?? "--"
        self.vintage = tastingNote.vintage ?? "--"
        
        self.isCoreData = true
    }
    
    func setProfileImage(of imageView: UIImageView) {
        if !isCoreData {
            imageView.backgroundColor = UIColor(named: "ThatWineColor")
        }
        imageView.kf.setImage(with: profileImageURL, placeholder: profileImagePlaceholder)
    }
}
