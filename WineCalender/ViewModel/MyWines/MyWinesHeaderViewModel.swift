//
//  MyWinesHeaderViewModel.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/06.
//

import Foundation
import UIKit

class MyWinesHeaderViewModel {
    
    let profileImageURL: URL?
    let nickname: String
    let introduction: String?
    var numberOfPosts: String
    var numberOfPostsColor: UIColor
    
    init (user: User?, posts: Int) {
        self.profileImageURL = user?.profileImageURL
        self.nickname = user?.nickname ?? "비회원"
        self.introduction = user?.introduction
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if posts >= 10000 && posts < 100000000 {
            let num = posts / 10000
            self.numberOfPosts = numberFormatter.string(for: num)! + "만"
        } else if posts >= 100000000 {
            let num = posts / 100000000
            self.numberOfPosts = numberFormatter.string(for: num)! + "억"
        } else {
            self.numberOfPosts = numberFormatter.string(for: posts)!
        }
        
        if posts == 0 {
            self.numberOfPostsColor = UIColor.systemGray2
        } else {
            self.numberOfPostsColor = UIColor.label
        }
    }
}
