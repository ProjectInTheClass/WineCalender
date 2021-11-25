//
//  SettingsTableViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/20.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
    
    let section0 = ["공지사항", "도움말", "이용약관", "개인정보 취급방침"]
    lazy var section1 = [String]()
    lazy var section2 = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "설정"
        configureRow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "blackAndWhite")!]
        authListener()
    }
    
    func configureRow() {
        if Auth.auth().currentUser == nil {
            self.section1 = ["회원가입 / 로그인 / 비밀번호 찾기"]
        } else {
            self.section1 = ["프로필 수정", "비밀번호 변경", "로그아웃"]
            self.section2 = ["탈퇴하기"]
        }
    }

    func authListener() {
        AuthenticationManager.shared.authListener { [weak self] result in
            switch result {
            case .success(_):
                return
            case .failure(let error):
                if error == AuthError.userTokenExpired {
                    self?.configureRow()
                    self?.tableView.reloadData()
                    let alert = UIAlertController(title: nil, message: error.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                } else if error == AuthError.failedToConnectToNetwork || error == AuthError.unknown {
                    let alert = UIAlertController(title: nil, message: error.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                } else if error == AuthError.nonmember {
                    self?.configureRow()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if Auth.auth().currentUser == nil {
            return 2
        } else {
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return section0.count
        case 1:
            return section1.count
        case 2:
            return section2.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell")
        switch indexPath.section {
        case 1:
            cell?.textLabel?.text = section1[indexPath.row]
        case 2:
            cell?.textLabel?.text = section2[indexPath.row]
        default:
            cell?.textLabel?.text = section0[indexPath.row]
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if Auth.auth().currentUser == nil && section == 1 {
            return "로그인을 하시면 기록을 백업하고, 다른 사용자들과 기록을 공유할 수 있습니다."
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 0 {
            
        } else {
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            if Auth.auth().currentUser == nil {
                let signInIndexPath = IndexPath(row: 0, section: 1)
                if indexPath == signInIndexPath {
                    let signInVC = storyboard.instantiateViewController(identifier: "SignInViewController") as! SignInViewController
                    self.navigationController?.pushViewController(signInVC, animated: true)
                }
            } else {
                AuthenticationManager.shared.checkNetworkConnection { [weak self] result in
                    switch result {
                    case .failure(let error):
                        let alert = UIAlertController(title: nil, message: error.message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                        
                    case .success(()):
                        let editProfileIndexPath = IndexPath(row: 0, section: 1)
                        let changePasswordIndexPath = IndexPath(row: 1, section: 1)
                        let signOutIndexPath = IndexPath(row: 2, section: 1)
                        let deleteAccountIndexPath = IndexPath(row: 0, section: 2)
                        
                        switch indexPath {
                        case editProfileIndexPath:
                            if let editProfileVC = storyboard.instantiateViewController(identifier: "EditProfileViewController") as? EditProfileViewController {
                                self?.navigationController?.pushViewController(editProfileVC, animated: true)
                            }
                        case changePasswordIndexPath:
                            if let updatePasswordVC = storyboard.instantiateViewController(identifier: "UpdatePasswordViewController") as? UpdatePasswordViewController {
                                self?.navigationController?.pushViewController(updatePasswordVC, animated: true)
                            }
                        case signOutIndexPath:
                            let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                                AuthenticationManager.shared.signOut { result in
                                    switch result {
                                    case .failure(let error):
                                        let alert2 = UIAlertController(title: nil, message: error.message, preferredStyle: .alert)
                                        alert2.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                                        self?.present(alert2, animated: true, completion: nil)
                                    case .success(()):
                                        if let myWinesVC = self?.navigationController?.children.first as? MyWinesViewController {
                                            myWinesVC.posts = [Post]()
                                            myWinesVC.updateNonmemberUI()
                                            self?.navigationController?.popViewController(animated: true)
                                        }
                                    }
                                }
                            }))
                            self?.present(alert, animated: true, completion: nil)
                        case deleteAccountIndexPath:
                            if let editProfileVC = storyboard.instantiateViewController(identifier: "DeleteAccountViewController") as? DeleteAccountViewController {
                                self?.navigationController?.pushViewController(editProfileVC, animated: true)
                            }
                        default:
                            return
                        }
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
