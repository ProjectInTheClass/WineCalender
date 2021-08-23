//
//  EditProfileViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/23.
//

import UIKit
import FirebaseAuth

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "프로필 수정"
        fetchUserProfile()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func keboardReturnKeyTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }

    func fetchUserProfile() {
        profileImageView.layer.borderColor = UIColor.systemIndigo.cgColor
        profileImageView.layer.borderWidth = 1
        
        emailLabel.text = Auth.auth().currentUser?.email
        
        DispatchQueue.main.async {
            AuthenticationManager.shared.fetchUserNicknameAndProfileImage { nickname, profileImageURL in
                self.nicknameTextField.text = nickname
                if profileImageURL != nil {
                    self.profileImageView.kf.setImage(with: profileImageURL)
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
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard nicknameTextField.text != "" else {
            warningLabel.text = "닉네임을 입력해 주세요."
            return
        }
        warningLabel.text = ""
        
        let alert = UIAlertController(title: "프로필 수정", message: "프로필을 수정하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
            let nickname = self.nicknameTextField.text!
            let profileImage = self.profileImageView.image!
            AuthenticationManager.shared.saveUserNicknameAndProfileImage(nickname: nickname, profileImage: profileImage) { result in
                if result == true {
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
