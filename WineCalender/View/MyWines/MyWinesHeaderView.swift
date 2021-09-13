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
            self.profileImageView.image = user.profileImage
            self.nicknameLabel.text = user.nickname
            self.introductionLabel.text = user.introduction
        }
    }
    
//    var myWinesHeaderViewModel: MyWinesHeaderViewModel? {
//        didSet {
//            if Auth.auth().currentUser == nil {
//                self.profileImageView.image = UIImage(systemName: "person.circle.fill")
//                self.nicknameLabel.text = "비회원"
//                self.introductionLabel.text = ""
//            } else {
//                DispatchQueue.main.async {
//                    if let url = self.myWinesHeaderViewModel?.profileImageURL {
//                        self.profileImageView.kf.setImage(with: url)
//                    } else {
//                        self.profileImageView.image = UIImage(systemName: "person.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
//                    }
//                    self.nicknameLabel.text = self.myWinesHeaderViewModel?.nickname
//                    self.introductionLabel.text = self.myWinesHeaderViewModel?.introduction
//                }
//            }
//        }
//    }
}
