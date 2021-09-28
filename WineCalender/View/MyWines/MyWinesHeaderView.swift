//
//  MyWinesHeaderView.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/08.
//

import UIKit

class MyWinesHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    
    func update(user: MyWinesHeaderViewModel) {
        DispatchQueue.main.async {
            self.profileImageView.layer.borderColor = UIColor.white.cgColor
            self.profileImageView.layer.borderWidth = 6
            self.profileImageView.image = user.profileImage
            self.nicknameLabel.text = user.nickname
            self.introductionLabel.text = user.introduction
        }
    }
}
