//
//  Categories.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/07/09.
//

import UIKit

enum Categories : String {
    case Red = "Red"
    case White = "White"
    case Rose = "Rose"
    case Schedule = "Schedule"

    var categoryImage: UIImage {
        switch self {
        case .Red: return UIImage(named: "wine_red") ?? UIImage()
        case .White: return UIImage(named: "wine_white") ?? UIImage()
        case .Rose: return UIImage(named: "wine_rose") ?? UIImage()
        case .Schedule: return UIImage(named: "wine_gray") ?? UIImage()
        }
    }
}
