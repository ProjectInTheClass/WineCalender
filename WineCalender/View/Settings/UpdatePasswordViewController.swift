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
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func presentPasswordReturnKeyTapped(_ sender: UITextField) {
        newPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func newPasswordReturnKeyTapped(_ sender: UITextField) {
        checkNewPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func checkNewPasswordReturnKeyTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard presentPasswordTextField.text != "", newPasswordTextField.text != "",
              checkNewPasswordTextField.text != "" else {
            warningLabel.text = "빈 칸을 입력해 주세요."
            return
        }
        
        guard (presentPasswordTextField.text?.count)! >= 6 else {
            warningLabel.text = "입력하신 정보가 맞는지 다시 확인해 주세요."
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
        
        warningLabel.text = ""
        
        if let presentPassword = presentPasswordTextField.text, let newPassword = newPasswordTextField.text {
            AuthenticationManager.shared.updatePassword(presentPassword: presentPassword, newPassword: newPassword) { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.warningLabel.text = error.message
                case .success(()):
                    let alert = UIAlertController(title: nil, message: "비밀번호가 변경됐습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                        self?.navigationController?.popViewController(animated: true)
                    }))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        if let email = Auth.auth().currentUser?.email {
            let message = "이메일 주소 : \(email)"
            let alert = UIAlertController(title: "비밀번호 재설정 이메일을 전송합니다.", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                AuthenticationManager.shared.resetPassword(email: email) { [weak self] result in
                    switch result {
                    case .failure(let error):
                        let alert2 = UIAlertController(title: nil, message: error.message, preferredStyle: .alert)
                        alert2.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                        self?.present(alert2, animated: true, completion: nil)
                    case .success(()):
                        let alert3 = UIAlertController(title: nil, message: "비밀번호 재설정 이메일을 전송했습니다. 이메일을 확인해 주세요.", preferredStyle: .alert)
                        alert3.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                            self?.navigationController?.popViewController(animated: true)
                        }))
                        self?.present(alert3, animated: true, completion: nil)
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
