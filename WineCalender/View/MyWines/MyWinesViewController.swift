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
    lazy var user: User? = nil
    lazy var posts = [Post]()
    lazy var notes = [WineTastingNote]()
    lazy var noPosts: Bool? = nil
    lazy var insideoutCells = [Int:Int]()
    
    var lastFetchedValue: String? = nil
    var fetchingMore = false
    var endReached = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adjustCollectionViewTopAnchor()
        uploadUpdateDeleteNotiObserver()
        
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
    
    func uploadUpdateDeleteNotiObserver() {
        NotificationCenter.default.addObserver(forName: MyWinesViewController.uploadUpdateDelete, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            if Auth.auth().currentUser != nil {
                self?.insideoutCells = [:]
                self?.updatePosts()
            } else {
                self?.insideoutCells = [:]
                self?.updateNonmemberUI()
            }
        }
    }

    //회원가입 직후?
    func uploadNewMemberData() {
//        let activityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
//        self.view.addSubview(activityIndicatorView)
//        activityIndicatorView.frame = CGRect(x: 0, y: 185, width: self.view.bounds.width, height: 50)
//        activityIndicatorView.startAnimating()
//        PostManager.shared.uploadDatafromCoreDataToFirebase { result in
//            if result == true {
//                DataManager.shared.removeAllWineTastingNotes { result in
//                    if result == true {
//                        activityIndicatorView.stopAnimating()
//                    }
//                }
//            }
//        }
    }
    
    //로그인, 회원가입, 회원이 앱 실행할 때
    func updateMemberUI() {
        self.insideoutCells = [:]
        self.posts = []
        self.lastFetchedValue = nil
        self.endReached = false
        PostManager.shared.numberOfMyPosts(uid: Auth.auth().currentUser?.uid ?? "") { [weak self] numberOfMyPosts in
            if numberOfMyPosts == 0 {
                self?.noPosts = true
            } else {
                self?.noPosts = false
            }
            AuthenticationManager.shared.fetchMyProfile { user in
                self?.user = user
                self?.myWinesHeaderVM = MyWinesHeaderViewModel(user: user, posts: numberOfMyPosts)
            }
            self?.beginBatchFetch()
        }
    }
    
    //회원이 글 쓸 때, 삭제할 때
    func updatePosts() {
        self.insideoutCells = [:]
        self.posts = []
        self.lastFetchedValue = nil
        self.endReached = false
        PostManager.shared.numberOfMyPosts(uid: Auth.auth().currentUser?.uid ?? "") { [weak self] numberOfMyPosts in
            if numberOfMyPosts == 0 {
                self?.noPosts = true
            } else {
                self?.noPosts = false
            }
            self?.myWinesHeaderVM = MyWinesHeaderViewModel(user: self?.user, posts: numberOfMyPosts)
            self?.beginBatchFetch()
        }
    }
    
    //fetch My Posts
    func beginBatchFetch() {
        guard !fetchingMore && !endReached && Auth.auth().currentUser != nil else { return }
        fetchingMore = true
        PostManager.shared.fetchMyPosts(lastFetchedValue: self.lastFetchedValue) { newPosts in
            self.posts.append(contentsOf: newPosts)
            self.endReached = newPosts.count == 0
            self.fetchingMore = false
            self.lastFetchedValue = newPosts.last?.postID
            self.collectionView.reloadData()
        }
    }
    
    //프로필 수정 후
    func fetchMyProfile() {
        PostManager.shared.numberOfMyPosts(uid: Auth.auth().currentUser?.uid ?? "") { [weak self] numberOfMyPosts in
            AuthenticationManager.shared.fetchMyProfile { user in
                self?.user = user
                self?.myWinesHeaderVM = MyWinesHeaderViewModel(user: user, posts: numberOfMyPosts)
            }
        }
    }
    
    //로그아웃, 비회원이 앱 실행할 때, 비회원이 글 쓸 때
    func updateNonmemberUI() {
        self.insideoutCells = [:]
        DataManager.shared.fetchWineTastingNote { [weak self] myNotes in
            self?.notes = myNotes
            let numberOfNotes = self?.notes.count
            if numberOfNotes == 0 {
                self?.noPosts = true
            } else {
                self?.noPosts = false
            }
            self?.myWinesHeaderVM = MyWinesHeaderViewModel(user: nil, posts: numberOfNotes ?? 0)
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
                self.insideoutCells[indexPath.item] = indexPath.item
                cell.imageView.alpha = 0.3
                cell.imageView.layer.cornerRadius = 10
                cell.imageWhiteBackView.isHidden = false
                cell.wineStackView.isHidden = false
                cell.likesCommentsStackView.isHidden = false
                cell.imageViewTopAnchor.constant = 10
                cell.imageViewLeadingAnchor.constant = 10
                cell.imageViewTrailingAnchor.constant = 10
                cell.imageViewBottomAnchor.constant = 10
            } else {
                self.insideoutCells[indexPath.item] = nil
                cell.imageView.alpha = 1.0
                cell.imageView.layer.cornerRadius = 0
                cell.imageWhiteBackView.isHidden = true
                cell.wineStackView.isHidden = true
                cell.likesCommentsStackView.isHidden = true
                cell.imageViewTopAnchor.constant = 0
                cell.imageViewLeadingAnchor.constant = 0
                cell.imageViewTrailingAnchor.constant = 0
                cell.imageViewBottomAnchor.constant = 0
            }
        }
    }
    
    @IBAction func addTastingNoteTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "TastingNotes", bundle: nil)
        let addTastingNoteNav = storyboard.instantiateViewController(identifier: "AddTastingNoteNav")
        addTastingNoteNav.modalPresentationStyle = .fullScreen
        self.present(addTastingNoteNav, animated: true, completion: nil)
    }
    
    @IBAction func signUpAndSignInButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(identifier: "settings")
        let signInVC = storyboard.instantiateViewController(identifier: "SignInViewController")
        self.navigationController?.pushViewController(settingsVC, animated: false)
        self.navigationController?.pushViewController(signInVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MyWinesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if noPosts == true {
            return 1
        } else if Auth.auth().currentUser == nil {
            return notes.count
        } else if Auth.auth().currentUser != nil {
            return posts.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let noPostsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWinesNoPostsCell", for: indexPath) as! MyWinesNoPostsCell
        
        if noPosts == true {
            if Auth.auth().currentUser == nil {
                noPostsCell.isMember = false
            } else {
                noPostsCell.isMember = true
            }
            noPostsCell.isHidden = false
            
            return noPostsCell
        } else {
            noPostsCell.isHidden = true
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWinesCell", for: indexPath) as! MyWinesCollectionViewCell
            
            cell.backColorView.backgroundColor = UIColor(named: "postCard\(indexPath.item % 5)")
            
            //셀재사용으로 인해 UI적용에 문제가 있어서 셀이 선택됐는지 확인 후 UI적용
            if self.insideoutCells[indexPath.item] == indexPath.item {
                cell.imageView.alpha = 0.3
                cell.imageView.layer.cornerRadius = 10
                cell.imageWhiteBackView.isHidden = false
                cell.wineStackView.isHidden = false
                cell.likesCommentsStackView.isHidden = false
                cell.imageViewTopAnchor.constant = 10
                cell.imageViewLeadingAnchor.constant = 10
                cell.imageViewTrailingAnchor.constant = 10
                cell.imageViewBottomAnchor.constant = 10
            } else {
                cell.imageView.alpha = 1.0
                cell.imageView.layer.cornerRadius = 0
                cell.imageWhiteBackView.isHidden = true
                cell.wineStackView.isHidden = true
                cell.likesCommentsStackView.isHidden = true
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
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if noPosts == true {
            let margin: CGFloat = 30
            let width = collectionView.bounds.width - margin * 2
            let height = width
            
            return CGSize(width: width, height: height)
        } else {
            let margin: CGFloat = 2
            let spacing: CGFloat = 2
            let width = (collectionView.bounds.width - margin * 2 - spacing) / 2
            let height = width
            
            return CGSize(width: width, height: height)
        }
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
        guard let cell = collectionView.cellForItem(at: indexPath) as? MyWinesCollectionViewCell else { return }
        let cellColor = cell.backColorView.backgroundColor        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > collectionView.contentSize.height - scrollView.frame.size.height - 100 {
            beginBatchFetch()
        }
    }
}

extension MyWinesViewController {
    static let uploadUpdateDelete = Notification.Name(rawValue: "uploadUpdateDelete")
}
