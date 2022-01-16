//
//  CommentDetailController.swift
//  WineCalender
//
//  Created by Minju Lee on 2022/01/14.
//

import UIKit
import PanModal

class CommentDetailController: UIViewController, UITextViewDelegate {
    
    var post: Post?
    var comments = [Comment]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentInputView: UIView!
    @IBOutlet weak var commentInputViewBottom: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var uploadCommentButton: UIButton!
    
    let commentTextViewPlaceholder = "댓글을 입력해 주세요."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        commentTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        fetchComments()
    }
    
    @objc func adjustInputView(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue  else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            let adjustmentHeight = keyboardFrame.height - self.view.safeAreaInsets.bottom
            UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) { [weak self] in
                guard let self = self else { return }
                self.commentInputViewBottom.constant = adjustmentHeight
                self.view.layoutIfNeeded()
            }.startAnimation()
        } else {
            commentInputViewBottom.constant = 0
        }
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func fetchComments() {
        guard let postID = post?.postID else { return }
        PostManager.shared.fetchComments(postID: postID) { comments in
            self.comments = comments
            self.tableView.reloadData()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == commentTextViewPlaceholder {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == commentTextViewPlaceholder || textView.text == "" {
            uploadCommentButton.isEnabled = false
        } else {
            uploadCommentButton.isEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" || textView.text == commentTextViewPlaceholder {
            textView.text = commentTextViewPlaceholder
            textView.textColor = UIColor.systemGray2
            uploadCommentButton.isEnabled = false
        }
    }
    
    @IBAction func uploadCommentButtonTapped(_ sender: UIButton) {
        guard let post = post else { return }
        guard commentTextView.text != "" && commentTextView.text != commentTextViewPlaceholder else { return }
        
        uploadCommentButton.isEnabled = false
        
        PostManager.shared.uploadComment(postUID: post.postID, authorUID: post.authorUID, text: commentTextView.text) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(_):
                print("success")
                self.commentTextView.text = nil
                self.view.endEditing(true)
                self.fetchComments()
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate 

extension CommentDetailController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentDetailCell") as? CommentDetailCell else {
                  return UITableViewCell()
        }
        
        cell.viewModel = CommentDetailVM(comments[indexPath.row])
        return cell
    }
}

// MARK: - PanModalPresentable

extension CommentDetailController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        nil
    }
    
    var longFormHeight: PanModalHeight {
        .contentHeight(500)
    }
}
