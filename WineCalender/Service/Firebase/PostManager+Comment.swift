//
//  PostManager+Comment.swift
//  WineCalender
//
//  Created by Minju Lee on 2022/01/14.
//

import Firebase
import FirebaseStorage
import FirebaseDatabase
import Foundation

enum CommentError: Error {
    case failedToAuthenticateUser
    case failedToUploadComment
    
    var localizedDescription: String {
        switch self {
        case .failedToAuthenticateUser:
            return "Failed to authenticate user"
        case .failedToUploadComment:
            return "Failed to upload Comment"
        }
    }
}

extension PostManager {
    var commentRef: DatabaseReference {
        get {
            return Database.database().reference().child("Comment")
        }
    }
    
    func uploadComment(postUID: String, authorUID: String, text: String, completion: @escaping (Result<Void, Error>) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(CommentError.failedToAuthenticateUser))
            return
        }
        
        let commentRef = PostManager.shared.commentRef.child(postUID).childByAutoId()
        let date: Double = (Date().timeIntervalSince1970).rounded()
        let commentID: String = commentRef.key ?? ""
        let value = ["uid":uid, "date":date, "text":text, "commentID":commentID] as [String:Any]
        commentRef.setValue(value) { error, ref in
            if let _ = error {
                completion(.failure(CommentError.failedToUploadComment))
            } else {
                let commentRef = Database.database().reference().child("Post").child(authorUID).child(postUID).child("commentCount")
                commentRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                    let currentCount = mutableData.value as? Int ?? 0
                    
                    mutableData.value = currentCount + 1
                    
                    return TransactionResult.success(withValue: mutableData)
                }, andCompletionBlock: { (error, _, _) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                        completion(.failure(CommentError.failedToUploadComment))
                    } else {
                        completion(.success(()))
                    }
                })
            }
        }
    }
    
    func fetchFirstComment(postID: String, completion: @escaping (Comment) -> Void) {
        commentRef.child(postID).queryLimited(toFirst: 1).observeSingleEvent(of: .value) { snapshot in
            guard let snapshotDict = snapshot.value as? [String: [String: Any]] else { return }
            let commentDict: [String: Any] = Array(snapshotDict.values)[0]
            guard let uid = commentDict["uid"] as? String else { return }
            
            AuthenticationManager.shared.fetchUserProfile(uid: uid) { url, nickname in
                let comment = Comment(dictionary: commentDict, url: url, nickname: nickname)
                completion(comment)
            }
        }
    }
    
    func fetchComments(postID: String, completion: @escaping ([Comment]) -> Void) {
        var comments = [Comment]()
        commentRef.child(postID).observeSingleEvent(of: .value) { snapshot in
            guard let snapshotDict = snapshot.value as? [String: [String: Any]] else {
                completion(comments)
                return
            }
            let commentArray: [[String: Any]] = Array(snapshotDict.values)

            commentArray.forEach {
                guard let uid: String = $0["uid"] as? String else { return }
                let commentDict: [String: Any] = $0
                AuthenticationManager.shared.fetchUserProfile(uid: uid) { url, nickname in
                    let comment = Comment(dictionary: commentDict, url: url, nickname: nickname)
                    comments.append(comment)
                    if comments.count == commentArray.count {
                        comments.sort { $0.date < $1.date }
                        completion(comments)
                    }
                }
            }
        }
    }
}
