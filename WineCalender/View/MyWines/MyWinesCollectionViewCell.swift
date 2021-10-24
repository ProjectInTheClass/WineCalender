//
//  MyWinesCollectionViewCell.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/29.
//

import UIKit
import Kingfisher

class MyWinesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var wineNameLabel: UILabel!
    @IBOutlet weak var tastingDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var numberOfComentsLabel: UILabel!
    @IBOutlet weak var wineStackView: UIStackView!
    @IBOutlet weak var likesComentsStackView: UIStackView!
    @IBOutlet weak var imageViewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingAnchor: NSLayoutConstraint!
    
    var post: Post? {
        didSet {
            updatePost()
        }
    }
    var note: WineTastingNote? {
        didSet {
            updateNote()
        }
    }

    func updatePost() {
        if let post = post {
            let vm = MyWinesViewModel(post: post)
            imageView.kf.setImage(with: vm.firstImageURL)
            wineNameLabel.text = vm.wineNameDescription
            tastingDateLabel.text = vm.tastingDateDescription
            ratingLabel.text = vm.ratingDescription
        }
    }
    
    func updateNote() {
        if let note = note {
            let vm = MyWinesViewModel(note: note)
            imageView.image = vm.firstImage
            wineNameLabel.text = vm.wineNameDescription
            tastingDateLabel.text = vm.tastingDateDescription
            ratingLabel.text = vm.ratingDescription
        }
    }
}
