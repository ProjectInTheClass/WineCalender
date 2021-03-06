//
//  ComuDetailVC.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/08/16.
//

import Foundation
import UIKit
import Kingfisher
import FirebaseAuth
import PanModal

protocol PostDetailDelegate: AnyObject {
    func userDidReport()
}

class PostDetail: UIViewController, UIGestureRecognizerDelegate{
    @IBOutlet weak var postCollection: UICollectionView!
    @IBOutlet weak var detailProfile: UIImageView!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var wineName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var collectionBackground: UIView!
    @IBOutlet weak var profileBg: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var bottomTable: UITableView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var postUpdateTime: UILabel!
    @IBOutlet weak var wineInfoView: UIView!
    @IBOutlet weak var producingCountryLabel: UILabel!
    @IBOutlet weak var vintageLabel: UILabel!
    
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var commentDetailView: UIStackView!
    @IBOutlet weak var commentProfileImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    
    var likesPost: Bool = false
    
    var currentCelIndex = 0
    
    var postDetailVM : PostDetailVM?
    var postDetailData : Post?
    var noteDetailData : WineTastingNote?
    
    weak var delegate : PostDetailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // disable large title
        navigationController?.navigationBar.prefersLargeTitles = false
        
        postCollection.delegate = self
        postCollection.dataSource = self
        
        guard let vm = postDetailVM else { return }
        postCollection.backgroundColor = vm.backgroundColor
        postUpdateTime.text = vm.date
        
        if vm.isMoreButtonHidden {
            navigationItem.rightBarButtonItem = nil
        }
        heartButton.isHidden = vm.isLikeHidden
        likeLabel.isHidden = vm.isLikeHidden
        
        pageControl.numberOfPages = vm.imageCount
        mainText.text = vm.memo
        wineName.text = vm.wineName
        
        producingCountryLabel.text = vm.producingCountry
        vintageLabel.text = vm.vintage
        
        userName.text = vm.userName
        vm.setProfileImage(of: detailProfile)
        
        commentView.isHidden = vm.isCommentHidden
        commentDetailView.isHidden = vm.isCommentDetailHidden
        commentCountLabel.text = vm.commentCount
        
        updateLikes()
        
        updateComments()
        
        addTapGestureRecognizer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        wineInfoView.layer.addBorder([.top, .bottom], color: .systemGray6, width: 1)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        guard let vm = postDetailVM else { return }
        
