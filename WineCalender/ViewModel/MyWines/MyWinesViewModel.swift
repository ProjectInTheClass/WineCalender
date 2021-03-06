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
    
    var firstImage: UIImage? {
        return note?.image[0]
    }
    
    var wineNameDescription: String {
        var name = ""
        if let post = post {
            name = post.tastingNote.wineName
        } else if let note = note {
            name = note.wineName
        }
        return "🍷 " + name
    }
    
    var tastingDateDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ko_kr")
        
        var date = Date()
        if let post = post {
            date = post.tastingNote.tastingDate
        } else if let note = note {
            date = note.tastingDate
        }
        return "🗓 " + dateFormatter.string(from: date)
    }
    
    var ratingDescription: String {
        var rating: String = ""
        if let post = post {
            if post.tastingNote.rating == nil {
                rating = ""
            } else {
                rating = String(post.tastingNote.rating!)
            }
        } else if let note = note {
            if note.rating == 0 {
                rating = ""
            } else {
                rating = String(note.rating)
            }
        }
        return "⭐️ " + rating
    }
    
    var likeCount: String {
        var like: String = ""
        if let post = post, let count = post.likeCount {
            like = String(count)
        } else {
            like = "0"
        }
        return like
    }
    
    var commentCount: String {
        var comment: String = ""
        if let post = post, let count = post.commentCount {
            comment = String(count)
        } else {
            comment = "0"
        }
        return comment
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
}
