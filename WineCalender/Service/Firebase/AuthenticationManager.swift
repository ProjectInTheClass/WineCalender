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
    private init() { }

    let userRef = Database.database().reference().child("User")
    let userProfileImageRef = Storage.storage().reference().child("ProfileImage")
    
    func checkNetworkConnection(completion: @escaping(Result<Void,AuthError>) -> Void) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observeSingleEvent(of: .value) { snapshot in
            guard let connected = snapshot.value as? Bool, connected else {
                print("네트워크 오류 : \(AuthError.failedToConnectToNetwork.message)")
                completion(.failure(AuthError.failedToConnectToNetwork))
                return
            }
            completion(.success(()))
        }
    }
    
    func signUp(email: String, password: String, nickname: String, completion: @escaping(Result<Void,AuthError>) -> Void) {
        checkNetworkConnection { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    completion(.failure(error))
                }
            case .success(()):
                if let currentUserUID = Auth.auth().currentUser?.uid {
                    self?.checkNickname(uid: nil, nickname: nickname) { result in
                        if result == false {
                            print("닉네임 등록 오류 : \(AuthError.unavailableNickname.message)")
                            completion(.failure(AuthError.unavailableNickname))
                        } else {
                            AuthenticationManager.shared.saveUserNickname(uid: currentUserUID, nickname: nickname ) { result in
                                if result == true {
                                    completion(.success(()))
                                } else {
                                    completion(.failure(AuthError.failedToSaveUserNickname))
                                }
                            }
                        }
                    }
                } else {
                    self?.checkNickname(uid: nil, nickname: nickname) { result in
                        if result == false {
                            print("회원가입 오류 : \(AuthError.unavailableNickname.message)")
                            completion(.failure(AuthError.unavailableNickname))
                        } else {
                            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                                if error != nil {
                                    print("회원가입 오류 : \(error?.localizedDescription ?? "")")
                                    if error.debugDescription.contains("ERROR_INVALID_EMAIL") {
                                        completion(.failure(AuthError.invalidEmail))
                                    } else if error.debugDescription.contains("ERROR_EMAIL_ALREADY_IN_USE") {
                                        completion(.failure(AuthError.emailAlreadyInUse))
                                    } else {
                                        completion(.failure(AuthError.failedToSignUp))
                                    }
                                } else {
                                    guard let uid = authResult?.user.uid else { return }
                                    AuthenticationManager.shared.saveUserNickname(uid: uid, nickname: nickname) { result in
                                        if result == true {
                                            completion(.success(()))
                                        } else {
                                            completion(.failure(AuthError.failedToSaveUserNickname))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func editUserProfile(profileImage: UIImage?, nickname: String, introduction: String?, completion: @escaping(Result<Void,AuthError>) -> Void) {
        checkNetworkConnection { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    completion(.failure(error))
                }
            case .success(()):
                guard let uid = Auth.auth().currentUser?.uid else { return }
                self?.checkNickname(uid: uid, nickname: nickname) { result in
                    if result == false {
                        print("프로필 수정 오류 : \(AuthError.unavailableNickname.message)")
                        completion(.failure(AuthError.unavailableNickname))
                    } else {
                        self?.saveUserProfile(uid: uid, profileImage: profileImage, nickname: nickname, introduction: introduction, completion: { result in
                            switch result {
                            case .failure(let error):
                                completion(.failure(error))
                            case .success(()):
                                completion(.success(()))
                            }
                        })
                    }
                }
            }
        }
    }
    
    func checkNickname(uid: String?, nickname: String, completion: @escaping(Bool) -> Void) {
        AuthenticationManager.shared.userRef.queryOrdered(byChild: "nickname").queryEqual(toValue: nickname).observeSingleEvent(of: .value) { snapshot in
            if let snapshotDict = snapshot.value as? [String:Any] {
                if snapshotDict.keys.first == uid { //1) 중복 - 본인이 쓰던 기존 닉네임 그대로
                    completion(true)
                } else { //2) 중복 - 다른 사용자가 사용하는 닉네임이면
                    completion(false)
                }
            } else { //3) 중복이 아니면
                completion(true)
            }
        }
    }

    func saveUserNickname(uid: String, nickname: String, completion: @escaping(Bool) -> Void) {
        AuthenticationManager.shared.userRef.child(uid).setValue(["nickname": nickname]) { error, ref in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func saveUserProfile(uid: String, profileImage: UIImage?, nickname: String, introduction: String?, completion: @escaping(Result<Void,AuthError>) -> Void) {
        let profileImageName = uid + ".jpg"
        if let profileImage = profileImage {
            if let profileImageData = profileImage.jpegData(compressionQuality: 0.1) {
                self.userProfileImageRef.child(profileImageName).putData(profileImageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("프로필 이미지 등록 에러 : \(error.localizedDescription)")
                        completion(.failure(AuthError.failedToSaveUserProfile))
                    } else {
                        self.userProfileImageRef.child(profileImageName).downloadURL { url, error in
                            guard let urlString: String = url?.absoluteString else { return }
                            if let introduction = introduction {
                                AuthenticationManager.shared.userRef.child(uid).setValue(["profileImageURL": urlString, "nickname": nickname, "introduction": introduction])
                                completion(.success(()))
                            } else {
                                AuthenticationManager.shared.userRef.child(uid).setValue(["profileImageURL": urlString, "nickname": nickname])
                                completion(.success(()))
                            }
                        }
                    }
                }
            }
        } else {
            if let introduction = introduction {
                AuthenticationManager.shared.userRef.child(uid).setValue(["nickname": nickname, "introduction": introduction]) { error, ref in
                    if error == nil {
                        completion(.success(()))
                    } else {
                        completion(.failure(AuthError.failedToSaveUserProfile))
                    }
                }
            } else {
                AuthenticationManager.shared.userRef.child(uid).setValue(["nickname": nickname]) { error, ref in
                    if error == nil {
                        completion(.success(()))
                    } else {
                        completion(.failure(AuthError.failedToSaveUserProfile))
                    }
                }
            }
            AuthenticationManager.shared.userProfileImageRef.child(profileImageName).delete()
        }
    }
    
    ///My profile
    func fetchMyProfile(completion: @escaping (Result<User,AuthError>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid, let email = Auth.auth().currentUser?.email else {
            return
        }
        userRef.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let values = snapshot.value as? [String : String] else {
                completion(.failure(AuthError.failedToFetchMyProfile))
                return
            }
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
            
            completion(.success(user))
        }
    }
    
    ///Post Author Profile
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
    
    ///Another user profile
    func fetchAnotherUserProfile(uid: String, completion: @escaping (URL?, String, String?) -> Void) {
        userRef.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let values = snapshot.value as? [String : String] else { return }
            
            var profileImageURL: URL? = nil
            if let url = values["profileImageURL"] {
                profileImageURL = URL(string: url)
            }
            
            let nickname = values["nickname"]!
            
            var introduction: String? = nil
            if let value = values["introduction"] {
                introduction = value
            }
            
            completion(profileImageURL, nickname, introduction)
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping(Result<Void,AuthError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { uthResult, error in
            if error != nil {
                print("로그인 오류 : \(error?.localizedDescription ?? "")")
                if error.debugDescription.contains("ERROR_NETWORK_REQUEST_FAILED") {
                    completion(.failure(AuthError.failedToConnectToNetwork))
                } else if error.debugDescription.contains("ERROR_INVALID_EMAIL") {
                    completion(.failure(AuthError.invalidEmail))
                } else if error.debugDescription.contains("ERROR_WRONG_PASSWORD") {
                    completion(.failure(AuthError.wrongPassword))
                } else if error.debugDescription.contains("ERROR_USER_NOT_FOUND") {
                    completion(.failure(AuthError.userNotFound))
                } else {
                    completion(.failure(AuthError.failedToSignIn))
                }
            } else {
                completion(.success(()))
            }
        }
    }
    
    func signOut(completion: @escaping(Result<Void,AuthError>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch let signOutError as NSError {
            print("로그아웃 오류 : ", signOutError)
            completion(.failure(AuthError.failedToSignOut))
        }
    }
    
    func resetPassword(email: String, completion: @escaping(Result<Void,AuthError>) -> Void) {
        checkNetworkConnection { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    completion(.failure(error))
                }
            case .success(()):
                Auth.auth().languageCode = "ko_kr"
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if error != nil {
                        print("비밀번호 찾기 오류 : \(error?.localizedDescription ?? "")")
                        if error.debugDescription.contains("ERROR_INVALID_EMAIL") {
                            completion(.failure(AuthError.invalidEmail))
                        } else if error.debugDescription.contains("ERROR_USER_NOT_FOUND") {
                            completion(.failure(AuthError.userNotFound))
                        } else {
                            completion(.failure(AuthError.failedToResetPassword))
                        }
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    func updatePassword(presentPassword: String, newPassword: String, completion: @escaping(Result<Void,AuthError>) -> Void) {
        checkNetworkConnection { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    completion(.failure(error))
                }
            case .success(()):
                if let email = Auth.auth().currentUser?.email {
                    //현재 비밀번호 확인을 위한 signIn
                    self?.signIn(email: email, password: presentPassword) { result in
                        switch result {
                        case .failure(let error):
                                completion(.failure(error))
                        case .success(()):
                            Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { error in
                                if error != nil, error.debugDescription.contains("ERROR_REQUIRES_RECENT_LOGIN") {
                                    self?.reauthenticate(email: email, password: presentPassword) { result in
                                        if result == true {
                                            Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { error in
                                                if error != nil {
                                                    print("비밀번호 변경 오류 : ", error?.localizedDescription ?? "")
                                                    completion(.failure(AuthError.failedToUpdatePassword))
                                                } else {
                                                    completion(.success(()))
                                                }
                                            })
                                        } else {
                                            print("비밀번호 변경 오류 - 재인증 실패 : ", error?.localizedDescription ?? "")
                                            completion(.failure(AuthError.failedToUpdatePassword))
                                        }
                                    }
                                } else if error != nil {
                                    print("비밀번호 변경 오류 : ", error?.localizedDescription ?? "")
                                    completion(.failure(AuthError.failedToUpdatePassword))
                                } else {
                                    completion(.success(()))
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func deleteAccount(password: String, completion: @escaping (Result<Void,AuthError>) -> Void) {
        guard let user = Auth.auth().currentUser, let email = user.email else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //비밀번호 확인을 위한 signIn
        signIn(email: email, password: password) { result in
            switch result {
            case .failure(let error):
                    completion(.failure(error))
            case .success(()):
                PostManager.shared.fetchMyPostIDs { result, postIDs in
                    if result == false {
                        print("탈퇴 오류 : post 삭제 오류")
                        completion(.failure(AuthError.failedToDeleteAccount))
                    }
                    if result == true, postIDs == nil {
                        //보류
                        //deleteLikesAndComments()
                        deleteProfileAndAccount()
                    }
                    if result == true, let postIDs = postIDs {
                        PostManager.shared.removeMyPosts(postIDs: postIDs, authorUID: uid, numberOfImages: 3) { result in
                            
                            switch result {
                            case false:
                                completion(.failure(AuthError.failedToDeleteAccount))
                            case true:
                                //보류
                                //deleteLikesAndComments()
                                deleteProfileAndAccount()
                            }
                        }
                    }
                }
            }
        }
        
        func deleteLikesAndComments() {
            PostManager.shared.removeMyLikesAndComments(authorUID: uid) { result in
                switch result {
                case false:
                    completion(.failure(AuthError.failedToDeleteAccount))
                case true:
                    deleteProfileAndAccount()
                }
            }
        }
        
        func deleteProfileAndAccount() {
            let profileImageName = uid + ".jpg"
            AuthenticationManager.shared.userProfileImageRef.child(profileImageName).delete { error in
                if let error = error, error.localizedDescription.contains("does not exist.") {
                    deleteUserRefAndAccount()
                } else if let error = error {
                    print("탈퇴 오류 - 프로필 이미지 삭제 오류 : ", error.localizedDescription)
                    completion(.failure(AuthError.failedToDeleteAccount))
                } else {
                    deleteUserRefAndAccount()
                }
            }
            
            func deleteUserRefAndAccount() {
                AuthenticationManager.shared.userRef.child(uid).removeValue { error, ref in
                    if let error = error {
                        print("탈퇴 오류 - userRef 삭제 오류 : ", error.localizedDescription)
                        completion(.failure(AuthError.failedToDeleteAccount))
                    } else {
                        user.delete { [weak self] error in
                            if error != nil {
                                print("탈퇴 오류 : ", error?.localizedDescription ?? "")
                                if error.debugDescription.contains("ERROR_REQUIRES_RECENT_LOGIN") {
                                    self?.reauthenticate(email: email, password: password) { result in
                                        if result == true {
                                            user.delete { error in
                                                if error != nil {
                                                    print("탈퇴 오류 : ", error?.localizedDescription ?? "")
                                                    completion(.failure(AuthError.failedToDeleteAccount))
                                                } else {
                                                    completion(.success(()))
                                                }
                                            }
                                        } else {
                                            completion(.failure(AuthError.failedToDeleteAccount))
                                        }
                                    }
                                } else {
                                    completion(.failure(AuthError.failedToDeleteAccount))
                                }
                            } else {
                                completion(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func reauthenticate(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let user = Auth.auth().currentUser
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        user?.reauthenticate(with: credential) { result, error in
            if let error = error {
                print("재인증 오류 : ", error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func authListener(completion: @escaping (Result<Void,AuthError>) -> Void) {
        Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                completion(.failure(AuthError.nonmember))
            } else {
                user?.reload(completion: { error in
                    if error != nil {
                        print(error.debugDescription)
                        if error.debugDescription.contains("ERROR_USER_TOKEN_EXPIRED") {
                            completion(.failure(AuthError.userTokenExpired))
                        } else if error.debugDescription.contains("ERROR_USER_NOT_FOUND") {
                            completion(.failure(AuthError.userTokenExpired))
                        } else if error.debugDescription.contains("ERROR_NETWORK_REQUEST_FAILED") {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                completion(.failure(AuthError.failedToConnectToNetwork))
                            }
                        } else {
                            completion(.failure(AuthError.unknown))
                        }
                    } else {
                        completion(.success(()))
                    }
                })
            }
        }
    }
}

enum AuthError: Error {
    case failedToConnectToNetwork
    
    case unavailableNickname
    case invalidEmail
    case emailAlreadyInUse
    case failedToSaveUserNickname
    case failedToSignUp
 
    case failedToFetchMyProfile
    case failedToSaveUserProfile
    
    case wrongPassword
    case userNotFound
    case failedToSignIn
    
    case failedToSignOut
    
    case failedToResetPassword
    
    case failedToUpdatePassword
    
    case failedToDeleteAccount
    
    case userTokenExpired
    case unknown
    case nonmember
    
    var message: String {
        switch self {
        case .failedToConnectToNetwork:
            return "네트워크에 연결할 수 없습니다.\n네트워크 상태 확인 후 다시 시도해 주세요."

        case .unavailableNickname:
            return "사용할 수 없는 닉네임입니다."
        case .invalidEmail:
            return "이메일 주소를 정확하게 입력해 주세요."
        case .emailAlreadyInUse:
            return "이미 사용 중인 이메일 주소입니다."
        case .failedToSaveUserNickname:
            return "닉네임 등록에 실패했습니다. 잠시 후 다시 시도해 주세요.\n이 오류가 반복되면 [설정]-[도움말]을 참고해 주세요."
        case .failedToSignUp:
            return "회원가입에 실패했습니다. 잠시 후 다시 시도해 주세요.\n이 오류가 반복되면 [설정]-[도움말]을 참고해 주세요."
   
        case .failedToFetchMyProfile:
            return "프로필을 불러올 수 없습니다. 프로필을 다시 등록해 주세요."
        case .failedToSaveUserProfile:
            return "프로필 저장에 실패했습니다. 잠시 후 다시 시도해 주세요.\n이 오류가 반복되면 [설정]-[도움말]을 참고해 주세요."
            
        case .wrongPassword:
            return "입력하신 정보가 맞는지 다시 확인해 주세요."
        case .userNotFound:
            return "입력하신 정보가 맞는지 다시 확인해 주세요."
        case .failedToSignIn:
            return "로그인에 실패했습니다. 잠시 후 다시 시도해 주세요.\n이 오류가 반복되면 [설정]-[도움말]을 참고해 주세요."
            
        case .failedToSignOut:
            return "로그아웃에 실패했습니다.\n잠시 후 다시 시도해 주세요.\n이 오류가 반복되면 [설정]-[도움말]을 참고해 주세요."
            
        case .failedToResetPassword:
            return "이메일 전송에 실패했습니다.\n잠시 후 다시 시도해 주세요.\n이 오류가 반복되면 [설정]-[도움말]을 참고해 주세요."
            
        case .failedToUpdatePassword:
            return "비밀번호 변경에 실패했습니다. 잠시 후 다시 시도해 주세요.\n이 오류가 반복되면 [설정]-[도움말]을 참고해 주세요."
      
        case .failedToDeleteAccount:
            return "일시적인 오류가 있습니다. 잠시 후 다시 시도해 주세요.\n이 오류가 반복되면 [설정]-[도움말]을 참고해 주세요."
            
        case .userTokenExpired:
            return "사용자 토큰이 만료되었습니다."
        case .unknown:
            return "서버로부터 데이터를 불러오는데 실패했습니다.\n앱을 재실행해 주세요."
        case .nonmember:
            return ""
        }
    }
}
