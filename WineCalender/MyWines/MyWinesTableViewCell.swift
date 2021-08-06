//
//  MyWinesTableViewCell.swift
//  WineCalender
//
//  Created by GnoJng on 8/6/21.
//

import UIKit

class MyWinesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var wineNameLabel: UILabel!
    @IBOutlet weak var wineCategoryLabel: UILabel!
    @IBOutlet weak var wineCellBG: UIView!
    @IBOutlet weak var wineImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
