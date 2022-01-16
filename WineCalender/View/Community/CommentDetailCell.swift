//
//  CommentDetailCell.swift
//  WineCalender
//
//  Created by Minju Lee on 2022/01/14.
//

import UIKit

class CommentDetailCell: UITableViewCell {
    
    var viewModel: CommentDetailVM? {
        didSet { configure() }
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    
    func configure() {
        guard let vm = viewModel else { return }
        profileImageView.kf.setImage(with: vm.profileImageUrl, placeholder: profileImagePlaceholder)
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        commentLabel.attributedText = vm.commentLabelText()
    }
}
