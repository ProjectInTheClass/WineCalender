//
//  MyWinesCollectionViewCell.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/29.
//

import UIKit

class MyWinesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    func update(myWine: MyWinesModel) {
        DispatchQueue.main.async {
            self.imageView.image = myWine.firstImage
            self.label1.text = myWine.wineNameDescription
            self.label2.text = myWine.tastingDateDescription
            self.label3.text = myWine.ratingDescription
        }
    }
}