        if vm.isCoreData {
            //????????? - ??? ????????? or ?????? - ???????????? ?????? ?????????
            guard noteDetailData != nil else { return }
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "??????", style: .destructive, handler: { action in
                let alert2 = UIAlertController(title: "????????? ?????????????????????????", message: nil, preferredStyle: .actionSheet)
                alert2.addAction(UIAlertAction(title: "??????", style: .destructive, handler: { action in
                    DataManager.shared.removeWineTastingNote(wineTastingNote: self.noteDetailData) { result in
                        if result ==  true {
                            self.navigationController?.popViewController(animated: true)
                            NotificationCenter.default.post(name: MyWinesViewController.uploadUpdateDelete, object: nil)
                        }
                    }
                }))
                alert2.addAction(UIAlertAction(title: "??????", style: .cancel, handler: nil))
                self.present(alert2, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "??????", style: .default, handler: { action in
                let storyboard = UIStoryboard(name: "TastingNotes", bundle: nil)
                let addTastingNoteNav = storyboard.instantiateViewController(identifier: "AddTastingNoteNav")
                addTastingNoteNav.modalPresentationStyle = .fullScreen
                let addTastingNoteTVC = addTastingNoteNav.children.first as! AddTastingNoteTableViewController
                addTastingNoteTVC.note = self.noteDetailData
                self.present(addTastingNoteNav, animated: true, completion: nil)
            }))
            //?????? - ???????????? ?????? ????????? ??????
            if Auth.auth().currentUser != nil, let note = noteDetailData {
                alert.addAction(UIAlertAction(title: "??????????????? ??????", style: .default, handler: { _ in
                    let alert2 = UIAlertController(title: "??????????????? ????????? ??? ?????? ????????? ??? ????????????. ?????????????????????????", message: nil, preferredStyle: .actionSheet)
                    alert2.addAction(UIAlertAction(title: "??????", style: .default, handler: { action in
                        PostManager.shared.uploadDatafromCoreDataToFirebase(note: note) { result in
                            switch result {
                            case .success(()):
                                self.navigationController?.popViewController(animated: true)
                                NotificationCenter.default.post(name: MyWinesViewController.uploadUpdateDelete, object: nil)
                            case .failure(let error):
                                let alert3 = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
                                alert3.addAction(UIAlertAction(title: "??????", style: .default, handler: nil))
                                self.present(alert3, animated: true)
                            }
                        }
                    }))
                    alert2.addAction(UIAlertAction(title: "??????", style: .cancel, handler: nil))
                    self.present(alert2, animated: true, completion: nil)
                }))
            }
            alert.addAction(UIAlertAction(title: "??????", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            guard let currentUserUID = Auth.auth().currentUser?.uid  else { return }
            if postDetailData?.authorUID == currentUserUID {
                //?????? - ??? ?????????
                let numberOfImages = postDetailData?.postImageURL.count
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "??????", style: .destructive, handler: { action in
                    let alert2 = UIAlertController(title: "????????? ?????????????????????????", message: nil, preferredStyle: .actionSheet)
                    alert2.addAction(UIAlertAction(title: "??????", style: .destructive, handler: { action in
                        PostManager.shared.removeMyPost(postID: self.postDetailData?.postID ?? "", authorUID: self.postDetailData?.authorUID ?? "", numberOfImages: numberOfImages ?? 0) { result in
                            switch result {
                            case .success(()):
                                self.navigationController?.popViewController(animated: true)
                                NotificationCenter.default.post(name: MyWinesViewController.uploadUpdateDelete, object: nil)
                            case .failure(let error):
                                let alert3 = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
                                alert3.addAction(UIAlertAction(title: "??????", style: .default, handler: nil))
                                self.present(alert3, animated: true)
                            }
                        }
                    }))
                    alert2.addAction(UIAlertAction(title: "??????", style: .cancel, handler: nil))
                    self.present(alert2, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "??????", style: .default, handler: { action in
                    let storyboard = UIStoryboard(name: "TastingNotes", bundle: nil)
                    let addTastingNoteNav = storyboard.instantiateViewController(identifier: "AddTastingNoteNav")
                    addTastingNoteNav.modalPresentationStyle = .fullScreen
                    let addTastingNoteTVC = addTastingNoteNav.children.first as! AddTastingNoteTableViewController
                    addTastingNoteTVC.postID = self.postDetailData?.postID
                    self.present(addTastingNoteNav, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "??????", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                //?????? - ?????? ?????? ?????????
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "????????????", style: .destructive, handler: { action in
                    let alert2 = UIAlertController(title: "???????????? ?????????????????????????\n????????? ???????????? ?????? ??? ????????? ??? ????????? ????????? ????????? ???????????? ????????? ????????? ??? ????????????.", message: nil, preferredStyle: .actionSheet)
                    alert2.addAction(UIAlertAction(title: "??????", style: .destructive, handler: { [weak self] action in
                        guard let self = self else { return }
                        guard let post = self.postDetailData else { return }
                        PostManager.shared.checkIfReportedPost(postID: post.postID, authorUID: post.authorUID, completion: { result in
                            switch result {
                            case true:
                                let alert3 = UIAlertController(title: "?????? ????????? ????????? ??????????????????.", message: nil, preferredStyle: .alert)
                                alert3.addAction(UIAlertAction(title: "??????", style: .default, handler: {_ in
                                    self.delegate?.userDidReport()
                                    self.navigationController?.popToRootViewController(animated: true)
                                }))
                                self.present(alert3, animated: true, completion: nil)
                            case false:
                                PostManager.shared.reportPost(postID: post.postID, authorUID: post.authorUID, currentUserUID: currentUserUID, completion: { result in
                                    switch result {
                                    case .failure(let error):
                                        print(error)
                                    case .success(()):
                                        let alert4 = UIAlertController(title: "????????? ?????????????????????.", message: nil, preferredStyle: .alert)
                                        alert4.addAction(UIAlertAction(title: "??????", style: .default, handler: {_ in
                                            self.delegate?.userDidReport()
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }))
                                        self.present(alert4, animated: true, completion: nil)
                                    }
                                })
                            }
                        })
                    }))
                    alert2.addAction(UIAlertAction(title: "??????", style: .cancel, handler: nil))
                    self.present(alert2, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "??????", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func handleWineInfoTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Community", bundle: nil)
        if let wineVC = storyboard.instantiateViewController(withIdentifier: "WineDetailController") as? WineDetailController {
            if let note = noteDetailData {
                wineVC.viewModel = WineDetailVM(note)
                presentPanModal(wineVC)
            } else if let post = postDetailData {
                wineVC.viewModel = WineDetailVM(post)
                presentPanModal(wineVC)
            }
        }
    }
    
    @IBAction func handleCommentTapped(_ sender: Any) {
        guard Auth.auth().currentUser != nil else { return }
        guard let post = postDetailData else { return }
        let storyboard = UIStoryboard(name: "Community", bundle: nil)
        if let commentVC = storyboard.instantiateViewController(withIdentifier: "CommentDetailController") as? CommentDetailController {
            commentVC.post = post
            presentPanModal(commentVC)
        }
    }
    
    @IBAction func pageControlTapped(_ sender: UIPageControl) {
        let page: Int? = sender.currentPage
        var frame: CGRect = self.postCollection.frame
        frame.origin.x = frame.size.width * CGFloat(page ?? 0)
        frame.origin.y = 0
        postCollection.scrollRectToVisible(frame, animated: true)
    }
}

extension PostDetail {
    @IBAction func handleHeartTapped(_ sender: Any) {
        guard let postUID = postDetailData?.postID, let authorUID = postDetailData?.authorUID else {
            debugPrint("Unable to identify post UID")
            return
        }
        
        let task = likesPost ? PostManager.shared.unlike : PostManager.shared.like
        task(postUID, authorUID) { result in
        }
    }
    
    func updateLikes() {
        guard let postUID = postDetailData?.postID else { return }
        
        PostManager.shared.likesPost(postUID: postUID) { result in
            switch result {
            case .success(let likes):
                self.likesPost = likes
                let image = likes ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
                self.heartButton.setImage(image, for: .normal)
                
                PostManager.shared.fetchLikes(postUID: postUID) { result in
                    switch result {
                    case .success(let likes):
                        self.likeLabel.text = "\(likes.count)"
                    default:
                        debugPrint("Failed to fetch likes")
                    }
                }
                
            case .failure(let err):
                debugPrint(err.localizedDescription)
            }
        }
    }
}

extension PostDetail {
    func updateComments() {
        guard let postID = postDetailData?.postID,
              postDetailData?.commentCount ?? 0 > 0 else { return }
        PostManager.shared.fetchFirstComment(postID: postID) { [weak self] comment in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if comment.isReported == true || comment.nickname.isEmpty {
                    self.commentLabel.text = "??? ??? ?????? ?????????"
                    self.commentLabel.font = UIFont.boldSystemFont(ofSize: 16)
                    self.commentProfileImageView.image = profileImagePlaceholder
                    self.commentProfileImageView.backgroundColor = UIColor(named: "ThatWineColor")
                } else {
                    let attributedString = NSMutableAttributedString(string: "\(comment.nickname) ", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
                    attributedString.append(NSAttributedString(string: comment.text, attributes: [.font: UIFont.systemFont(ofSize: 16)]))
                    self.commentLabel.attributedText = attributedString
                    self.commentProfileImageView.kf.setImage(with: comment.profileImageUrl, placeholder: profileImagePlaceholder)
                    self.commentProfileImageView.backgroundColor = UIColor(named: "ThatWineColor")
                }
            }
        }
    }
}

//show User Profile
extension PostDetail {
    func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(showUserProfile))
        detailProfile.isUserInteractionEnabled = true
        detailProfile.addGestureRecognizer(tap)
    }
    
    @objc func showUserProfile() {
        navigationItem.backButtonTitle = ""
        let storyboard = UIStoryboard(name: "MyWines", bundle: nil)
        let myWinesVC = storyboard.instantiateViewController(identifier: "MyWinesVC") as! MyWinesViewController
        myWinesVC.anotherUserUid = postDetailData?.authorUID
        navigationController?.pushViewController(myWinesVC, animated: true)
    }
}

extension PostDetail: UICollectionViewDelegate,  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postDetailVM?.imageCount ?? 0
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.pointee.x / view.frame.width)
        self.pageControl.currentPage = page
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postCell = postCollection.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        if let imageURLs = postDetailVM?.postImageUrls {
            let imageURL = imageURLs[indexPath.row]
            postCell.postImage.kf.setImage(with: imageURL)
        } else if let images = postDetailVM?.postImages {
            postCell.postImage.image = images[indexPath.row]
        }
        return postCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: postCollection.frame.width, height: postCollection.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
