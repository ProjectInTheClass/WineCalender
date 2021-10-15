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
            self.profileImageView.layer.borderColor = UIColor(named: "whiteAndBlack")!.cgColor
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
            self.numberOfPostsLabel.text = vm.numberOfPosts
            self.numberOfPostsLabel.textColor = vm.numberOfPostsColor
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if traitCollection.userInterfaceStyle == .dark {
                    self.profileImageView.layer.borderColor = UIColor.black.cgColor
                }
                else {
                    self.profileImageView.layer.borderColor = UIColor.white.cgColor
                }
            }
        } else {
            self.profileImageView.layer.borderColor = UIColor.white.cgColor
        }
    }
}
