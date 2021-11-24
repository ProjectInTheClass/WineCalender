//
//  DeleteAccountViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/11/22.
//

import UIKit

class DeleteAccountViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    override func viewDidLoad() {
        self.navigationItem.title = "탈퇴하기"
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }

    @IBAction func returnKeyTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard let password = passwordTextField.text, password != "" else {
            warningLabel.text = "비밀번호를 입력해 주세요."
            return
        }
        guard password.count >= 6 else {
            warningLabel.text = "입력하신 정보가 맞는지 다시 확인해 주세요."
            return
        }
        warningLabel.text = ""
        
        AuthenticationManager.shared.deleteAccount(password: password) { result in
            
        }
    }
}
