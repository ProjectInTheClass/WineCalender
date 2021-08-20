//
//  SignInViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/20.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "로그인"
    }
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            AuthenticationManager.shared.signIn(email: email, password: password, warningLabel: warningLabel) { result in
                if result == true {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
}

extension SignInViewController {
    static let userStateChangeNoti = Notification.Name(rawValue: "userStateChangeNoti")
}
