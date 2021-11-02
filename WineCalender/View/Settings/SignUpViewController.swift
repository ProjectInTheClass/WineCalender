//
//  SignUpViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/20.
//

import UIKit

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
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
    
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "카메라", style: .default) { action in
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            alert.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "사진 선택", style: .default) { action in
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            alert.addAction(photoLibraryAction)
        }
        
        let deleteAction = UIAlertAction(title: "사진 선택 안 함", style: .default) { action in
            self.profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        profileImageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
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
        
        if let email = emailTextField.text, let password = passwordTextField.text,
           let nickname = nicknameTextField.text, let profileImage = profileImageView.image {
            AuthenticationManager.shared.signUp(email: email, password: password, nickname: nickname,
                                                profileImage: profileImage, warningLabel: warningLabel) { result in
                if result == true,
                   let myWinesVC = self.navigationController?.children.first as? MyWinesViewController {
                    myWinesVC.uploadNewMemberData()
                    myWinesVC.updateMemberUI()
                    let alert = UIAlertController(title: "회원가입완료", message: "환영합니다:)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default) { done in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                    self.present(alert, animated: true, completion: nil)
                } else {
                    print("회원가입 실패")
                }
            }
        }
    }
}
