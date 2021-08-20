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
                NotificationCenter.default.post(name: SignInViewController.userStateChangeNoti, object: nil)
                return completion(true)
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
}
