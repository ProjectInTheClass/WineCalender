//
//  PostManager.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/24.
//

import Foundation
import Firebase

class PostManager {
    
    static let shared = PostManager()
    
    let postRef = Database.database(url: "https://wine-calendar-3e6a1-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("Post")
    //let postRef = Database.database().reference().child("Post")
    let postImageRef = Storage.storage().reference().child("PostImage")
    
    func uploadPost(wineTastingNotes: WineTastingNotes) {
        if let uid = Auth.auth().currentUser?.uid {
            let postingDate: Double = (Date().timeIntervalSince1970).rounded()
            
            let tastingDate: Double = (wineTastingNotes.date.timeIntervalSince1970).rounded()
            let tastingNote = ["tastingDate":tastingDate, "wineName":wineTastingNotes.name, "rating":wineTastingNotes.rating as Any, "price":wineTastingNotes.price as Any, "alcoholContent":wineTastingNotes.alcoholContent as Any] as [String : Any]
            
            let value = ["authorUID":uid, "postingDate":postingDate, "tastingNote":tastingNote] as [String:Any]
            
            PostManager.shared.postRef.childByAutoId().setValue(value)
            
        }
    }
    
    func fetchMyPosts() {
        if let uid = Auth.auth().currentUser?.uid {
            PostManager.shared.postRef.queryOrdered(byChild: "authorUID").queryEqual(toValue: uid).observeSingleEvent(of: .value) { snapshot in
                print(snapshot)
            }
        }
    }
    
}
