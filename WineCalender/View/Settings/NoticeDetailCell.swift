//
//  NoticeDetailCell.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/12/29.
//

import UIKit

class NoticeDetailCell: UITableViewCell {
    
    var dateLabel: UILabel = {
       let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = " "
        label.lineSpacing()
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
        titleLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        
        addSubview(detailLabel)
        detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        detailLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        detailLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        detailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
