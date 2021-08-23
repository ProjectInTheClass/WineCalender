//
//  AuthenticationManager.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/20.
//

import Foundation
import Firebase

class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    
    let userRef = Database.database(url: "https://wine-calendar-3e6a1-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("User")
    let userProfileImageRef = Storage.storage().reference().child("ProfileImage")
    
    func signUp(email: String, password: String, nickname: String, profileImage: UIImage, warningLabel: UILabel, completion: @escaping(Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                if error.localizedDescription.contains("The email address is badly formatted.") {
                    warningLabel.text = "이메일 형식을 확인해 주세요."
                } else if error.localizedDescription.contains("The email address is already in use by another account.") {
                    warningLabel.text = "이미 사용 중인 이메일 주소입니다."
                } else {
                    warningLabel.text = "입력한 내용을 다시 확인해 주세요."
                }
                return
            } else {
                self.saveUserNicknameAndProfileImage(nickname: nickname, profileImage: profileImage) { result in
                    if result == true {
                        NotificationCenter.default.post(name: SignInViewController.userStateChangeNoti, object: nil)
                        return completion(true)
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String, warningLabel: UILabel, completion: @escaping(Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { uthResult, error in
            if let error = error {
                print("이메일 로그인 에러 : \(error.localizedDescription)" )
                warningLabel.text = "이메일 주소와 비밀번호가 맞는지 다시 확인해 주세요."
                return
            } else {
                completion(true)
                NotificationCenter.default.post(name: SignInViewController.userStateChangeNoti, object: nil)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            NotificationCenter.default.post(name: SignInViewController.userStateChangeNoti, object: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func saveUserNicknameAndProfileImage(nickname: String, profileImage: UIImage, completion: @escaping(Bool) -> Void) {
        let uid = Auth.auth().currentUser!.uid
        if profileImage.isSymbolImage == true {
        } else {
            let profileImageName = uid + ".jpg"
            if let profileImageData = profileImage.jpegData(compressionQuality: 0.1) {
                userProfileImageRef.child(profileImageName).putData(profileImageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("프로필 이미지 등록 에러 : \(error.localizedDescription)")
                    } else {
                        print("프로필 이미지 등록함")
                    }
                }
            }
        }
        userRef.child(uid).setValue(["nickname": nickname])
        completion(true)
    }
    
    func fetchUserNicknameAndProfileImage(completion: @escaping(_ nickname: String, _ profileImageURL: URL?) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
            userRef.child(uid).child("nickname").observeSingleEvent(of: .value) { snapshot in
                let nickname = snapshot.value as? String ?? "닉네임없음"
                let profileImageName = uid + ".jpg"
                self.userProfileImageRef.child(profileImageName).downloadURL { url, error in
                    if let error = error {
                        let profileImageURL: URL? = nil
                        print("이미지 다운로드 에러 또는 이미지없음: \(error.localizedDescription)")
                        completion(nickname,profileImageURL)
                    } else {
                        self.userProfileImageRef.child(profileImageName).downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                return
                            }
                            let profileImageURL = downloadURL
                            completion(nickname,profileImageURL)
                        }
                    }
                }
            }
        }
    }
}
