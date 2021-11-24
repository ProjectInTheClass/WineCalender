//
//  SignInViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/20.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "로그인"
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func emailReturnKeyTapped(_ sender: UITextField) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordReturnKeyTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            guard email != "" else {
                warningLabel.text = "이메일 주소를 입력해 주세요."
                return
            }
            guard password != "" else {
                warningLabel.text = "비밀번호를 입력해 주세요."
                return
            }
            guard password.count >= 6 else {
                warningLabel.text = "입력하신 정보가 맞는지 다시 확인해 주세요."
                return
            }
            warningLabel.text = ""

            AuthenticationManager.shared.signIn(email: email, password: password) { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.warningLabel.text = error.message
                case .success(()):
                    if  let myWinesVC = self?.navigationController?.children.first as? MyWinesViewController {
                        myWinesVC.notes = [WineTastingNote]()
                        myWinesVC.updateMemberUI()
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }
}
