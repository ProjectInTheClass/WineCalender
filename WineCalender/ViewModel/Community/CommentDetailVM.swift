//
//  CommentDetailVM.swift
//  WineCalender
//
//  Created by Minju Lee on 2022/01/14.
//

import Foundation
import UIKit
import FirebaseAuth

struct CommentDetailVM {
    
    var profileImageUrl: URL?
    
    var nickname: String
    
    var commentText: String
    
    var date: String
    
    var isMoreButtonHidden: Bool
    
    func commentLabelText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(nickname) ", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
        
        attributedString.append(NSAttributedString(string: commentText, attributes: [.font: UIFont.systemFont(ofSize: 16)]))
        
        attributedString.append(NSAttributedString(string: "\n\(date)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.systemGray2]))
        
        return attributedString
    }
    
    init(_ comment: Comment) {
        
        
        if comment.profileImageUrl == nil && comment.nickname == "" {
            self.nickname = "알 수 없는 사용자"
            self.commentText = ""
            self.isMoreButtonHidden = true
        } else if comment.isReported == true {
            self.nickname = "알 수 없는 사용자"
            self.commentText = "신고된 댓글입니다."
            self.isMoreButtonHidden = true
        } else {
            self.profileImageUrl = comment.profileImageUrl
            self.nickname = comment.nickname
            self.commentText = comment.text
            self.isMoreButtonHidden = false
        }
        
        let formatter = DateComponentsFormatter()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_kr")
        formatter.calendar = calendar
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.minute, .second, .hour, .day, .month, .calendar]
        formatter.maximumUnitCount = 1
        let timeDifference = comment.date.distance(to: Date())
        if let diff = formatter.string(from: timeDifference) {
            self.date = "\(diff) 전"
        } else {
            self.date = DateFormatter().string(from: comment.date)
        }
    }
}
