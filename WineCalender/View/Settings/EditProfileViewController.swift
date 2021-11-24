//
//  EditProfileViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/23.
//

import UIKit
import FirebaseAuth

class EditProfileViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var introductionTextView: UITextView!
    @IBOutlet weak var introductionCountLabel: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    let maximumTextViewCount = 200

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
        AuthenticationManager.shared.fetchMyProfile { [weak self] result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    if let url = user.profileImageURL {
                        self?.profileImageView.kf.setImage(with: url)
                    }
                    self?.emailLabel.text = user.email
                    self?.nicknameTextField.text = user.nickname
                    if let introduction = user.introduction {
                        self?.introductionTextView.text = introduction
                        self?.introductionTextView.textColor = .label
                        self?.introductionCountLabel.text = String((self?.maximumTextViewCount ?? 200) - introduction.count)
                        self?.tableView.beginUpdates()
                        self?.tableView.endUpdates()
                    } else {
                        self?.introductionTextView.text = "소개"
                        self?.introductionTextView.textColor = UIColor.systemGray3
                        self?.introductionCountLabel.text = "200"
                    }
                }
            case .failure(_):
                self?.emailLabel.text = Auth.auth().currentUser?.email
                self?.introductionTextView.text = "소개"
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if introductionTextView.text == "소개" {
            introductionTextView.text = ""
            introductionTextView.textColor = UIColor(named: "blackAndWhite")
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLinesArray = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let currentLines = existingLinesArray.count + newLines.count - 1
        let maximumNumberOfLines = 8
        
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        let currentTextCount = updatedText.count
        
        return currentLines <= maximumNumberOfLines && currentTextCount <= maximumTextViewCount
    }
    
    func textViewDidChange(_ textView: UITextView) {
        introductionCountLabel.text = String(maximumTextViewCount - introductionTextView.text.count)
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if introductionTextView.text == "" || introductionTextView.text == "소개" {
            introductionTextView.text = "소개"
            introductionTextView.textColor = UIColor.systemGray3
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard nicknameTextField.text != "" else {
            warningLabel.text = "닉네임을 입력해 주세요."
            nicknameTextField.becomeFirstResponder()
            return
        }
        guard nicknameTextField.text?.contains("비회원") == false && nicknameTextField.text?.contains(" ") == false else {
            warningLabel.text = "사용할 수 없는 닉네임입니다."
            return
        }
        warningLabel.text = ""
        
        self.nicknameTextField.resignFirstResponder()
        self.introductionTextView.resignFirstResponder()
        
        let alert = UIAlertController(title: "프로필 수정", message: "프로필을 수정하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] action in
            var profileImage: UIImage? {
                if self?.profileImageView.image?.isSymbolImage == true {
                    return nil
                } else {
                    return self?.profileImageView.image
                }
            }
            let nickname = self?.nicknameTextField.text!
            var introduction: String? {
                if self?.introductionTextView.text == "소개" {
                    return nil
                } else {
                    return self?.introductionTextView.text
                }
            }
            
            AuthenticationManager.shared.editUserProfile(profileImage: profileImage, nickname: nickname!, introduction: introduction) { result in
                switch result {
                case .failure(let error):
                    self?.warningLabel.text = error.message
                case .success(()):
                    if let myWinesVC = self?.navigationController?.children.first as? MyWinesViewController{
                        myWinesVC.fetchMyProfile()
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
