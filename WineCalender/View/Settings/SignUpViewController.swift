//
//  SignUpViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/20.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "회원가입"
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func emailReturnkeyTapped(_ sender: UITextField) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordReturnkeyTapped(_ sender: UITextField) {
        checkPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func checkPasswordReturnkeyTapped(_ sender: UITextField) {
        nicknameTextField.becomeFirstResponder()
    }
    
    @IBAction func nicknameReturnKeyTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if textField == nicknameTextField {
            return updatedText.count <= 15
        } else {
            return updatedText.count <= 50
        }
    }
    
    @IBAction func doenButtonTapped(_ sender: UIButton) {
        guard emailTextField.text != "", passwordTextField.text != "",
              checkPasswordTextField.text != "", nicknameTextField.text != "" else {
            warningLabel.text = "빈 칸을 입력해 주세요."
            return
        }
        warningLabel.text = ""
        
        guard (passwordTextField.text?.count)! >= 6 else {
            warningLabel.text = "비밀번호는 6글자 이상으로 설정해 주세요."
            return
        }
        
        guard passwordTextField.text == checkPasswordTextField.text else {
            warningLabel.text = "비밀번호가 일치하지 않습니다."
            return
        }
        
        guard nicknameTextField.text?.contains("비회원") == false && nicknameTextField.text?.contains(" ") == false else {
            warningLabel.text = "사용할 수 없는 닉네임입니다."
            return
        }
        warningLabel.text = ""
        
        if let email = emailTextField.text, let password = passwordTextField.text,
           let nickname = nicknameTextField.text {
            AuthenticationManager.shared.signUp(email: email, password: password, nickname: nickname) { [weak self] result in
                switch result {
                case .success(()):
                    if let myWinesVC = self?.navigationController?.children.first as? MyWinesViewController {
                        myWinesVC.updateNewMemberUI()
                        let alert = UIAlertController(title: "회원가입이 완료됐습니다!", message: "환영합니다:)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default) { done in
                            self?.navigationController?.popToRootViewController(animated: true)
                        })
                        self?.present(alert, animated: true, completion: nil)
                    }
                case .failure(let error):
                    self?.warningLabel.text = error.message
                }
            }
        }
    }
}
