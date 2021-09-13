//
//  WineTastingNote+CoreDataProperties.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/17.
//
//

import Foundation
import CoreData
import UIKit

extension WineTastingNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WineTastingNote> {
        return NSFetchRequest<WineTastingNote>(entityName: "WineTastingNote")
    }
    
    @NSManaged public var postingDate: Date
    @NSManaged public var updatedDate: Date?
    @NSManaged public var tastingDate: Date
    @NSManaged public var place: String?
    @NSManaged public var image: [UIImage]
    @NSManaged public var wineName: String
    @NSManaged public var category: String?
    @NSManaged public var varieties: [String]?
    @NSManaged public var producingCountry: String?
    @NSManaged public var producer: String?
    @NSManaged public var vintage: String?
    @NSManaged public var price: Int32
    @NSManaged public var alcoholContent: Float
    @NSManaged public var sweet: Int16
    @NSManaged public var acidity: Int16
    @NSManaged public var tannin: Int16
    @NSManaged public var body: Int16
    @NSManaged public var aromasAndFlavors: [String]?
    @NSManaged public var memo: String?
    @NSManaged public var rating: Int16
}

extension WineTastingNote : Identifiable {

}
