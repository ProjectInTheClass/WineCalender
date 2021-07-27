//
//  UserCardView.swift
//  WineCalender
//
//  Created by 강재권 on 2021/07/27.
//

import Foundation
import UIKit

class UserCardView : UIView {
    @IBOutlet var userCardView: UIView!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder : NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle  = Bundle(for: UserCardView.self)
        bundle.loadNibNamed("UserCardView",owner: self, options:nil)
        addSubview(userCardView)
        userCardView.frame = self.bounds
        userCardView.autoresizingMask = [.flexibleHeight , .flexibleWidth]
    }
}
