//
//  NoticeCell.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/12/29.
//

import UIKit

class NoticeCell: UITableViewCell {
    
    var dateLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(dateLabel)
        dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
