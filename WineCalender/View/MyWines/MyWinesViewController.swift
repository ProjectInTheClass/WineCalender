//
//  MyWinesTableViewController.swift
//  WineCalender
//
//  Created by GnoJng on 8/6/21.
//

import UIKit
import FirebaseAuth
import Kingfisher

class MyWinesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var myWinesHeaderVM: MyWinesHeaderViewModel? = nil {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var posts = [Post]()
    lazy var notes = [WineTastingNote]()
    
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
        NotificationCenter.default.addObserver(forName: AddTastingNoteViewController.uploadPost, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
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
        
//        cell.label1.isHidden = true
//        cell.label2.isHidden = true
//        cell.label3.isHidden = true
//        cell.moreButton.isHidden = true
        cell.wineStackView.isHidden = true
        cell.likesComentsStackView.isHidden = true
        cell.imageView.alpha = 1.0
        //cell.backView.backgroundColor = postCardColorSet[indexPath.item % postCardColorSet.count]
        cell.backView.backgroundColor = UIColor(named: "postCard\(indexPath.item % 5)")
        
        if Auth.auth().currentUser != nil {
            cell.post = posts[indexPath.row]
        } else {
            cell.note = notes[indexPath.row]
        }
        
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

        //imageView constraint
        let imageViewTopAnchor = cell.imageView.topAnchor.constraint(equalTo: cell.imageView.superview!.topAnchor)
        imageViewTopAnchor.priority = UILayoutPriority(999)
        let imageViewSelectedTopAnchor = cell.imageView.topAnchor.constraint(equalTo: cell.imageView.superview!.topAnchor, constant: 10)
        imageViewSelectedTopAnchor.priority = UILayoutPriority(999)
        
        let imageViewLeadingAnchor = cell.imageView.leadingAnchor.constraint(equalTo: cell.imageView.superview!.leadingAnchor)
        imageViewLeadingAnchor.priority = UILayoutPriority(999)
        let imageViewSelectedLeadingAnchor = cell.imageView.leadingAnchor.constraint(equalTo: cell.imageView.superview!.leadingAnchor, constant: 22)
        imageViewSelectedLeadingAnchor.priority = UILayoutPriority(999)
        
        let imageViewBottomAnchor = cell.imageView.bottomAnchor.constraint(equalTo: cell.imageView.superview!.bottomAnchor)
        imageViewBottomAnchor.priority = UILayoutPriority(999)
        let imageViewSelectedBottomAnchor = cell.imageView.bottomAnchor.constraint(equalTo: cell.imageView.superview!.bottomAnchor, constant: -34)
        imageViewSelectedBottomAnchor.priority = UILayoutPriority(999)
        
        if cell.imageView.alpha == 1.0 {
            UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            cell.imageView.alpha = 0.3
            cell.imageView.layer.cornerRadius = 10
            cell.wineStackView.isHidden = false
            cell.likesComentsStackView.isHidden = false
            
            imageViewTopAnchor.isActive = false
            imageViewLeadingAnchor.isActive = false
            imageViewBottomAnchor.isActive = false
            imageViewSelectedTopAnchor.isActive = true
            imageViewSelectedLeadingAnchor.isActive = true
            imageViewSelectedBottomAnchor.isActive = true
        } else {
            UIView.transition(with: cell, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
            cell.imageView.alpha = 1.0
            cell.imageView.layer.cornerRadius = 0
            cell.wineStackView.isHidden = true
            cell.likesComentsStackView.isHidden = true
            
            imageViewSelectedTopAnchor.isActive = false
            imageViewSelectedLeadingAnchor.isActive = false
            imageViewSelectedBottomAnchor.isActive = false
            imageViewTopAnchor.isActive = true
            imageViewLeadingAnchor.isActive = true
            imageViewBottomAnchor.isActive = true
            
            let storyboard = UIStoryboard(name: "Community", bundle: nil)
            let postDetailVC = storyboard.instantiateViewController(identifier: "PostDetail") as! PostDetail

            if Auth.auth().currentUser != nil {
                postDetailVC.postDetailData = posts[indexPath.row]
            } else {
                postDetailVC.noteDetailData = notes[indexPath.row]
            }
            self.navigationController?.pushViewController(postDetailVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MyWinesHeaderView", for: indexPath) as! MyWinesHeaderView
        
        self.navigationItem.title = self.myWinesHeaderVM?.nickname
        
        guard let vm = self.myWinesHeaderVM else { return headerView }
        headerView.update(vm: vm)
        
        return headerView
    }
}
