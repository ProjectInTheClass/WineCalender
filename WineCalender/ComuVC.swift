//
//  ComuVC.swift
//  WineCalender
//
//  Created by 강재권 on 2021/07/26.
//

import Foundation
import UIKit
import SnapKit


class ComuVC : ViewController {
    @IBOutlet weak var ScrollFrameView: UIView!
    
    let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    let stackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 9
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        for count in 0..<20 {
            let userCardView = UIView()
            
            let userCardImageView: UIImageView = {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFit
                imageView.image = UIImage(systemName: "paperplane.fill")
                return imageView
            }()
            
            userCardView.addSubview(userCardImageView)
            userCardImageView.snp.makeConstraints{ make in
                make.top.left.right.equalToSuperview()
                make.centerX.equalToSuperview()
            }
            
            let cardLabel : UILabel = {
                let label = UILabel()
                label.text = "\(count+1)"
                label.textColor = .black
                
                return label
            }()
            userCardImageView.addSubview(cardLabel)
            cardLabel.snp.makeConstraints{ make in
                make.top.equalTo(userCardImageView.snp.bottom).offset(8)
                make.bottom.centerX.equalToSuperview()
            }
            stackView.addArrangedSubview(userCardImageView)
        }
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.left.right.bottom.height.equalToSuperview()
        }
        ScrollFrameView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.left.right.bottom.height.equalToSuperview()
            
        }
        
    }
}
