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
    
    var myWinesViewModel: MyWinesViewModel? {
        didSet{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.locale = Locale(identifier: "ko_kr")
            
            DispatchQueue.main.async {
                self.imageView.kf.setImage(with: self.myWinesViewModel?.firstImageURL)
                self.label1.text = "🍷 " + self.myWinesViewModel!.wineName
                self.label2.text = "🗓 " + dateFormatter.string(from: self.myWinesViewModel!.tastingDate)
                self.label3.text = "⭐️ " + "\(self.myWinesViewModel?.rating ?? 0)"
            }
        }
    }
}
