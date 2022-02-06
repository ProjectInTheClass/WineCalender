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
    
    var vm: MyWinesHeaderViewModel? {
        didSet {
            update()
        }
    }
    
    var isMember: Bool?
    
    func update() {
        DispatchQueue.main.async { [weak self] in
            guard let vm = self?.vm, let isMember = self?.isMember else { return }
            if isMember { //회원, 다른 유저
                self?.profileImageView.backgroundColor = UIColor(named: "ThatWineColor")
                if let url = vm.profileImageURL {
                    self?.profileImageView.kf.setImage(with: url, placeholder: profileImagePlaceholder)
                }
                self?.introductionLabel.text = vm.introduction
            } else { //비회원
                self?.profileImageView.backgroundColor = .systemGray4
            }
            self?.nicknameLabel.text = vm.nickname
            self?.numberOfPostsLabel.text = vm.numberOfPosts
            self?.numberOfPostsLabel.textColor = vm.numberOfPostsColor
            self?.introductionLabel.setContentHuggingPriority(UILayoutPriority(Float(252)), for: .vertical)
        }
    }
    
//    다크모드 변화 감지
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
//        if #available(iOS 13.0, *) {
//            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//                if traitCollection.userInterfaceStyle == .dark {
//                    self.profileImageView.layer.borderColor = UIColor.black.cgColor
//                }
//                else {
//                    self.profileImageView.layer.borderColor = UIColor.white.cgColor
//                }
//            }
//        } else {
//            self.profileImageView.layer.borderColor = UIColor.white.cgColor
//        }
//    }
}
