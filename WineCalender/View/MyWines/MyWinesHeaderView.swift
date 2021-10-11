//
//  MyWinesHeaderView.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/08.
//

import UIKit
import Kingfisher
import FirebaseAuth

class MyWinesHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var numberOfPostsLabel: UILabel!
    @IBOutlet weak var numberOfFollowersLabel: UILabel!
    @IBOutlet weak var numberOfFollowingsLabel: UILabel!
    
    func update(vm: MyWinesHeaderViewModel) {
        DispatchQueue.main.async {
            self.profileImageView.layer.borderColor = UIColor.white.cgColor
            self.profileImageView.layer.borderWidth = 6
            
            if Auth.auth().currentUser != nil {
                if let url = vm.profileImageURL {
                    self.profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle.fill")!.withTintColor(.systemPurple, renderingMode: .alwaysOriginal))
                } else {
                    self.profileImageView.image = UIImage(systemName: "person.circle.fill")!.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
                }
            } else {
                self.profileImageView.image = UIImage(systemName: "person.circle.fill")
            }

            self.nicknameLabel.text = vm.nickname
            self.introductionLabel.text = vm.introduction
            
            if vm.numberOfPosts == "0" {
                self.numberOfPostsLabel.textColor = UIColor.systemGray2
            } else {
                self.numberOfPostsLabel.textColor = UIColor(named: "blackAndWhite")
            }
            self.numberOfPostsLabel.text = vm.numberOfPosts
        }
    }
}
