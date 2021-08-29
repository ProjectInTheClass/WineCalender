//
//  MyWinesCollectionViewCell.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/29.
//

import UIKit

class MyWinesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
}

class MyWinesHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
}
