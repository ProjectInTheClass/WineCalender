//
//  UILabel+Helpers.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/18.
//

import Foundation
import UIKit

extension UILabel {
    func labelIndent(string: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 7
        paragraphStyle.headIndent = 7
        paragraphStyle.tailIndent = -7
        paragraphStyle.minimumLineHeight = 20
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
}
