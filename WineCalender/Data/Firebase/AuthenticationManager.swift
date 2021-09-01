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
                self.saveMyProfile(profileImage: profileImage, nickname: nickname, introduction: "" ) { result in
                    if result == true {
                        NotificationCenter.default.post(name: SignInViewController.userSignInNoti, object: nil)
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
                NotificationCenter.default.post(name: SignInViewController.userSignInNoti, object: nil)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            NotificationCenter.default.post(name: SettingsTableViewController.userSignOutNoti, object: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func saveMyProfile(profileImage: UIImage, nickname: String, introduction: String, completion: @escaping(Bool) -> Void) {
        let uid = Auth.auth().currentUser!.uid
        if !profileImage.isSymbolImage {
            let profileImageName = uid + ".jpg"
            print("saveUserProfile profileImageName - \(profileImageName)")
            if let profileImageData = profileImage.jpegData(compressionQuality: 0.1) {
                userProfileImageRef.child(profileImageName).putData(profileImageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("프로필 이미지 등록 에러 : \(error.localizedDescription)")
                    } else {
                        print("프로필 이미지 등록함")
                        if introduction != "" {
                            AuthenticationManager.shared.userRef.child(uid).setValue(["nickname": nickname, "introduction": introduction])
                            completion(true)
                        } else {
                            AuthenticationManager.shared.userRef.child(uid).setValue(["nickname": nickname])
                            completion(true)
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
    
    func fetchMyProfile(completion: @escaping(_ profileImageURL: URL?, _ nickname: String, _ introduction: String) -> Void) {
        if let uid = Auth.auth().currentUser?.uid {
            userRef.child(uid).observeSingleEvent(of: .value) { snapshot in
                guard let values = snapshot.value as? [String : String] else { return }

                let nickname = values["nickname"]!
                
                var introduction = ""
                if let introductionValue = values["introduction"] {
                    introduction = introductionValue
                }
                
                let profileImageName = uid + ".jpg"
                self.userProfileImageRef.child(profileImageName).downloadURL { url, error in
                    if let error = error {
                        let profileImageURL: URL? = nil
                        print("이미지 다운로드 에러 또는 이미지없음: \(error.localizedDescription)")
                        completion(profileImageURL, nickname, introduction)
                    } else {
                        self.userProfileImageRef.child(profileImageName).downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                return
                            }
                            let profileImageURL = downloadURL
                            completion(profileImageURL, nickname, introduction)
                        }
                    }
                }
            }
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
