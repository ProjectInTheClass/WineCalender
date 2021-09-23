//
//  MyWinesViewModel.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/10.
//

import Foundation
import Kingfisher
import FirebaseAuth

class MyWinesViewModel {

    let post: Post?
    
    let note: WineTastingNote?

    var firstImageURL: URL? {
        var url = URL(string: "")
        if let postImageURL = URL(string:post?.postImageURL[0] ?? "") {
            url = postImageURL
        }
        return url
    }
    
    var firstImage: UIImage {
        return note?.image[0] ?? UIImage()
    }
    
    var wineNameDescription: String {
        var string = ""
        if let post = post {
            string = self.wineNameToDescription(name: post.tastingNote.wineName)
        } else if let note = note {
            string = self.wineNameToDescription(name: note.wineName)
        }
        return string
    }
    
    var tastingDateDescription: String {
        var string = ""
        if let post = post {
            string = self.tastingDateToDescription(date: post.tastingNote.tastingDate)
        } else if let note = note {
            string = self.tastingDateToDescription(date: note.tastingDate)
        }
        return string
    }
    
    var ratingDescription: String {
        var string = ""
        if let post = post {
            string = self.ratingToDescription(rating: post.tastingNote.rating)
        } else if let note = note {
            string = self.ratingToDescription(rating: note.rating)
        }
        return string
    }

    //FireBase
    init(post: Post) {
        self.post = post
        self.note = nil
    }
    
    //CoreData
    init(note: WineTastingNote) {
        self.post = nil
        self.note = note
    }
    
    private func downloadImage(with urlString : String) -> UIImage {
        guard let url = URL(string: urlString) else { return UIImage() }
 
        let resource = ImageResource(downloadURL: url)
        var image = UIImage()
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                image = value.image
            case .failure:
                break
            }
        }
        return image
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
