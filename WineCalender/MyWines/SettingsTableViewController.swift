//
//  SettingsTableViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/20.
//

import UIKit
import Firebase

class SettingsTableViewController: UITableViewController {
    
    let section1 = ["공지사항", "도움말", "문의하기", "이용약관", "개인정보 취급방침"]
    lazy var section2 = [String]()

    var userState: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateRow()
        
//        NotificationCenter.default.addObserver(forName: SignInViewController.userSignInNoti, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
//            self?.updateRow()
//        }
    }
    
    func updateRow() {
        if Auth.auth().currentUser == nil {
            self.section2 = ["로그인"]
            userState = false
        } else {
            self.section2 = ["프로필 수정", "비밀번호 변경", "로그아웃"]
            userState = true
        }
        self.tableView.reloadData()
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
        if userState {
            let editProfileIndexPath = IndexPath(row: 0, section: 1)
            let changePasswordIndexPath = IndexPath(row: 1, section: 1)
            let signOutIndexPath = IndexPath(row: 2, section: 1)
            switch indexPath {
            case editProfileIndexPath:
                if let editProfileVC = storyboard?.instantiateViewController(identifier: "EditProfileViewController") as? EditProfileViewController {
                    self.navigationController?.pushViewController(editProfileVC, animated: true)
                }
            case changePasswordIndexPath:
                if let updatePasswordVC = storyboard?.instantiateViewController(identifier: "UpdatePasswordViewController") as? UpdatePasswordViewController {
                    self.navigationController?.pushViewController(updatePasswordVC, animated: true)
                }
            case signOutIndexPath:
                let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                    AuthenticationManager.shared.signOut()
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            default:
                return
            }
        } else {
            let signInIndexPath = IndexPath(row: 0, section: 1)
            if indexPath == signInIndexPath {
                print("sign in")
                let signInVC = self.storyboard?.instantiateViewController(identifier: "SignInViewController") as! SignInViewController
                self.navigationController?.pushViewController(signInVC, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension SettingsTableViewController {
    static let userSignOutNoti = Notification.Name(rawValue: "userSignOutNoti")
}
