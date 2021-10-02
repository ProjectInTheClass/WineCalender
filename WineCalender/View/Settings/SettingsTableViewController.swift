//
//  SettingsTableViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/20.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
    
    let section1 = ["공지사항", "도움말", "문의하기", "이용약관", "개인정보 취급방침"]
    lazy var section2 = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "설정"
        updateRow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    }
    
    func updateRow() {
        if Auth.auth().currentUser == nil {
            self.section2 = ["로그인"]
        } else {
            self.section2 = ["프로필 수정", "비밀번호 변경", "로그아웃"]
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return section1.count
        default:
            return section2.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell")
        switch indexPath.section {
        case 0:
            cell?.textLabel?.text = section1[indexPath.row]
        default:
            cell?.textLabel?.text = section2[indexPath.row]
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        
        if Auth.auth().currentUser != nil {
            let editProfileIndexPath = IndexPath(row: 0, section: 1)
            let changePasswordIndexPath = IndexPath(row: 1, section: 1)
            let signOutIndexPath = IndexPath(row: 2, section: 1)

            switch indexPath {
            case editProfileIndexPath:
                if let editProfileVC = storyboard.instantiateViewController(identifier: "EditProfileViewController") as? EditProfileViewController {
                    self.navigationController?.pushViewController(editProfileVC, animated: true)
                }
            case changePasswordIndexPath:
                if let updatePasswordVC = storyboard.instantiateViewController(identifier: "UpdatePasswordViewController") as? UpdatePasswordViewController {
                    self.navigationController?.pushViewController(updatePasswordVC, animated: true)
                }
            case signOutIndexPath:
                let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                    AuthenticationManager.shared.signOut { result in
                        if result == true,
                           let myWinesVC = self.navigationController?.children.first as? MyWinesViewController {
                            myWinesVC.posts = [Post]()
                            myWinesVC.updateNonmemberUI()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            default:
                return
            }
        } else {
            let signInIndexPath = IndexPath(row: 0, section: 1)
            if indexPath == signInIndexPath {
                let signInVC = storyboard.instantiateViewController(identifier: "SignInViewController") as! SignInViewController
                self.navigationController?.pushViewController(signInVC, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
