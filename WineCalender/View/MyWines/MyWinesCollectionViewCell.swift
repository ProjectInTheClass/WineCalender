//
//  MyWinesCollectionViewCell.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/29.
//

import UIKit
import Kingfisher

class MyWinesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
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
            label1.text = vm.wineNameDescription
            label2.text = vm.tastingDateDescription
            label3.text = vm.ratingDescription
        }
    }
    
    func updateNote() {
        if let note = note {
            let vm = MyWinesViewModel(note: note)
            imageView.image = vm.firstImage
            label1.text = vm.wineNameDescription
            label2.text = vm.tastingDateDescription
            label3.text = vm.ratingDescription
        }
    }
}
