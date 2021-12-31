//
//  HelpCell.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/12/29.
//

import UIKit

class HelpCell: UITableViewCell {
    
    var showingDetail: Bool = false {
        didSet {
            didSelectRow()
        }
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var accessary: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.text = " "
        label.lineSpacing()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var titleLabelBottomAnchor: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCell() {
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        titleLabelBottomAnchor = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -16)
        titleLabelBottomAnchor?.isActive = true
        
        addSubview(accessary)
        accessary.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        accessary.leftAnchor.constraint(greaterThanOrEqualTo: titleLabel.rightAnchor, constant: 20).isActive = true
        accessary.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        
        accessary.text = "▽"
    }
    
    func didSelectRow() {
        if showingDetail {
            titleLabelBottomAnchor?.isActive = false
            
            addSubview(detailLabel)
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
            detailLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 30).isActive = true
            detailLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
            detailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
            
            accessary.text = "△"
        } else {
            configureCell()
        }
    }
}
