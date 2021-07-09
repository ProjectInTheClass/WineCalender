//
//  Calendar.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/07/09.
//

import UIKit

struct ScheduleAndMyWinesData {
    var scheduleAndMyWinesDate: Date
    var scheduleDescription: String?
    var wineName: String?
    var category: Categories?
    var categoryImage: UIImage?
    
    init (scheduleAndMyWinesDate: Date, scheduleDescription:String, wineName: String, category: Categories) {
        self.scheduleAndMyWinesDate = scheduleAndMyWinesDate
        self.scheduleDescription = scheduleDescription
        self.wineName = wineName
        self.category = category
        self.categoryImage = self.category?.categoryImage
    }
    
    init (scheduleAndMyWinesDate: Date, scheduleDescription:String, category: Categories) {
        self.scheduleAndMyWinesDate = scheduleAndMyWinesDate
        self.scheduleDescription = scheduleDescription
        //self.wineName = wineName
        self.category = category
        self.categoryImage = self.category?.categoryImage
    }
}

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
        case .Schedule: return UIImage(named: "wine_black") ?? UIImage()
        }
    }
}

