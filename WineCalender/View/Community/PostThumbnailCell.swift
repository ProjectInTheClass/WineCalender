//
//  PostThumbnailCell.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/09/09.
//

import Foundation
import UIKit
import Kingfisher

class PostThumbnailCell : UICollectionViewCell {
    @IBOutlet weak var postCardView: UIView!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var thumnailBottom: UIView!
    
    
    var postThumbnailVM : PostThumbnailVM?{
        didSet{
            updateView()
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateView(){
        
        guard let vm = postThumbnailVM else { return }
        
        subTitle.isHidden = vm.postSubTextIsHidden
        postCardView.backgroundColor = vm.color
//        thumnailBottom.backgroundColor = vm.color
        cellImage.kf.setImage(with: vm.thumbnailImageURL)
        profileName.text = vm.userName
        profileImage.kf.setImage(with: vm.profileImageURL, placeholder: UIImage(systemName: "person.circle.fill")!.withTintColor(.systemPurple, renderingMode: .alwaysOriginal))

        mainTitle.text = vm.postMainText
        subTitle.text = vm.postSubText

        cellImage.layer.cornerRadius = 5
        profileImage.layer.borderWidth = 0.1
        profileImage.layer.borderColor = UIColor.lightGray.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        // 뷰의 경계에 맞춰준다
        profileImage.clipsToBounds = true
    }
}
