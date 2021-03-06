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
    private init() { }
    
    let postRef = Database.database().reference().child("Post")
    let recentPostRef = Database.database().reference().child("RecentPost")
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
                        //error2) image??? ????????????
                        //image ??????
                        print("image??? ???????????????, DB??? ??????????????? : \(error.localizedDescription)")
                        self?.removeMyPostImages(postID: postID, numberOfImages: images.count) { result in
                            completion(.failure(PostError.failedToUploadPost))
                        }
                    } else {
                        // add recent post ID
                        let recentPostValue = ["postID":postID, "authorID":uid, "postedDate":postingDate as Any] as [String:Any]
                        PostManager.shared.recentPostRef.child(postID).updateChildValues(recentPostValue) { error, ref in
                            if let error = error {
                                //error3) image, postRef??? ????????????
                                //postRef, image ??????
                                print("image, postRef??? ???????????????, recentPostRef??? ??????????????? : \(error.localizedDescription)")
                                self?.removeMyPost(postID: postID, authorUID: uid, numberOfImages: images.count) { result in
                                    completion(.failure(PostError.failedToUploadPost))
                                }
                            } else {
                                completion(.success(()))
                            }
                        }
                    }
                }
            } else {
                //error1) image ????????? ??? ??????
                //image ??????
                self?.removeMyPostImages(postID: postID, numberOfImages: images.count) { result in
                    completion(.failure(PostError.failedToUploadPost))
                }
            }
        }
        
        func uploadImage(imageUploadCompletion: @escaping (Bool) -> Void) {
            var uploadCount = 0
            for (index, image) in images.enumerated() {
                let imageName = postID + String(index) + ".jpg"
                if let postImageData = image.jpegData(compressionQuality: 0.2) {
                    PostManager.shared.postImageRef.child(uid).child(postID).child(imageName).putData(postImageData, metadata: nil) { metadata, error in
                        if let error = error {
                            imageUploadCompletion(false)
                            print("image ????????? ?????? : \(error.localizedDescription)")
                        } else {
                            PostManager.shared.postImageRef.child(uid).child(postID).child(imageName).downloadURL { url, error in
                                if let error = error {
                                    imageUploadCompletion(false)
                                    print("downloadURL ?????? : \(error.localizedDescription)")
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
    
    func numberOfMyPosts(uid: String, completion: @escaping (Int) -> Void) {
        PostManager.shared.postRef.child(uid).observeSingleEvent(of: .value) { snapshot in
            completion(Int(snapshot.childrenCount))
        }
    }
    
    //For My Wines
    func fetchMyPosts(uid: String, lastFetchedValue: String?, completion: @escaping ([Post]?) -> Void){
        
        let queryLimited: UInt = fetchMyPostsqueryLimited
        var queryRef: DatabaseQuery
        if lastFetchedValue == nil {
            queryRef = PostManager.shared.postRef.child(uid).queryOrdered(byChild: "postID").queryLimited(toLast: queryLimited)
        } else {
            queryRef = PostManager.shared.postRef.child(uid).queryOrdered(byChild: "postID").queryEnding(beforeValue: lastFetchedValue).queryLimited(toLast: queryLimited)
        }

//        queryRef.observe(.value) { snapshot in
        queryRef.observeSingleEvent(of: .value) { snapshot in
            guard let snapshotDict = snapshot.value as? [String:Any] else {
                completion(nil)
                return
            }
            let datas = Array(snapshotDict.values)
            guard let data = try? JSONSerialization.data(withJSONObject: datas, options: []) else { return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            guard let posts = try? decoder.decode([Post].self, from: data) else { return }
            let newPosts = posts.sorted{ $0.postingDate > $1.postingDate }
            print("newPosts : \(newPosts.count)???")
            
            completion(newPosts)
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
    
    //for delete account
    func fetchMyPostIDs(completion: @escaping (Bool, [String]?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false, nil)
            return
        }
        PostManager.shared.postRef.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let snapshotDict = snapshot.value as? NSDictionary else {
                completion(true, nil)
                return
            }
            let postIDs = snapshotDict.allKeys as? [String]
            completion(true, postIDs)
        }
    }
    
    func updateMyPost(postID: String, tastingNote: WineTastingNotes, completion: @escaping (Result<Void, PostError>) -> Void) {
        guard let authorUID = Auth.auth().currentUser?.uid else { return }
        let updatedDate: Double = (Date().timeIntervalSince1970).rounded()
        let tastingDate: Double = (tastingNote.tastingDate.timeIntervalSince1970).rounded()
        let tastingNote = ["tastingDate":tastingDate, "place":tastingNote.place as Any, "wineName":tastingNote.wineName as Any, "category":tastingNote.category as Any, "varieties":tastingNote.varieties as Any, "producingCountry":tastingNote.producingCountry as Any, "producer":tastingNote.producer as Any, "vintage":tastingNote.vintage as Any, "price":tastingNote.price as Any, "alcoholContent":tastingNote.alcoholContent as Any, "aromasAndFlavors":tastingNote.aromasAndFlavors as Any, "sweet":tastingNote.sweet as Any, "acidity":tastingNote.acidity as Any, "tannin":tastingNote.tannin as Any, "body":tastingNote.body as Any, "memo":tastingNote.memo as Any, "rating":tastingNote.rating as Any] as [String : Any]
        
        let value = ["updatedDate":updatedDate, "tastingNote":tastingNote] as [String:Any]
        
        PostManager.shared.postRef.child(authorUID).child(postID).updateChildValues(value) { error, ref in
            if let error = error {
                //error)
                print("???????????? ?????? ?????? ?????? : \(error.localizedDescription)")
                completion(.failure(PostError.failedToUpdatePost))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func removeMyPost(postID: String, authorUID: String, numberOfImages: Int, completion: @escaping (Result<Void,PostError>) -> Void) {
        guard authorUID == Auth.auth().currentUser?.uid else { return }
        PostManager.shared.recentPostRef.child(postID).removeValue { error, ref in
            if let error = error {
                //error1)
                print("recentPostRef ?????? ?????? : \(error.localizedDescription)")
                completion(.failure(PostError.failedToRemovePost))
            } else {
                PostManager.shared.postRef.child(authorUID).child(postID).removeValue { [weak self] error, ref in
                    if let error = error {
                        //error2)
                        print("postRef ?????? ?????? : \(error.localizedDescription)")
                        completion(.failure(PostError.failedToRemovePost))
                    } else {
                        self?.removeMyPostImages(postID: postID, numberOfImages: numberOfImages) { result in
                            if result == true {
                                completion(.success(()))
                            } else {
                                //error3)
                                completion(.failure(PostError.failedToRemovePost))
                            }
                        }
                    }
                }
                PostManager.shared.likeRef.child(postID).removeValue()
                PostManager.shared.commentRef.child(postID).removeValue()
            }
        }
    }
    
    func removeMyPostImages(postID: String, numberOfImages: Int, completion: @escaping (Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        var removeCount = 0
        for num in 1...numberOfImages {
            let imageName = postID + String(num - 1) + ".jpg"
            PostManager.shared.postImageRef.child(uid).child(postID).child(imageName).delete { error in
                if let error = error, error.localizedDescription.contains("does not exist.") {
                    removeCount += 1
                } else if let error = error {
                    print("image ?????? ?????? : \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("image ?????????")
                    removeCount += 1
                    if removeCount == numberOfImages {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func removeMyPosts(postIDs: [String], authorUID: String, numberOfImages: Int, completion: @escaping (Bool) -> Void) {
        var removeCount = 0
        postIDs.forEach {
            PostManager.shared.removeMyPost(postID: $0, authorUID: authorUID, numberOfImages: 3) { result in
                switch result {
                case .failure(_):
                    completion(false)
                    break
                case .success(()):
                    removeCount += 1
                    if removeCount == postIDs.count {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func removeMyLikesAndComments(authorUID: String, completion: @escaping (Bool) -> Void) {
//        PostManager.shared.likeRef.queryOrdered(byChild: authorUID).queryEqual(toValue: "??????").observeSingleEvent(of: .value) {
        PostManager.shared.likeRef.queryOrdered(byChild: authorUID).queryEqual(toValue: 1640532959).observeSingleEvent(of: .value) {
              snapshot in

            guard let snapshotDict = snapshot.value as? [String:Any] else {
                //????????? ????????? ??????
                completion(true)
                return
            }
            
            let postUIDs = snapshotDict.keys
            postUIDs.forEach {
                PostManager.shared.unlike(postUID: $0, authorUID: authorUID) { result in
                    switch result {
                    case .failure(_):
                        completion(false)
                    case .success(()):
                        print("??????")
                        //comment??????
                    }
                }
            }
        }
    }
    
    func uploadDatafromCoreDataToFirebase(note: WineTastingNote ,completion: @escaping (Result<Void,PostError>) -> Void) {
        let postingDate = note.postingDate
        let updatedDate = note.updatedDate
        let tastingNote = WineTastingNotes(tastingDate: note.tastingDate, place: note.place, wineName: note.wineName, category: note.category, varieties: note.varieties, producingCountry: note.producingCountry, producer: note.producer, vintage: note.vintage, price: note.price, alcoholContent: note.alcoholContent, sweet: note.sweet, acidity: note.acidity, tannin: note.tannin, body: note.body, aromasAndFlavors: note.aromasAndFlavors, memo: note.memo, rating: note.rating)
        let images = note.image
        
        PostManager.shared.uploadPost(posting: postingDate, updated: updatedDate, tastingNote: tastingNote, images: images) { result in
            switch result {
            case .success(_):
                DataManager.shared.removeWineTastingNote(wineTastingNote: note) { result in
                    if result == true {
                        completion(.success(()))
                    }
                }
            case .failure(_):
                completion(.failure(PostError.failedToUploadPost))
            }
        }
    }
}

enum PostError: Error {
    case failedToUploadPost
    case failedToRemovePost
    case failedToUpdatePost
    
    var title: String {
        switch self {
        default: return "?????? ??? ?????? ????????? ?????????."
        }
    }
    
    var message: String {
        switch self {
        case .failedToUploadPost:
            return "???????????? ??????????????????. \n??? ????????? ???????????? [??????]-[?????????]??? ????????? ?????????."
        case .failedToRemovePost:
            return "????????? ??????????????????. \n??? ????????? ???????????? [??????]-[?????????]??? ????????? ?????????."
        case .failedToUpdatePost:
            return "????????? ??????????????????. \n??? ????????? ???????????? [??????]-[?????????]??? ????????? ?????????."
        }
    }
}
