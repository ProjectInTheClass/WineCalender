//
//  FindPasswordViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/24.
//

import UIKit

class FindPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "비밀번호 찾기"
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard emailTextField.text != "" else {
            warningLabel.text = "이메일 주소를 입력해 주세요."
            return
        }
        if let email = emailTextField.text {
            AuthenticationManager.shared.resetPassword(email: email) { result in
                if result == false {
                    self.warningLabel.text = "이메일 주소를 다시 확인해 주세요."
                } else {
                    let alert = UIAlertController(title: nil, message: "비밀번호 재설정 이메일 전송했습니다. 이메일을 확인해 주세요.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
