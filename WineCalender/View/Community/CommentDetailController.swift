//
//  CommentDetailController.swift
//  WineCalender
//
//  Created by Minju Lee on 2022/01/14.
//

import UIKit
import PanModal
import FirebaseAuth

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
                self.commentTextView.text = nil
                self.view.endEditing(true)
                self.fetchComments()
            }
        }
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? CommentDetailCell,
              let indexPath = tableView.indexPath(for: cell),
              let post = post else { return }
        
        let commentID = self.comments[indexPath.row].commentID
        
        if comments[indexPath.row].uid == Auth.auth().currentUser?.uid {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { action in
                PostManager.shared.deleteComment(postUID: post.postID, authorUID: post.authorUID, commentID: commentID) { [weak self] result in
                    switch result {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .success(()):
                        self?.fetchComments()
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "신고하기", style: .destructive, handler: { action in
                let alert2 = UIAlertController(title: "댓글을 신고하시겠습니까?\n신고된 댓글은 검토 후 삭제될 수 있으며 신고가 누적된 사용자는 사용이 제한될 수 있습니다.", message: nil, preferredStyle: .actionSheet)
                alert2.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { [weak self] action in
                    guard let self = self else { return }
                    guard let post = self.post else { return }
                    PostManager.shared.checkIfReportedComment(postID: post.postID, commentID: commentID, completion: { result in
                        switch result {
                        case true:
                            let alert3 = UIAlertController(title: "이미 신고가 접수된 댓글입니다.", message: nil, preferredStyle: .alert)
                            alert3.addAction(UIAlertAction(title: "확인", style: .default, handler: {_ in
                                self.fetchComments()
                            }))
                            self.present(alert3, animated: true, completion: nil)
                        case false:
                            print("신고")
                            guard let uid = Auth.auth().currentUser?.uid else { return }
                            PostManager.shared.reportComment(postID: post.postID, commentID: commentID, authorUID: post.authorUID, currentUserUID: uid, completion: { result in
                                switch result {
                                case .failure(let error):
                                    print(error)
                                case .success(()):
                                    let alert4 = UIAlertController(title: "신고가 접수되었습니다.", message: nil, preferredStyle: .alert)
                                    alert4.addAction(UIAlertAction(title: "확인", style: .default, handler: {_ in
                                        self.fetchComments()
                                    }))
                                    self.present(alert4, animated: true, completion: nil)
                                }
                            })
                        }
                    })
                }))
                alert2.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                self.present(alert2, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
