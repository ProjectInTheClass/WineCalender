//
//  Comment.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/10.
//

import Foundation

struct Comment: Decodable {
    let authorUID: String
    let writingDate: Date
    let updatedDate: Date?
    let text: String
}
