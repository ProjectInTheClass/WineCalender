//
//  MyWinesTableViewController.swift
//  WineCalender
//
//  Created by GnoJng on 8/6/21.
//

import UIKit
import FirebaseAuth
import Kingfisher

class MyWinesViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var myWinesHeaderVM: MyWinesHeaderViewModel? = nil {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var posts = [Post]()
    lazy var notes = [WineTastingNote]()
    
    lazy var selectedCells = [Int:Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustCollectionViewTopAnchor()
        setUploadNotiObserver()
        
        if Auth.auth().currentUser != nil {
            updateMemberUI()
        } else {
            updateNonmemberUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "blackAndWhite")!]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
    }
    
    func adjustCollectionViewTopAnchor() {
        let window = UIApplication.shared.windows.first{ $0.isKeyWindow }
        let statusbarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        let navigationbarHeight = self.navigationController?.navigationBar.frame.height ?? 0

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: -(statusbarHeight+navigationbarHeight)).isActive = true
    }
    
    func setUploadNotiObserver() {
        NotificationCenter.default.addObserver(forName: AddTastingNoteTableViewController.uploadPost, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            if Auth.auth().currentUser != nil {
                self?.updateMemberUI()
            } else {
                self?.updateNonmemberUI()
            }
        }
    }

    //로그인, 회원가입, 회원이 앱 실행할 때, 회원이 글 쓸 때
    func updateMemberUI() {
        PostManager.shared.fetchMyPosts { myPosts in
            if let myPosts = myPosts {
                self.posts = myPosts
                let numberOfPosts = self.posts.count
                AuthenticationManager.shared.fetchMyProfile { user in
                    self.myWinesHeaderVM = MyWinesHeaderViewModel(user: user, posts: numberOfPosts)
                }
            } else {
                AuthenticationManager.shared.fetchMyProfile { user in
                    self.myWinesHeaderVM = MyWinesHeaderViewModel(user: user, posts: 0)
                }
            }
        }
    }
    
    //로그아웃, 비회원이 앱 실행할 때, 비회원이 글 쓸 때
    func updateNonmemberUI() {
        DataManager.shared.fetchWineTastingNote { myNotes in
            self.notes = myNotes
            let numberOfNotes = self.notes.count
            self.myWinesHeaderVM = MyWinesHeaderViewModel(user: nil, posts: numberOfNotes)
        }
    }

    //프로필 수정 후
    func fetchMyProfile() {
        AuthenticationManager.shared.fetchMyProfile { user in
            let numberOfPosts = self.posts.count
            self.myWinesHeaderVM = MyWinesHeaderViewModel(user: user, posts: numberOfPosts)
        }
    }
    
