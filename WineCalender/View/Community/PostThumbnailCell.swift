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
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    var postThumbnailVM : PostThumbnailVM?{
        didSet {
            updateView()
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateView(){
        guard let vm = postThumbnailVM else { return }
        
        subTitle.isHidden = vm.subTextIsHidden
        postCardView.backgroundColor = vm.color
        cellImage.kf.setImage(with: vm.thumbnailImageURL)
        
        profileName.text = vm.userName
        profileImage.layer.borderColor = UIColor.lightGray.cgColor
        profileImage.kf.setImage(with: vm.profileImageURL, placeholder: profileImagePlaceholder)

        mainTitle.text = vm.mainText
        subTitle.text = vm.subText
        likesLabel.text = vm.likeCount
        commentsLabel.text = vm.commentCount
    }
}
