//
//  UpdatePasswordViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/24.
//

import UIKit
import FirebaseAuth

class UpdatePasswordViewController: UIViewController {

    @IBOutlet weak var presentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var checkNewPasswordTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "비밀번호 변경"
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard presentPasswordTextField.text != "", newPasswordTextField.text != "",
              checkNewPasswordTextField.text != "" else {
            warningLabel.text = "빈 칸을 입력해 주세요."
            return
        }
        
        guard (newPasswordTextField.text?.count)! >= 6 else {
            warningLabel.text = "비밀번호는 6글자 이상으로 설정해 주세요."
            return
        }
        
        guard newPasswordTextField.text == checkNewPasswordTextField.text else {
            warningLabel.text = "새 비밀번호와 새 비밀번호 확인이 일치하지 않습니다."
            return
        }
        
        if let presentPassword = presentPasswordTextField.text, let newPassword = newPasswordTextField.text {
            AuthenticationManager.shared.updatePassword(presentPassword: presentPassword, newPassword: newPassword, warningLabel: self.warningLabel) { result in
                if result == true {
                    let alret = UIAlertController(title: "비밀번호 변경 완료", message: nil, preferredStyle: .alert)
                    alret.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alret, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        if let email = Auth.auth().currentUser?.email {
            let message = "이메일 주소 : \(email)"
            let alert = UIAlertController(title: "비밀번호 재설정 이메일을 전송합니다. 이메일을 확인해 주세요.", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                AuthenticationManager.shared.resetPassword(email: email) { result in
                    if result == true {
                        //print("이메일 전송 완료")
                    } else {
                        //print("이메일 전송 오류")
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
