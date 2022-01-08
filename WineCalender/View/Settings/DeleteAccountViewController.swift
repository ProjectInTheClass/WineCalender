//
//  DeleteAccountViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/11/22.
//

import UIKit
import Lottie

class DeleteAccountViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    let addButton = TabBarController.addButton
    
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
        
        let animationView: AnimationView = {
            let aniView = AnimationView(name: "swirling-wine")
            aniView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            aniView.contentMode = .scaleAspectFill
            aniView.loopMode = .loop
            aniView.backgroundColor = .white
            aniView.layer.cornerRadius = 50
            return aniView
        }()
        
        func animationPlay() {
            self.view.isUserInteractionEnabled = false
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            self.tabBarController?.tabBar.isUserInteractionEnabled = false
            self.view.superview?.addSubview(animationView)
            animationView.center = self.view.center
            animationView.play()
        }
        
        func animationStop() {
            animationView.stop()
            animationView.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
            self.navigationController?.navigationBar.isUserInteractionEnabled = true
            self.tabBarController?.tabBar.isUserInteractionEnabled = true
        }
        
        animationPlay()
        
        AuthenticationManager.shared.deleteAccount(password: password) { [weak self] result in
            switch result {
            case .failure(let error):
                animationStop()
                self?.warningLabel.text = error.message
            case .success(()):
                animationStop()
                let alert = UIAlertController(title: "회원 탈퇴가 완료되었습니다.", message: "이용해 주셔서 감사합니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
//                    if let myWinesVC = self?.navigationController?.children.first as? MyWinesViewController {
//                        myWinesVC.signOutUI()
//                    }
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.addButton.isHidden = false
                    
                    AuthenticationManager.shared.authListener { result in
                        switch result {
                        case .success(_):
                            return
                        case .failure(_):
                            return
                        }
                    }
                }))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
