//
//  HelpCell.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/12/29.
//

import UIKit

class HelpCell: UITableViewCell {
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
