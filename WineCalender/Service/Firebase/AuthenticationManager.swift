//
//  AuthenticationManager.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/20.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase

class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    
    let userRef = Database.database(url: "https://wine-calendar-3e6a1-default-rtdb.asia-southeast1.firebasedatabase.app/").reference().child("User")
    let userProfileImageRef = Storage.storage().reference().child("ProfileImage")
    
    func signUp(email: String, password: String, nickname: String, profileImage: UIImage, warningLabel: UILabel, completion: @escaping(Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("회원가입 오류 - \(error.localizedDescription)")
                if error.localizedDescription.contains("The email address is badly formatted.") {
                    warningLabel.text = "이메일 형식을 확인해 주세요."
                } else if error.localizedDescription.contains("The email address is already in use by another account.") {
                    warningLabel.text = "이미 사용 중인 이메일 주소입니다."
                } else {
                    warningLabel.text = "입력한 내용을 다시 확인해 주세요."
                }
                return
            } else {
                self.saveUserProfile(profileImage: profileImage, nickname: nickname, introduction: "" ) { result in
                    if result == true {
                        return completion(true)
                    } else {
                        print("회원가입 - 프로필 저장 실패")
                        return completion(false)
                    }
                }
            }
        }
    }
    
    func signIn(email: String, password: String, warningLabel: UILabel, completion: @escaping(Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { uthResult, error in
            if let error = error {
                print("이메일 로그인 에러 : \(error.localizedDescription)" )
                warningLabel.text = "입력하신 정보가 맞는지 다시 확인해 주세요."
                return
            } else {
                completion(true)
            }
        }
    }
    
    func signOut(completion: @escaping(Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            completion(false)
        }
    }
    
    func saveUserProfile(profileImage: UIImage, nickname: String, introduction: String, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if !profileImage.isSymbolImage {
            let profileImageName = uid + ".jpg"
            if let profileImageData = profileImage.jpegData(compressionQuality: 0.1) {
                userProfileImageRef.child(profileImageName).putData(profileImageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("프로필 이미지 등록 에러 : \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("프로필 이미지 등록함")
                        self.userProfileImageRef.child(profileImageName).downloadURL { url, error in
                            guard let urlString: String = url?.absoluteString else { return }
                            if introduction != "" {
                                AuthenticationManager.shared.userRef.child(uid).setValue(["profileImageURL": urlString, "nickname": nickname, "introduction": introduction])
                                completion(true)
                            } else {
                                AuthenticationManager.shared.userRef.child(uid).setValue(["profileImageURL": urlString, "nickname": nickname])
                                completion(true)
                            }
                        }
                    }
                }
            }
        } else {
            if introduction != "" {
                AuthenticationManager.shared.userRef.child(uid).setValue(["nickname": nickname, "introduction": introduction])
                completion(true)
            } else {
                AuthenticationManager.shared.userRef.child(uid).setValue(["nickname": nickname])
                completion(true)
            }
        }
    }
    
    //My profile
    func fetchMyProfile(completion: @escaping (User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else { return }
        
        userRef.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let values = snapshot.value as? [String : String] else { return }
            
            var profileImageURL: URL? = nil
            if let url = values["profileImageURL"] {
                profileImageURL = URL(string: url)
            }
            
            let nickname = values["nickname"]!
            
            var introduction: String? = nil
            if let introductionValue = values["introduction"] {
                introduction = introductionValue
            }
            
            let user = User(uid: uid, email: email, profileImageURL: profileImageURL, nickname: nickname, introduction: introduction)
            
            completion(user)
        }
    }
    
    //Post Author Profile
    func fetchUserProfile(AuthorUID: String, completion: @escaping (URL?, String) -> Void) {
        userRef.child(AuthorUID).observeSingleEvent(of: .value) { snapshot in
            guard let values = snapshot.value as? [String : String] else { return }
            
            var profileImageURL: URL? = nil
            if let url = values["profileImageURL"] {
                profileImageURL = URL(string: url)
            }
            
            let nickname = values["nickname"]!
            
            completion(profileImageURL, nickname)
        }
    }
    
    func resetPassword(email: String, completion: @escaping(Bool) -> Void) {
        Auth.auth().languageCode = "ko_kr"
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("비밀번호 찾기 에러: \(error.localizedDescription)")
                completion(false)
            } else {
                print("이메일 보냄")
                completion(true)
            }
        }
    }
    
    func updatePassword(presentPassword: String, newPassword: String, warningLabel: UILabel, completion: @escaping(Bool) -> Void) {
        if let email = Auth.auth().currentUser?.email {
            signIn(email: email, password: presentPassword, warningLabel: warningLabel) { result in
                if result == true {
                    Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { error in
                        if error != nil {
                            warningLabel.text = "비밀번호 변경 오류"
                            print("비밀번호 변경 오류")
                            completion(false)
                        } else {
                            print("비밀번호 변경됨")
                            completion(true)
                        }
                    })
                }
            }
        }
    }
}
