//
//  Like.swift
//  WineCalender
//
//  Created by Susan Kim on 2021/10/29.
//

import Foundation

struct PostLike: Decodable {
    let likes: [Like]
}

struct Like: Decodable {
    let authorUID: String
    let timestamp: Date
}
