//
//  UserViewModel.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/06.
//

import Foundation

struct UserViewModel {
    let email: String
    let profileImageURL: URL?
    let nickname: String
    let introduction: String?
    
    
    init (user: User) {
        self.email = user.email
        self.profileImageURL = user.profileImageURL
        self.nickname = user.nickname
        self.introduction = user.introduction
        
    }
    
}
