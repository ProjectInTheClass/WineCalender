//
//  SearchTableViewCell.swift
//  WineCalender
//
//  Created by 강재권 on 2021/07/23.
//

import Foundation
import UIKit

class SearchTableViewCell : UITableViewCell {
    @IBOutlet weak var SearchView: UIView!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellSubTitle: UILabel!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var RightBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

