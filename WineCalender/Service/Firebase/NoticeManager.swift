//
//  NoticeManager.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/12/29.
//

import Foundation
import Firebase
import FirebaseDatabase

class NoticeManager {
    
    static let shared = NoticeManager()
    private init() { }
    
    let noticeRef = Database.database().reference().child("Notice")
    
    func fetchNotice(completion: @escaping ([Notice]) -> Void) {
        NoticeManager.shared.noticeRef.observeSingleEvent(of: .value) { snapshot in
            guard let snapshotArray = snapshot.value as? NSArray else { return }
            guard let data = try? JSONSerialization.data(withJSONObject: snapshotArray, options: []) else { return }
            let decoder = JSONDecoder()
            guard let notice = try? decoder.decode([Notice].self, from: data) else { return }
            completion(notice)
        }
    }
}
