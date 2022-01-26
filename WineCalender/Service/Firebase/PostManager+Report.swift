//
//  PostManager+Report.swift
//  WineCalender
//
//  Created by Minju Lee on 2022/01/26.
//

import Firebase
import FirebaseDatabase

enum ReportError: Error {
    case failedToReportPost
    
    var localizedDescription: String {
        switch self {
        case .failedToReportPost:
            return "Failed to report post"
        }
    }
}

extension PostManager {
    var reportRef: DatabaseReference {
        get {
            return Database.database().reference().child("Report")
        }
    }
    
    func reportPost(postID: String, authorUID: String, currentUserUID: String, completion: @escaping (Result<Void,ReportError>) -> Void) {
        let date = (Date().timeIntervalSince1970).rounded()
        let values = ["date":date,"postID":postID, "reportedUser":authorUID, "reporter":currentUserUID] as [String : Any]
        reportRef.childByAutoId().updateChildValues(values) { error, _ in
            if error == nil {
                let postValue = ["isReported":true]
                PostManager.shared.postRef.child(authorUID).child(postID).updateChildValues(postValue) { error, _ in
                    if error == nil {
                        completion(.success(()))
                    } else {
                        completion(.failure(.failedToReportPost))
                    }
                }
            } else {
                completion(.failure(.failedToReportPost))
            }
        }
    }
    
    func checkIfReportedPost(postID: String, authorUID: String, completion: @escaping (Bool) -> Void) {
        postRef.child(authorUID).child(postID).child("isReported").observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(false)
                return
            }
            guard let value = snapshot.value as? Bool, value != false else {
                completion(false)
                return
            }
            completion(true)
        }
    }
}
