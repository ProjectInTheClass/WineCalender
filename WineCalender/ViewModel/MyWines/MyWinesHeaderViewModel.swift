//
//  MyWinesHeaderViewModel.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/09/06.
//

import Foundation
import Kingfisher
import FirebaseAuth

class MyWinesHeaderViewModel {
    
    var onUpdated: () -> Void = {}
    
    var email: String? = nil
    var profileImage: UIImage = UIImage() {
        didSet {
            onUpdated()
        }
    }
    var nickname: String = ""
    var introduction: String? = nil
    
    func fetchUserProfile() {
        if Auth.auth().currentUser != nil {
            AuthenticationManager.shared.fetchUserProfile { user in
                if let url = user.profileImageURL {
                    self.downloadImage(with: url) { image in
                        guard let image = image else { return }
                        self.profileImage = image
                    }
                } else {
                    self.profileImage = UIImage(systemName: "person.circle.fill")!.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
                }
                self.email = user.email
                self.nickname = user.nickname
                self.introduction = user.introduction
            }            
        } else {
            self.email = nil
            self.profileImage = UIImage(systemName: "person.circle.fill")!
            self.nickname = "비회원"
            self.introduction = nil
        }
    }
    
    private func downloadImage(with url : URL, imageCompletionHandler: @escaping (UIImage?) -> Void){
        let resource = ImageResource(downloadURL: url)
        
        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
            switch result {
            case .success(let value):
                imageCompletionHandler(value.image)
            case .failure:
                imageCompletionHandler(nil)
            }
        }
    }
}
//struct MyWinesHeaderViewModel {
//    let email: String
//    let profileImageURL: URL?
//    let nickname: String
//    let introduction: String?
//
//    init (user: User) {
//        self.email = user.email
//        self.profileImageURL = user.profileImageURL
//        self.nickname = user.nickname
//        self.introduction = user.introduction
//    }
//}
