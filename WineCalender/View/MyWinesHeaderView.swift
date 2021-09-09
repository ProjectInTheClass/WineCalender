//
//  MyWinesHeaderView.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/08.
//

import UIKit
import FirebaseAuth

class MyWinesHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    
    var userViewModel: UserViewModel? {
        didSet {
            if Auth.auth().currentUser == nil {
                self.profileImageView.image = UIImage(systemName: "person.circle.fill")
                self.nicknameLabel.text = "비회원"
                self.introductionLabel.text = ""
            } else {
                DispatchQueue.main.async {
                    if let url = self.userViewModel?.profileImageURL {
                        self.profileImageView.kf.setImage(with: url)
                    } else {
                        self.profileImageView.image = UIImage(systemName: "person.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
                    }
                    self.nicknameLabel.text = self.userViewModel?.nickname
                    self.introductionLabel.text = self.userViewModel?.introduction
                }
            }
        }
    }
}
