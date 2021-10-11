//
//  MyWinesHeaderViewModel.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/06.
//

import Foundation

class MyWinesHeaderViewModel {
    
    let profileImageURL: URL?
    let nickname: String
    let introduction: String?
    var numberOfPosts: String
    
    init (user: User?, posts: Int) {
        self.profileImageURL = user?.profileImageURL
        self.nickname = user?.nickname ?? "비회원"
        self.introduction = user?.introduction
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        var formattedPosts = ""
        if posts < 10000 {
            formattedPosts = numberFormatter.string(for: posts)!
        } else if posts >= 10000 && posts < 100000000 {
            let num = posts / 10000
            formattedPosts = numberFormatter.string(for: num)! + "만"
        } else if posts >= 100000000{
            let num = posts / 100000000
            formattedPosts = numberFormatter.string(for: num)! + "억"
        }
        self.numberOfPosts = formattedPosts
    }
}