//    @IBAction func moreButtonTapped(_ sender: UIButton) {
//        let superview = sender.superview?.superview?.superview?.superview
//
//        guard let cell = superview as? MyWinesCollectionViewCell else { return }
//        guard let indexPath = collectionView.indexPath(for: cell) else { return }
//        print(indexPath.row)
//
//        let storyboard = UIStoryboard(name: "Community", bundle: nil)
//        let postDetailVC = storyboard.instantiateViewController(identifier: "PostDetail") as! PostDetail
//
//        if Auth.auth().currentUser != nil {
//            postDetailVC.postDetailData = posts[indexPath.row]
//        } else {
//            postDetailVC.noteDetailData = notes[indexPath.row]
//        }
//
//        self.navigationController?.pushViewController(postDetailVC, animated: true)
//    }

    @objc func handleSwipe(gestureRecognizer: UISwipeGestureRecognizer) {
        let point = gestureRecognizer.location(in: collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: point) {
            let cell = collectionView.cellForItem(at: indexPath) as! MyWinesCollectionViewCell
            
            if gestureRecognizer.direction == .right {
                UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            } else if gestureRecognizer.direction == .left {
                UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromRight, animations: nil, completion: nil)
            }
            
            if cell.imageView.alpha == 1.0 {
                self.selectedCells[indexPath.item] = indexPath.item
                cell.imageView.alpha = 0.3
                cell.imageView.layer.cornerRadius = 10
                cell.wineStackView.isHidden = false
                cell.likesComentsStackView.isHidden = false
                cell.imageViewTopAnchor.constant = 10
                cell.imageViewLeadingAnchor.constant = 10
                cell.imageViewTrailingAnchor.constant = 10
                cell.imageViewBottomAnchor.constant = 10
            } else {
                self.selectedCells[indexPath.item] = nil
                cell.imageView.alpha = 1.0
                cell.imageView.layer.cornerRadius = 0
                cell.wineStackView.isHidden = true
                cell.likesComentsStackView.isHidden = true
                cell.imageViewTopAnchor.constant = 0
                cell.imageViewLeadingAnchor.constant = 0
                cell.imageViewTrailingAnchor.constant = 0
                cell.imageViewBottomAnchor.constant = 0
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MyWinesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if Auth.auth().currentUser != nil {
            return posts.count
        } else {
            return notes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWinesCell", for: indexPath) as! MyWinesCollectionViewCell
        
        cell.backView.backgroundColor = UIColor(named: "postCard\(indexPath.item % 5)")
        
        //셀재사용으로 인해 UI적용에 문제가 있어서 셀이 선택됐는지 확인 후 UI적용
        if self.selectedCells[indexPath.item] == indexPath.item {
            cell.imageView.alpha = 0.3
            cell.imageView.layer.cornerRadius = 10
            cell.wineStackView.isHidden = false
            cell.likesComentsStackView.isHidden = false
            cell.imageViewTopAnchor.constant = 10
            cell.imageViewLeadingAnchor.constant = 10
            cell.imageViewTrailingAnchor.constant = 10
            cell.imageViewBottomAnchor.constant = 10
        } else {
            cell.imageView.alpha = 1.0
            cell.imageView.layer.cornerRadius = 0
            cell.wineStackView.isHidden = true
            cell.likesComentsStackView.isHidden = true
            cell.imageViewTopAnchor.constant = 0
            cell.imageViewLeadingAnchor.constant = 0
            cell.imageViewTrailingAnchor.constant = 0
            cell.imageViewBottomAnchor.constant = 0
        }
        
        if Auth.auth().currentUser != nil {
            cell.post = posts[indexPath.row]
        } else {
            cell.note = notes[indexPath.row]
        }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gestureRecognizer:)))
        swipeRight.delegate = self
        swipeRight.delaysTouchesBegan = true
        swipeRight.direction = .right
        cell.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gestureRecognizer:)))
        swipeLeft.delegate = self
        swipeLeft.delaysTouchesBegan = true
        swipeLeft.direction = .left
        cell.addGestureRecognizer(swipeLeft)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = 2
        let spacing: CGFloat = 2
        let width = (collectionView.bounds.width - margin * 2 - spacing) / 2
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath) as! MyWinesHeaderView
        headerView.introductionLabel.text = myWinesHeaderVM?.introduction

        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MyWinesCollectionViewCell
        let cellColor = cell.backView.backgroundColor
        
        let storyboard = UIStoryboard(name: "Community", bundle: nil)
        let postDetailVC = storyboard.instantiateViewController(identifier: "PostDetail") as! PostDetail
        
        if Auth.auth().currentUser != nil {
            postDetailVC.postDetailData = posts[indexPath.row]
            postDetailVC.postDetailVM = PostDetailVM(posts[indexPath.row], myWinesHeaderVM!.nickname, myWinesHeaderVM?.profileImageURL, cellColor ?? .white)
        } else {
            postDetailVC.noteDetailData = notes[indexPath.row]
//            postDetailVC.postDetailVM = PostDetailVM(notes[indexPath.row], myWinesHeaderVM!.nickname, nil, cellColor ?? .white)
        }
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MyWinesHeaderView", for: indexPath) as! MyWinesHeaderView
        
        self.navigationItem.title = self.myWinesHeaderVM?.nickname
        
        guard let vm = self.myWinesHeaderVM else { return headerView }
        headerView.update(vm: vm)
        
        return headerView
    }
}
