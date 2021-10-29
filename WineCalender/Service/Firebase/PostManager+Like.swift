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
    
    func fetchLikes(postUID: String, completion: @escaping ((Result<PostLike, LikeError>) -> ())) {
        print("fetch likes")
        
        // 로그인 상태 확인
        guard let _ = Auth.auth().currentUser else {
            debugPrint("User not logged in")
            return
        }
    
        PostManager.shared.likeRef.queryEqual(toValue: postUID).getData { error, snapshot in
            guard let _ = error else {
                completion(.failure(.postUnavailable))
                return
            }
            
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(.valueUnavailable))
                return
            }
            
            let data = Array(value)
            guard let data = try? JSONSerialization.data(withJSONObject: data, options: []) else { return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            guard let postLike = try? decoder.decode(PostLike.self, from: data) else { return }
            
            completion(.success(postLike))
            
        }
    }
}
