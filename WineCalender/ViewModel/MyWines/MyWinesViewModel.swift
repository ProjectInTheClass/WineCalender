//
//  MyWinesViewModel.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/10.
//

import Foundation
import Kingfisher
import FirebaseAuth

struct MyWinesModel {
    let postID: String?
    let postingDate: Date
    let firstImage: UIImage
    let wineNameDescription: String
    let tastingDateDescription: String
    let ratingDescription: String
}

class MyWinesViewModel {

    var onUpdated: () -> Void = {}

    var vm = [MyWinesModel]() {
        didSet {
            vm.sort { $0.postingDate > $1.postingDate }
            onUpdated()
        }
    }

    func fetchMyPosts() {
        vm = [MyWinesModel]()
        if Auth.auth().currentUser != nil {
            PostManager.shared.fetchMyPosts { myPosts in
                for post in myPosts {
                    let postID = post.postID
                    let postingDate = post.postingDate
                    self.downloadImage(with: post.postImageURL[0]) { image in
                        guard let image = image else { return }
                        let firstImage = image
                        let wineNameDescription = self.wineNameToDescription(name: post.tastingNote.wineName)
                        let tastingDateDescription = self.tastingDateToDescription(date: post.tastingNote.tastingDate)
                        let ratingDescription = self.ratingToDescription(rating: post.tastingNote.rating)
                        self.vm.append(MyWinesModel(postID: postID, postingDate: postingDate, firstImage: firstImage, wineNameDescription: wineNameDescription, tastingDateDescription: tastingDateDescription, ratingDescription: ratingDescription))
                    }
                }
            }
        } else {
            DataManager.shared.fetchWineTastingNote { myWineTastingNotes in
                for note in myWineTastingNotes {
                    let postingDate = note.postingDate
                    let firstImage = note.image[0]
                    let wineNameDescription = self.wineNameToDescription(name: note.wineName)
                    let tastingDateDescription = self.tastingDateToDescription(date: note.tastingDate)
                    let ratingDescription = self.ratingToDescription(rating: note.rating)
                    self.vm.append(MyWinesModel(postID: nil, postingDate: postingDate, firstImage: firstImage, wineNameDescription: wineNameDescription, tastingDateDescription: tastingDateDescription, ratingDescription: ratingDescription))
                }
            }
        }
    }
    
    private func downloadImage(with urlString : String, imageCompletionHandler: @escaping (UIImage?) -> Void){
        guard let url = URL(string: urlString) else {
            return  imageCompletionHandler(nil)
        }
        let resource = ImageResource(downloadURL: url)
        
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                imageCompletionHandler(value.image)
            case .failure:
                imageCompletionHandler(nil)
            }
        }
    }

    private func wineNameToDescription(name: String) -> String {
        return "🍷 " + name
    }

    private func tastingDateToDescription(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ko_kr")
        return "🗓 " + dateFormatter.string(from: date)
    }

    private func ratingToDescription(rating: Int16?) -> String {
        return "⭐️ " + "\(rating ?? 0)"
    }
}
