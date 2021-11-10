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
    case failedToLike
    case failedToUnlike
    case failedToAuthenticateUser
    
    var localizedDescription: String {
        switch self {
        case .failedToLike:
            return "Failed to like post"
        case .failedToUnlike:
            return "Failed to unlike post"
        case .failedToAuthenticateUser:
            return "Failed to authenticate user"
        }
    }
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
    
    func like(postUID: String, authorUID: String, completion: @escaping (Result<Void, Error>) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(LikeError.failedToAuthenticateUser))
            return
        }

        let likeRef = PostManager.shared.likeRef.child(postUID).child(uid)
        likeRef.setValue(Date().timeIntervalSince1970.rounded()) { error, ref in
            if let _ = error {
                completion(.failure(LikeError.failedToLike))
            } else {
                let likeCountRef = Database.database().reference().child("Post").child(authorUID).child(postUID).child("likeCount")
                        likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                            let currentCount = mutableData.value as? Int ?? 0

                            mutableData.value = currentCount + 1

                            return TransactionResult.success(withValue: mutableData)
                        }, andCompletionBlock: { (error, _, _) in
                            if let error = error {
                                assertionFailure(error.localizedDescription)
                                completion(.failure(LikeError.failedToLike))
                            } else {
                                completion(.success(()))
                            }
                        })
            }
        }
    }
    
    func unlike(postUID: String, authorUID: String, completion: @escaping (Result<Void, Error>) ->()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(LikeError.failedToAuthenticateUser))
            return
        }
        
        let likeRef = PostManager.shared.likeRef.child(postUID).child(uid)
        likeRef.removeValue { error, _ in
            if let _ = error {
                completion(.failure(LikeError.failedToUnlike))
            } else {
                let likeCountRef = Database.database().reference().child("Post").child(authorUID).child(postUID).child("likeCount")
                        likeCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                            let currentCount = mutableData.value as? Int ?? 0

                            mutableData.value = currentCount - 1

                            return TransactionResult.success(withValue: mutableData)
                        }, andCompletionBlock: { (error, _, _) in
                            if let error = error {
                                assertionFailure(error.localizedDescription)
                                completion(.failure(LikeError.failedToLike))
                            } else {
                                completion(.success(()))
                            }
                        })
            }
        }
    }
    
    func fetchLikes(postUID: String, completion: @escaping (Result<[String], Error>) -> ()) {
        guard let _ = Auth.auth().currentUser else {
            completion(.failure(LikeError.failedToAuthenticateUser))
            return
        }
        
        PostManager.shared.likeRef.child(postUID).observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String : Any] else {
                completion(.success([]))
                return
            }
            let uids = dict.keys.compactMap { String($0) }
            completion(.success(uids))
        }
    }
    
    func likesPost(postUID: String, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let userUID = Auth.auth().currentUser?.uid else {
            completion(.failure(LikeError.failedToAuthenticateUser))
            return
        }

        PostManager.shared.likeRef.child(postUID).observe(.value) { snapshot in
            if let dict = snapshot.value as? NSDictionary {
                if let _ = dict[userUID] {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            } else {
                completion(.success(false))
            }
        }
    }
}
