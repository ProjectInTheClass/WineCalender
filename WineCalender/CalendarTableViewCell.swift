//
//  CalendarTableViewCell.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/07/09.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var calendarImageView: UIImageView!
    @IBOutlet weak var calendarDateLabel: UILabel!
    @IBOutlet weak var calendarTimeLabel: UILabel!
    @IBOutlet weak var calendarDescriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
