//
//  PostManager+Like.swift
//  WineCalender
//
//  Created by Susan Kim on 2021/10/29.
//

import Firebase
import FirebaseStorage
import FirebaseDatabase

/**
 Like 기능과 관련한 Error
 */
enum LikeError: Error {
    case postUnavailable
    case valueUnavailable
}

/**
 like 기능 관련만 모아둠 ~~
 */
extension PostManager {
    var baseUrl: String {
        get {
            return "https://wine-calendar-3e6a1-default-rtdb.asia-southeast1.firebasedatabase.app/"
        }
    }
    
    var likeRef: DatabaseReference {
        get {
            return Database.database(url: baseUrl).reference().child("Like")

        }
    }
    
    func likePost() {
        print("like post")
    }
    
    func unlikePost() {
        print("unlike post")
    }
    
    func fetchLikes(postUID: String, completion: @escaping ((Result<[Like], Error>) -> ())) {
        var result = [Like]()

        // 로그인 상태 확인
        guard let _ = Auth.auth().currentUser else {
            debugPrint("User not logged in")
            return
        }
        
        PostManager.shared.likeRef.child(postUID).observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.reversed() {
                let dataSnapshot = child as! DataSnapshot
                guard let dictionary = dataSnapshot.value as? [String:Any] else { return }
                
                guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                guard let like = try? decoder.decode(Like.self, from: data) else { return }
                result.append(like)
            }
            
            completion(.success(result))
        }
    }
}
