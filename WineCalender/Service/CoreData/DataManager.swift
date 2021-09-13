//
//  DataManager.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/07/11.
//

import UIKit
import CoreData

class DataManager {
    
    static let shared = DataManager()
    private init() {
    }
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - WineTastingNote Data

    func fetchWineTastingNote(completion: @escaping ([WineTastingNote]) -> Void) {
        let request: NSFetchRequest<WineTastingNote> = WineTastingNote.fetchRequest()
        let sortByDESC = NSSortDescriptor(key: "postingDate", ascending: false)
        request.sortDescriptors = [sortByDESC]
        do {
            var wineTastingNoteList = [WineTastingNote]()
            wineTastingNoteList = try mainContext.fetch(request)
            completion(wineTastingNoteList)
        } catch {
            print(error)
        }
    }
    
    func addWineTastingNote(tastingNote: WineTastingNotes, images: [UIImage]){
        let object = NSEntityDescription.insertNewObject(forEntityName: "WineTastingNote", into: mainContext)

        let postingDate = Date()
        
        let compressedImagesDatas = images.map{ $0.jpegData(compressionQuality: 0.2) }
        let compressedImages = compressedImagesDatas.map{ UIImage(data:$0!) }
        
        object.setValue(postingDate, forKey: "postingDate")
        object.setValue(tastingNote.tastingDate, forKey: "tastingDate")
        object.setValue(tastingNote.place, forKey: "place")
        object.setValue(compressedImages, forKey: "image")
        object.setValue(tastingNote.wineName, forKey: "wineName")
        object.setValue(tastingNote.category, forKey: "category")
        object.setValue(tastingNote.varieties, forKey: "varieties")
        object.setValue(tastingNote.producingCountry, forKey: "producingCountry")
        object.setValue(tastingNote.producer, forKey: "producer")
        object.setValue(tastingNote.vintage, forKey: "vintage")
        object.setValue(tastingNote.price, forKey: "price")
        object.setValue(tastingNote.alcoholContent, forKey: "alcoholContent")
        object.setValue(tastingNote.sweet, forKey: "sweet")
        object.setValue(tastingNote.acidity, forKey: "acidity")
        object.setValue(tastingNote.tannin, forKey: "tannin")
        object.setValue(tastingNote.body, forKey: "body")
        object.setValue(tastingNote.aromasAndFlavors, forKey: "aromasAndFlavors")
        object.setValue(tastingNote.memo, forKey: "memo")
        object.setValue(tastingNote.rating, forKey: "rating")
        saveContext()
    }
    
    // MARK: - Calendar Data
    
    var selectedPageMonthEventList = [Event]()
    var eventDic = [Date:UIImage]()

    let dateFormatter = DateFormatter()
    let monthFormatter: DateFormatter = {
        let m = DateFormatter()
        m.dateFormat = "yyyy년 M월"
        return m
    }()
    
    func fetchEvent() {
        eventDic = [:]
        let request: NSFetchRequest<Event> = Event.fetchRequest()
        let sortByASC = NSSortDescriptor(key: "eventDate", ascending: true)
        request.sortDescriptors = [sortByASC]
        do {
            let eventList = try mainContext.fetch(request)
            selectedPageMonthEventList = eventList.filter{ monthFormatter.string(from: $0.eventDate!) == CalendarViewController.selectedPageMonth }
            updateSelectedPageMonth()
        } catch {
            print(error)
        }
    }
    
    func addSchedule(date: Date, category: String, place: String, description: String){
        let object = NSEntityDescription.insertNewObject(forEntityName: "Schedule", into: mainContext)
        object.setValue(date, forKey: "eventDate")
        object.setValue(category, forKey: "eventCategory")
        object.setValue(place, forKey: "schedulePlace")
        object.setValue(description, forKey: "scheduleDescription")
        saveContext()
    }
    
    func addMyWine(date: Date, category: String, wineName: String){
        let object = NSEntityDescription.insertNewObject(forEntityName: "MyWine", into: mainContext)
        object.setValue(date, forKey: "eventDate")
        object.setValue(category, forKey: "eventCategory")
        object.setValue(wineName, forKey: "wineName")
        saveContext()
    }
    
    func deleteSchedule(schedule: Schedule?) {
        if let schedule = schedule {
            mainContext.delete(schedule)
            saveContext()
        }
    }
    
    func updateSelectedPageMonth() {
        let count = selectedPageMonthEventList.count
        if count != 0 {
            for i in 0...count - 1 {
                if let date = selectedPageMonthEventList[i].eventDate,
                   let category = selectedPageMonthEventList[i].eventCategory{
                    updateEventDic(date: date, category: category)
                }
            }
        }
    }
    
    func updateEventDic(date: Date, category: String){
        var categoryImage = UIImage()
        switch category {
            case Categories.Red.rawValue :
                categoryImage = Categories.Red.categoryImage
            case Categories.White.rawValue :
                categoryImage = Categories.White.categoryImage
            case Categories.Rose.rawValue :
                categoryImage = Categories.Rose.categoryImage
            case Categories.Schedule.rawValue :
                categoryImage = Categories.Schedule.categoryImage
            default:
                break
        }
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd E"
        let eventDateStr = dateFormatter.string(from: date)
        if let eventDate = dateFormatter.date(from: eventDateStr){
            eventDic[eventDate] = categoryImage
        }
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "WineCalender")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
