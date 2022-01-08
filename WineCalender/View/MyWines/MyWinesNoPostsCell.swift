//
//  MyWinesNoPostsCell.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/11/14.
//

import UIKit

class MyWinesNoPostsCell: UICollectionViewCell {
    
    @IBOutlet weak var addTastingNoteButton: UIButton!
    @IBOutlet weak var signUpAndSignInButton: UIButton!
    
    var isMember: Bool? = nil {
        didSet {
            if isMember == false {
                addTastingNoteButton.setTitle("비회원으로 게시물 작성하기", for: .normal)
                signUpAndSignInButton.setTitle("회원가입 / 로그인하기", for: .normal)
                signUpAndSignInButton.isHidden = false
            } else {
                addTastingNoteButton.setTitle("게시물 작성하기", for: .normal)
                signUpAndSignInButton.isHidden = true
            }
        }
    }
}
