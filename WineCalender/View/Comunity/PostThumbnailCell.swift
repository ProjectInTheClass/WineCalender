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
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var postThumbnailVM : PostThumbnailVM?{
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        
        guard let vm = postThumbnailVM else { return }
        cellImage.kf.setImage(with: vm.thumbnailImageURL)
        profileName.text = vm.userName
        profileImage.kf.setImage(with: vm.profileImageURL) 
        
        cellImage.layer.cornerRadius = 10
        profileImage.layer.borderWidth = 0.1
        profileImage.layer.borderColor = UIColor.lightGray.cgColor
        // 뷰의 경계에 맞춰준다
        profileImage.clipsToBounds = true
    }
}
