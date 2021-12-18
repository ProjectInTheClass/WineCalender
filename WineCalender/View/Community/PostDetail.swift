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
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var postUpdateTime: UILabel!
    @IBOutlet weak var producingCountryLabel: UILabel!
    @IBOutlet weak var vintageLabel: UILabel!
    
    var likesPost: Bool = false
    
    var currentCelIndex = 0
    
    var postDetailData : Post?
    //nonmember
    var postDetailVM : PostDetailVM?
    var noteDetailData : WineTastingNote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postCollection.delegate = self
        postCollection.dataSource = self
        
        guard let vm = postDetailVM else { return }
        postCollection.backgroundColor = vm.backgroundColor
        postUpdateTime.text = vm.date
        
        moreButton.isHidden = vm.isMoreButtonHidden
        heartButton.isHidden = vm.isLikeHidden
        likeLabel.isHidden = vm.isLikeHidden
        
        pageControl.numberOfPages = vm.imageCount
        mainText.text = vm.memo
        wineName.text = vm.wineName
        
        producingCountryLabel.text = vm.producingCountry
        vintageLabel.text = vm.vintage
        
        updateLikes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureMemberUI()
        configureNonmemberUI()
    }
    
    func configureMemberUI() {
        //Fetch User Profile
        guard let authorUID = postDetailData?.authorUID else { return }
        AuthenticationManager.shared.fetchUserProfile(AuthorUID: authorUID) { imageURL, nickname in
            self.detailProfile.kf.setImage(with: imageURL, placeholder: UIImage(systemName: "person.circle.fill")!.withTintColor(.systemPurple, renderingMode: .alwaysOriginal))
            self.userName.text = nickname
        }
    }
    
    func configureNonmemberUI() {
        guard let note = noteDetailData else { return }
        self.userName.text = "비회원"
        self.wineName.text = note.wineName
        self.mainText.text = note.memo
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        if let currentUserUID = Auth.auth().currentUser?.uid {
            if postDetailData?.authorUID == currentUserUID {
                //회원 - 내 글
                let numberOfImages = postDetailData?.postImageURL.count
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { action in
                    let alert2 = UIAlertController(title: "정말로 삭제하시겠습니까?", message: nil, preferredStyle: .actionSheet)
                    alert2.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { action in
                        PostManager.shared.removeMyPost(postID: self.postDetailData?.postID ?? "", authorUID: self.postDetailData?.authorUID ?? "", numberOfImages: numberOfImages ?? 0) { result in
                            switch result {
                            case .success(()):
                                self.navigationController?.popViewController(animated: true)
                                NotificationCenter.default.post(name: MyWinesViewController.uploadUpdateDelete, object: nil)
                            case .failure(let error):
                                let alert3 = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
                                alert3.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                                self.present(alert3, animated: true)
                            }
                        }
                    }))
                    alert2.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                    self.present(alert2, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "수정", style: .default, handler: { action in
                    let storyboard = UIStoryboard(name: "TastingNotes", bundle: nil)
                    let addTastingNoteNav = storyboard.instantiateViewController(identifier: "AddTastingNoteNav")
                    addTastingNoteNav.modalPresentationStyle = .fullScreen
                    let addTastingNoteTVC = addTastingNoteNav.children.first as! AddTastingNoteTableViewController
                    addTastingNoteTVC.postID = self.postDetailData?.postID
                    self.present(addTastingNoteNav, animated: true, completion: nil)
                }))
                alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                //회원 - 다른 유저 글
            }
        } else {
            //비회원 - 내 글
            guard noteDetailData != nil else { return }
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { action in
                let alert2 = UIAlertController(title: "정말로 삭제하시겠습니까?", message: nil, preferredStyle: .actionSheet)
                alert2.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { action in
                    DataManager.shared.removeWineTastingNote(wineTastingNote: self.noteDetailData)
                    self.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(name: MyWinesViewController.uploadUpdateDelete, object: nil)
                }))
                alert2.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                self.present(alert2, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "수정", style: .default, handler: { action in
                let storyboard = UIStoryboard(name: "TastingNotes", bundle: nil)
                let addTastingNoteNav = storyboard.instantiateViewController(identifier: "AddTastingNoteNav")
                addTastingNoteNav.modalPresentationStyle = .fullScreen
                let addTastingNoteTVC = addTastingNoteNav.children.first as! AddTastingNoteTableViewController
                addTastingNoteTVC.updateNote = self.noteDetailData
                self.present(addTastingNoteNav, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func handleWineInfoTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Community", bundle: nil)
        if let wineVC = storyboard.instantiateViewController(withIdentifier: "WineDetailController") as? WineDetailController,
           let note = noteDetailData {
            wineVC.viewModel = WineDetailVM(note)
            presentPanModal(wineVC)
        }
    }
    
    @IBAction func handleCommentTapped(_ sender: Any) {
        print("comment tapped")
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

extension PostDetail: UICollectionViewDelegate,  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postDetailData?.postImageURL.count ?? 0
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.pointee.x / view.frame.width)
        self.pageControl.currentPage = page
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postCell = postCollection.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        if let post = postDetailData {
            let imageURL = URL(string: (post.postImageURL[indexPath.row]))
            postCell.postImage.kf.setImage(with: imageURL)
        } else if let note = noteDetailData {
            postCell.postImage.image = note.image[indexPath.row]
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
