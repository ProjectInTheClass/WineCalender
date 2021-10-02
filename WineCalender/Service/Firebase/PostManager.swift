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
    //let postRef = Database.database().reference().child("Post")
    let postImageRef = Storage.storage().reference().child("PostImage")
    
    func uploadPost(tastingNote: WineTastingNotes, images: [UIImage], completion: @escaping (Bool) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {

            guard let postID = PostManager.shared.postRef.childByAutoId().key else { return }
            
            for (index, image) in images.enumerated() {
                let imageName = postID + String(index) + ".jpg"
                if let postImageData = image.jpegData(compressionQuality: 0.2) {
                    PostManager.shared.postImageRef.child(postID).child(imageName).putData(postImageData, metadata: nil) { metadata, error in
                        if let error = error {
                            print("이미지 등록 에러 : \(error.localizedDescription)")
                        } else {
                            PostManager.shared.postImageRef.child(postID).child(imageName).downloadURL { url, error in
                                if let error = error {
                                    print("데이터베이스에 이미지추가 실패 : \(error.localizedDescription)")
                                }
                                guard let urlString: String = url?.absoluteString else { return }
                                let childUpdates = ["/\(postID)/postImageURL/\(index)":urlString]
                                PostManager.shared.postRef.updateChildValues(childUpdates)
                                print("이미지 등록함")
                                completion(true)
                            }
                        }
                    }
                }
            }
            
            let postingDate: Double = (Date().timeIntervalSince1970).rounded()
            
            let tastingDate: Double = (tastingNote.tastingDate.timeIntervalSince1970).rounded()
            let tastingNote = ["tastingDate":tastingDate, "place":tastingNote.place as Any, "wineName":tastingNote.wineName as Any, "category":tastingNote.category as Any, "varieties":tastingNote.varieties as Any, "producingCountry":tastingNote.producingCountry as Any, "producer":tastingNote.producer as Any, "vintage":tastingNote.vintage as Any, "price":tastingNote.price as Any, "alcoholContent":tastingNote.alcoholContent as Any, "sweet":tastingNote.sweet as Any, "acidity":tastingNote.acidity as Any, "tannin":tastingNote.tannin as Any, "body":tastingNote.body as Any, "aromasAndFlavors":tastingNote.aromasAndFlavors as Any, "memo":tastingNote.memo as Any, "rating":tastingNote.rating as Any] as [String : Any]
            
            let value = ["postID":postID, "authorUID":uid, "postingDate":postingDate, "tastingNote":tastingNote] as [String:Any]
            
            PostManager.shared.postRef.child(postID).setValue(value)
        }
    }
    
    func fetchMyPosts(completion: @escaping ([Post]?) -> Void){
        if let uid = Auth.auth().currentUser?.uid {
            PostManager.shared.postRef.queryOrdered(byChild: "authorUID").queryEqual(toValue: uid).observeSingleEvent(of: .value) { snapshot in
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
    
}
