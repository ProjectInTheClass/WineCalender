//
//  PostManager.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/24.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase

class PostManager {
    
    static let shared = PostManager()
    
    let postRef = Database.database(url: "https://wine-calendar-3e6a1-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("Post")
    let recentPostRef = Database.database(url: "https://wine-calendar-3e6a1-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("RecentPost")
    
    //let postRef = Database.database().reference().child("Post")
    let postImageRef = Storage.storage().reference().child("PostImage")
    
    func uploadPost(posting: Date?, updated: Date?, tastingNote: WineTastingNotes, images: [UIImage], completion: @escaping (Result<Void,PostError>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let postID = PostManager.shared.postRef.childByAutoId().key else { return }
        var postImageURLDict = [String:String]()
        
        uploadImage { [weak self] result in
            if result == true {
                var postingDate: Double? = nil
                if posting == nil {
                    postingDate = (Date().timeIntervalSince1970).rounded()
                } else {
                    postingDate = (posting!.timeIntervalSince1970).rounded()
                }
                
                var updatedDate: Double? = nil
                if updated == nil {
                    updatedDate = nil
                } else {
                    updatedDate = (updated!.timeIntervalSince1970).rounded()
                }
                
                let tastingDate: Double = (tastingNote.tastingDate.timeIntervalSince1970).rounded()
                let tastingNote = ["tastingDate":tastingDate, "place":tastingNote.place as Any, "wineName":tastingNote.wineName as Any, "category":tastingNote.category as Any, "varieties":tastingNote.varieties as Any, "producingCountry":tastingNote.producingCountry as Any, "producer":tastingNote.producer as Any, "vintage":tastingNote.vintage as Any, "price":tastingNote.price as Any, "alcoholContent":tastingNote.alcoholContent as Any, "sweet":tastingNote.sweet as Any, "acidity":tastingNote.acidity as Any, "tannin":tastingNote.tannin as Any, "body":tastingNote.body as Any, "aromasAndFlavors":tastingNote.aromasAndFlavors as Any, "memo":tastingNote.memo as Any, "rating":tastingNote.rating as Any] as [String : Any]
                
                let value = ["postImageURL":postImageURLDict, "postID":postID, "authorUID":uid, "postingDate":postingDate as Any, "updatedDate":updatedDate as Any, "tastingNote":tastingNote] as [String:Any]
                
                PostManager.shared.postRef.child(uid).child(postID).updateChildValues(value) { error, ref in
                    if let error = error {
                        //error2) image만 업로드됨
                        //image 삭제
                        print("image만 업로드되고, DB에 업로드실패 : \(error.localizedDescription)")
                        self?.removeMyPostImages(postID: postID, numberOfImage: images.count) { result in
                            completion(.failure(PostError.failedToUploadPost))
                        }
                    } else {
                        // add recent post ID
                        guard let recentPostID = PostManager.shared.recentPostRef.childByAutoId().key else { return }
                        let recentPostValue = ["postID":postID, "authorID":uid, "postedDate":postingDate as Any] as [String:Any]
                        PostManager.shared.recentPostRef.child(recentPostID).updateChildValues(recentPostValue) { error, ref in
                            if let error = error {
                                //error3) image, postRef만 업로드됨
                                //postRef, image 삭제
                                print("image, postRef만 업로드되고, recentPostRef에 업로드실패 : \(error.localizedDescription)")
                                self?.removeMyPost(postID: postID, authorUID: uid, numberOfImage: images.count) { result in
                                    completion(.failure(PostError.failedToUploadPost))
                                }
                            } else {
                                completion(.success(()))
                            }
                        }
                    }
                }
            } else {
                //error1) image 업로드 중 에러
                //image 삭제
                self?.removeMyPostImages(postID: postID, numberOfImage: images.count) { result in
                    completion(.failure(PostError.failedToUploadPost))
                }
            }
        }
        
        func uploadImage(imageUploadCompletion: @escaping (Bool) -> Void) {
            var uploadCount = 0
            for (index, image) in images.enumerated() {
                let imageName = postID + String(index) + ".jpg"
                if let postImageData = image.jpegData(compressionQuality: 0.2) {
                    PostManager.shared.postImageRef.child(postID).child(imageName).putData(postImageData, metadata: nil) { metadata, error in
                        //storage 위치 변경
                        //PostManager.shared.postImageRef.child(uid).child(postID).child(imageName).putData(postImageData, metadata: nil) { metadata, error in
                        if let error = error {
                            imageUploadCompletion(false)
                            print("이미지 등록 에러 : \(error.localizedDescription)")
                        } else {
                            PostManager.shared.postImageRef.child(postID).child(imageName).downloadURL { url, error in
                                //storage 위치 변경
                                //PostManager.shared.postImageRef.child(uid).child(postID).child(imageName).downloadURL { url, error in
                                if let error = error {
                                    imageUploadCompletion(false)
                                    print("downloadURL 에러 : \(error.localizedDescription)")
                                } else {
                                    guard let urlString: String = url?.absoluteString else { return }
                                    postImageURLDict["\(index)"] = urlString
                                    uploadCount = uploadCount + 1
                                    if images.count == uploadCount {
                                        imageUploadCompletion(true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //For My Wines
    func fetchMyPosts(completion: @escaping ([Post]?) -> Void){
        if let uid = Auth.auth().currentUser?.uid {
            PostManager.shared.postRef.child(uid).observe(DataEventType.value) { snapshot in
                guard let snapshotDict = snapshot.value as? [String:Any] else {
                    completion(nil)
                    return
                }
                let datas = Array(snapshotDict.values)
                guard let data = try? JSONSerialization.data(withJSONObject: datas, options: []) else { return }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970

                guard let posts = try? decoder.decode([Post].self, from: data) else { return }

                var myPosts: [Post] = posts
                myPosts.sort{ $0.postingDate > $1.postingDate }

                completion(myPosts)
            }
        }
    }
    
    //For Update
    func fetchMyPost(postID: String, completion: @escaping (Post) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        PostManager.shared.postRef.child(uid).child(postID).observeSingleEvent(of: .value) { snapshot in
            guard let snapshotDict = snapshot.value as? NSDictionary else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: snapshotDict, options: []) else { return }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            guard let post = try? decoder.decode(Post.self, from: data) else { return }

            completion(post)
        }
    }
    
    func removeMyPost(postID: String, authorUID: String, numberOfImage: Int, completion: @escaping (Bool) -> Void) {
        guard authorUID == Auth.auth().currentUser?.uid else { return }
        PostManager.shared.postRef.child(authorUID).child(postID).removeValue { [weak self] error, databaseReference in
            if let error = error {
                print(error)
            } else {
                self?.removeMyPostImages(postID: postID, numberOfImage: numberOfImage) { result in
                    if result == true {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    func removeMyPostImages(postID: String, numberOfImage: Int, completion: @escaping (Bool) -> Void) {
        for num in 1...numberOfImage {
            let fileName = postID + String(num - 1) + ".jpg"
            PostManager.shared.postImageRef.child(postID).child(fileName).delete { error in
                //storage 위치 변경
            //PostManager.shared.postImageRef.child(uid).child(postID).child(fileName).delete { error in
                if let error = error {
                    completion(false)
                    print("post만 삭제되고 image는 삭제안됨 또는 존재하지 않는 image\(error)")
                } else {
                    completion(true)
                    print("image삭제됨")
                }
            }
        }
    }
    
    func updateMyPost(postID: String, tastingNote: WineTastingNotes, completion: @escaping (Bool) -> Void) {
        guard let authorUID = Auth.auth().currentUser?.uid else { return }
        let updatedDate: Double = (Date().timeIntervalSince1970).rounded()
        let tastingDate: Double = (tastingNote.tastingDate.timeIntervalSince1970).rounded()
        let tastingNote = ["tastingDate":tastingDate, "place":tastingNote.place as Any, "wineName":tastingNote.wineName as Any, "category":tastingNote.category as Any, "varieties":tastingNote.varieties as Any, "producingCountry":tastingNote.producingCountry as Any, "producer":tastingNote.producer as Any, "vintage":tastingNote.vintage as Any, "price":tastingNote.price as Any, "alcoholContent":tastingNote.alcoholContent as Any, "aromasAndFlavors":tastingNote.aromasAndFlavors as Any, "sweet":tastingNote.sweet as Any, "acidity":tastingNote.acidity as Any, "tannin":tastingNote.tannin as Any, "body":tastingNote.body as Any, "memo":tastingNote.memo as Any, "rating":tastingNote.rating as Any] as [String : Any]
        
        let value = ["updatedDate":updatedDate, "tastingNote":tastingNote] as [String:Any]
        
        PostManager.shared.postRef.child(authorUID).child(postID).updateChildValues(value)
        completion(true)
    }
/*
    func uploadDatafromCoreDataToFirebase(completion: @escaping (Bool) -> Void) {
        DataManager.shared.fetchWineTastingNote { notes in
            if notes.count == 0 {
                completion(true)
            } else {
                for i in 1...notes.count {
                    let num = i - 1
                    let note = notes[num]
                    var price: Int32? = nil
                    if note.price == 0 {
                        price = nil
                    } else {
                        price = note.price
                    }
                    var alcoholContent: Float? = nil
                    if note.alcoholContent == 0 {
                        alcoholContent = nil
                    } else {
                        alcoholContent = note.alcoholContent
                    }
                    let tastingNote = WineTastingNotes(tastingDate: note.tastingDate, place: note.place, wineName: note.wineName, category: note.category, varieties: note.varieties, producingCountry: note.producingCountry, producer: note.producer, vintage: note.vintage, price: price, alcoholContent: alcoholContent, sweet: note.sweet, acidity: note.acidity, tannin: note.tannin, body: note.body, aromasAndFlavors: note.aromasAndFlavors, memo: note.memo, rating: note.rating)
                    PostManager.shared.uploadPost(posting: note.postingDate, updated: note.updatedDate, tastingNote: tastingNote, images: note.image) { result in
//                        if result == true && i == notes.count {
//                            completion(true)
//                        }
                        
//                        switch result {
//                        case .success(_):
//                            print("")
//                        case .failure(let error):
//                            print(error)
//                        }
                    }
                }
            }
        }
    }
*/
/*
    func uploadDatafromFirebaseToCoreData(completion: @escaping (Bool) -> Void) {
        PostManager.shared.fetchMyPosts { posts in
            guard let posts = posts else {
                completion(true)
                return
            }
            for i in 1...posts.count {
                let num = i - 1
                let post = posts[num]
                let tastingNote = WineTastingNotes(tastingDate: post.tastingNote.tastingDate, place: post.tastingNote.place, wineName: post.tastingNote.wineName, category: post.tastingNote.category, varieties: post.tastingNote.varieties, producingCountry: post.tastingNote.producingCountry, producer: post.tastingNote.producer, vintage: post.tastingNote.vintage, price: post.tastingNote.price, alcoholContent: post.tastingNote.alcoholContent, sweet: post.tastingNote.sweet, acidity: post.tastingNote.acidity, tannin: post.tastingNote.tannin, body: post.tastingNote.body, aromasAndFlavors: post.tastingNote.aromasAndFlavors, memo: post.tastingNote.memo, rating: post.tastingNote.rating)
                var images = [UIImage]()
                for urlString in post.postImageURL {
                    let url = URL(string: urlString)!
                    KingfisherManager.shared.retrieveImage(with: url) { result in
                        switch result {
                        case .success(let value):
                            images.append(value.image)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                DataManager.shared.addWineTastingNote(posting: post.postingDate, updated: post.updatedDate, tastingNote: tastingNote, images: images) { result in
                    if result == true {
                        completion(true)
                    }
                }
            }
        }
    }
*/
}

enum PostError: Error {
    case failedToUploadPost
    
    var message: String {
        switch self {
        case .failedToUploadPost:
            return "잠시 후 다시 시도해 주세요."
        }
    }
}
