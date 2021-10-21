//
//  EditProfileViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/23.
//

import UIKit

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var introductionTextView: UITextView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "프로필 수정"
        fetchMyProfile()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func nicknameReturnKeyTapped(_ sender: UITextField) {
        introductionTextView.becomeFirstResponder()
    }
    
    func fetchMyProfile() {
        AuthenticationManager.shared.fetchMyProfile { user in
            DispatchQueue.main.async {
                self.profileImageView.kf.setImage(with: user.profileImageURL, placeholder: UIImage(systemName: "person.circle.fill")!.withTintColor(.systemPurple, renderingMode: .alwaysOriginal))
                self.emailLabel.text = user.email
                self.nicknameTextField.text = user.nickname
                if let introduction = user.introduction {
                    self.introductionTextView.text = introduction
                    self.introductionTextView.textColor = UIColor(named: "blackAndWhite")
                } else {
                    self.introductionTextView.text = "소개"
                    self.introductionTextView.textColor = UIColor.systemGray2
                }
            }
        }
    }
    
    @IBAction func profileImageButtonTapped(_ sender: UIButton) {
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
            self.profileImageView.image = UIImage(systemName: "person.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if introductionTextView.text == "소개" {
            introductionTextView.text = ""
            introductionTextView.textColor = UIColor(named: "blackAndWhite")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if introductionTextView.text == "" || introductionTextView.text == "소개" {
            introductionTextView.text = "소개"
            introductionTextView.textColor = UIColor.systemGray2
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard nicknameTextField.text != "" else {
            warningLabel.text = "닉네임을 입력해 주세요."
            nicknameTextField.becomeFirstResponder()
            return
        }
        warningLabel.text = ""
        
        self.nicknameTextField.resignFirstResponder()
        self.introductionTextView.resignFirstResponder()
        
        let alert = UIAlertController(title: "프로필 수정", message: "프로필을 수정하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
            
            let profileImage = self.profileImageView.image!
            let nickname = self.nicknameTextField.text!
            var introduction = ""
            if self.introductionTextView.text != "소개" {
                introduction = self.introductionTextView.text
            }
            
            AuthenticationManager.shared.editUserProfile(profileImage: profileImage, nickname: nickname, introduction: introduction, warningLabel: self.warningLabel) { result in
                if result == true,
                   let myWinesVC = self.navigationController?.children.first as? MyWinesViewController{
                    myWinesVC.fetchMyProfile()
                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    print("프로필 수정 오류")
                    //self.warningLabel.text = "오류 잠시 후 다시 시도해 주세요. "
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
