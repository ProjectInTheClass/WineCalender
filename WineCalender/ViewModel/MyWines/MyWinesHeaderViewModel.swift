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
    
    init (user: User?, num: Int) {
        self.profileImageURL = user?.profileImageURL
        self.nickname = user?.nickname ?? "비회원"
        self.introduction = user?.introduction
        self.numberOfPosts = "\(num) 게시물"
    }
}
