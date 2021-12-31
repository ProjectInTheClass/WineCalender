//
//  UILabel+Extension.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/12/29.
//

import UIKit

extension UILabel {
    func lineSpacing() {
        guard let text = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        paragraphStyle.lineBreakStrategy = .hangulWordPriority
        
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        
        self.attributedText = attrString
    }
}
