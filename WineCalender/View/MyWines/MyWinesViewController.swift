//
//  MyWinesTableViewController.swift
//  WineCalender
//
//  Created by GnoJng on 8/6/21.
//

import UIKit
import FirebaseAuth
import Kingfisher
import Lottie

class MyWinesViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
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
    lazy var insideoutCellsInSectionZero = [Int:Int]()
    lazy var insideoutCellsInSectionTwo = [Int:Int]()
    
    lazy var lastFetchedValue: String? = nil
    lazy var fetchingMore = false
    lazy var endReached = false
    
    let loadingAnimationView: AnimationView = {
        let aniView = AnimationView(name: "loading")
        aniView.contentMode = .scaleAspectFill
        aniView.loopMode = .loop
        aniView.layer.cornerRadius = 50
        return aniView
    }()
    lazy var isLoadingAnimationPlaying = false
    
    var anotherUserUid: String? = nil
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "MyWinesFooterView")
        
        uploadUpdateDeleteNotiObserver()
        
        if anotherUserUid == nil {
            if Auth.auth().currentUser != nil {
                configureMemberUI()
            } else {
                configureNonmemberUI()
            }
        } else {
            configureAnotherUserUI()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        let addButton = TabBarController.addButton
        addButton.isHidden = false
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if collectionView.contentOffset.y == 0 {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        }
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        
        if anotherUserUid == nil {
            authListener()
        }
        
        isLoadingAnimationPlaying ? loadingAnimationPlay() : loadingAnimationStop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: MyWinesViewController.uploadUpdateDelete, object: nil)
    }
    
    // MARK: - Helpers
    
    func uploadUpdateDeleteNotiObserver() {
        NotificationCenter.default.addObserver(forName: MyWinesViewController.uploadUpdateDelete, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            if Auth.auth().currentUser != nil {
                self?.updatePosts()
                self?.fetchTastingNotes()
            } else {
                self?.configureNonmemberUI()
            }
        }
    }
    
    func authListener() {
        AuthenticationManager.shared.authListener { [weak self] result in
            switch result {
            case .success(_):
                return
            case .failure(let error):
                if error == AuthError.userTokenExpired {
                    self?.configureNonmemberUI()
                    let alert = UIAlertController(title: nil, message: error.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default) { done in
                        self?.signUpAndSignInButtonTapped(nil)
                    })
                    self?.present(alert, animated: true, completion: nil)
                } else if error == AuthError.failedToConnectToNetwork || error == AuthError.unknown {
                    let alert = UIAlertController(title: nil, message: error.message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                } else if error == AuthError.nonmember {
                    self?.configureNonmemberUI()
                }
            }
        }
    }
    
    func resetProperties() {
        insideoutCellsInSectionZero = [:]
        insideoutCellsInSectionTwo = [:]
        posts = []
        lastFetchedValue = nil
        endReached = false
    }

    //회원가입 직후
    func configureNewMemberUI() {
        AuthenticationManager.shared.fetchMyProfile { [weak self] result in
            switch result {
            case .success(let user):
                self?.user = user
                self?.myWinesHeaderVM = MyWinesHeaderViewModel(user: user, posts: 0)
                self?.noPosts = true
            case .failure(let error):
                if error == AuthError.failedToFetchMyProfile {
                    self?.moveToEditProfileVC(error: error)
                }
            }
        }
    }
    
    //로그인, 회원이 앱 실행할 때
    func configureMemberUI() {
        resetProperties()
        loadingAnimationPlay()
        PostManager.shared.numberOfMyPosts(uid: Auth.auth().currentUser?.uid ?? "") { [weak self] numberOfMyPosts in
            if numberOfMyPosts == 0 {
                self?.noPosts = true
            } else {
                self?.noPosts = false
            }
            AuthenticationManager.shared.fetchMyProfile { result in
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.myWinesHeaderVM = MyWinesHeaderViewModel(user: user, posts: numberOfMyPosts)
                case .failure(let error):
                    if error == AuthError.failedToFetchMyProfile {
                        self?.moveToEditProfileVC(error: error)
                    }
                }
            }
        }
        beginBatchFetch()
        
        fetchTastingNotes()
    }
    
    //회원 - 공유하지 않은 게시물 불러오기
    func fetchTastingNotes() {
        DataManager.shared.fetchWineTastingNote { [weak self] notes in
            self?.notes = notes
        }
    }
    
    //회원이 글 쓸 때, 삭제할 때
    func updatePosts() {
        resetProperties()
        PostManager.shared.numberOfMyPosts(uid: Auth.auth().currentUser?.uid ?? "") { [weak self] numberOfMyPosts in
            if numberOfMyPosts == 0 {
                self?.noPosts = true
            } else {
                self?.noPosts = false
            }
            self?.myWinesHeaderVM = MyWinesHeaderViewModel(user: self?.user ?? User(uid: "", email: "", profileImageURL: nil, nickname: "", introduction: nil), posts: numberOfMyPosts)
            self?.beginBatchFetch()
        }
    }
    
    //fetch My Posts
    func beginBatchFetch() {
        guard !fetchingMore && !endReached else { return }
        var uid: String = ""
        
        if let anotherUserUid = anotherUserUid {
            uid = anotherUserUid
        } else {
            guard let currentUid = Auth.auth().currentUser?.uid else { return }
            uid = currentUid
        }
        
        fetchingMore = true
        loadingAnimationPlay()
        
        PostManager.shared.fetchMyPosts(uid: uid, lastFetchedValue: self.lastFetchedValue) { [weak self] newPosts in
            if let newPosts = newPosts {
                self?.posts.append(contentsOf: newPosts)
                self?.lastFetchedValue = newPosts.last?.postID
            } else {
                self?.endReached = true
            }
            self?.fetchingMore = false
            self?.loadingAnimationStop()
            self?.collectionView.reloadData()
        }
    }
    
    //프로필 수정 후
    func fetchMyProfile() {
        PostManager.shared.numberOfMyPosts(uid: Auth.auth().currentUser?.uid ?? "") { [weak self] numberOfMyPosts in
            AuthenticationManager.shared.fetchMyProfile { result in
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.myWinesHeaderVM = MyWinesHeaderViewModel(user: user, posts: numberOfMyPosts)
                case .failure(let error):
                    if error == AuthError.failedToFetchMyProfile {
                        self?.moveToEditProfileVC(error: error)
                    }
                }
            }
        }
    }
    
    func moveToEditProfileVC(error: AuthError) {
        let alert = UIAlertController(title: nil, message: error.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let settingsVC = storyboard.instantiateViewController(identifier: "settings")
            let editProfileVC = storyboard.instantiateViewController(identifier: "EditProfileViewController")
            self.navigationController?.pushViewController(settingsVC, animated: false)
            self.navigationController?.pushViewController(editProfileVC, animated: true)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    //로그아웃, 탈퇴
    func signOutUI() {
        user = nil
        posts = []
        self.insideoutCellsInSectionTwo = [:]
        configureNonmemberUI()
    }
    
    //비회원이 앱 실행할 때, 비회원이 글 쓸 때
    func configureNonmemberUI() {
        self.insideoutCellsInSectionZero = [:]
        DataManager.shared.fetchWineTastingNote { [weak self] myNotes in
            self?.notes = myNotes
            let numberOfNotes = self?.notes.count
            if numberOfNotes == 0 {
                self?.noPosts = true
            } else {
                self?.noPosts = false
            }
            self?.myWinesHeaderVM = MyWinesHeaderViewModel(user: User(uid: "", email: "", profileImageURL: nil, nickname: "비회원", introduction: nil), posts: numberOfNotes ?? 0)
        }
    }
    
    //다른 유저
    func configureAnotherUserUI() {
        navigationItem.rightBarButtonItems = []
        
        resetProperties()
        loadingAnimationPlay()
        
        guard let uid = anotherUserUid else { return }
        
        PostManager.shared.numberOfMyPosts(uid: uid) { [weak self] numberOfMyPosts in
            AuthenticationManager.shared.fetchAnotherUserProfile(uid: uid) { url, nickname, introduction in
                let anotherUser = User(uid: uid, email: "", profileImageURL: url, nickname: nickname, introduction: introduction)
                self?.user = anotherUser
                self?.myWinesHeaderVM = MyWinesHeaderViewModel(user: anotherUser, posts: numberOfMyPosts)
               
            }
        }
        
        beginBatchFetch()
    }
    
    func loadingAnimationPlay() {
        isLoadingAnimationPlaying = true
        loadingAnimationView.play()
    }
    
    func loadingAnimationStop() {
        loadingAnimationView.stop()
        loadingAnimationView.removeFromSuperview()
        isLoadingAnimationPlaying = false
    }
    
    // MARK: - Actions

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
                if indexPath.section == 0 {
                    self.insideoutCellsInSectionZero[indexPath.item] = indexPath.item
                } else {
                    self.insideoutCellsInSectionTwo[indexPath.item] = indexPath.item
                }
                cell.configureInsideoutCell()
            } else {
                if indexPath.section == 0 {
                    self.insideoutCellsInSectionZero[indexPath.item] = nil
                } else {
                    self.insideoutCellsInSectionTwo[indexPath.item] = nil
                }
                cell.prepareForReuse()
            }
        }
    }
    
    @IBAction func addTastingNoteTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "TastingNotes", bundle: nil)
        let addTastingNoteNav = storyboard.instantiateViewController(identifier: "AddTastingNoteNav")
        addTastingNoteNav.modalPresentationStyle = .fullScreen
        self.present(addTastingNoteNav, animated: true, completion: nil)
    }
    
    @IBAction func signUpAndSignInButtonTapped(_ sender: UIButton?) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(identifier: "settings")
        let signInVC = storyboard.instantiateViewController(identifier: "SignInViewController")
        self.navigationController?.pushViewController(settingsVC, animated: false)
        self.navigationController?.pushViewController(signInVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension MyWinesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if anotherUserUid != nil {
            return 1
        } else {
            if Auth.auth().currentUser == nil {
                return 1
            } else if noPosts == true && notes.isEmpty {
                return 1
            } else if noPosts == true && !notes.isEmpty {
                return 3
            } else if noPosts == false && notes.isEmpty {
                return 1
            } else {
                return 3
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if anotherUserUid != nil {
            return posts.count
        } else {
            if noPosts == true && section == 0 {
                return 1
            } else if Auth.auth().currentUser == nil {
                return notes.count
            } else if Auth.auth().currentUser != nil && section == 0 {
                return posts.count
            } else if Auth.auth().currentUser != nil && section == 1 && !notes.isEmpty {
                return 1
            } else if Auth.auth().currentUser != nil && section == 2 && !notes.isEmpty {
                return notes.count
            } else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myWinesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWinesCell", for: indexPath) as! MyWinesCollectionViewCell
        
        myWinesCell.backColorView.backgroundColor = UIColor(named: "postCard\(indexPath.item % 5)")
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gestureRecognizer:)))
        swipeRight.delegate = self
        swipeRight.delaysTouchesBegan = true
        swipeRight.direction = .right
        myWinesCell.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(gestureRecognizer:)))
        swipeLeft.delegate = self
        swipeLeft.delaysTouchesBegan = true
        swipeLeft.direction = .left
        myWinesCell.addGestureRecognizer(swipeLeft)
        
        if indexPath.section == 0 {
            let noPostsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWinesNoPostsCell", for: indexPath) as! MyWinesNoPostsCell
            if anotherUserUid != nil {
                if self.insideoutCellsInSectionZero[indexPath.item] == indexPath.item {
                    myWinesCell.configureInsideoutCell()
                } else {
                    myWinesCell.prepareForReuse()
                }
                myWinesCell.post = posts[indexPath.row]
                
                return myWinesCell
            } else if noPosts == true {
                if Auth.auth().currentUser == nil {
                    noPostsCell.isMember = false
                } else {
                    noPostsCell.isMember = true
                }
                noPostsCell.isHidden = false
                
                return noPostsCell
            } else {
                noPostsCell.isHidden = true
                
                //셀재사용으로 인해 UI적용에 문제가 있어서 셀이 선택됐는지 확인 후 UI적용
                if self.insideoutCellsInSectionZero[indexPath.item] == indexPath.item {
                    myWinesCell.configureInsideoutCell()
                } else {
                    myWinesCell.prepareForReuse()
                }
                
                if Auth.auth().currentUser != nil {
                    myWinesCell.post = posts[indexPath.row]
                } else {
                    myWinesCell.note = notes[indexPath.row]
                }
                
                return myWinesCell
            }
        } else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWinesNotSharedCell", for: indexPath)
            
            return cell
        } else {
            if self.insideoutCellsInSectionTwo[indexPath.item] == indexPath.item {
                myWinesCell.configureInsideoutCell()
            } else {
                myWinesCell.prepareForReuse()
            }
            
            myWinesCell.note = notes[indexPath.row]
            
            return myWinesCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = 2
        let spacing: CGFloat = 2
        let width = (collectionView.bounds.width - margin * 2 - spacing) / 2
        let height = width
        let myWinesCellSize = CGSize(width: width, height: height)
        
        if indexPath.section == 0 {
            if anotherUserUid != nil {
                return myWinesCellSize
            } else if noPosts == true {
                let margin: CGFloat = 30
                let width = collectionView.bounds.width - margin * 2
                let height = width - 70
                
                return CGSize(width: width, height: height)
            } else {
                return myWinesCellSize
            }
        } else if indexPath.section == 1 {
            let margin: CGFloat = 2
            return CGSize(width: collectionView.bounds.width - margin * 2, height: 50)
        } else {
            return myWinesCellSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            let indexPath = IndexPath(row: 0, section: section)
            let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath) as! MyWinesHeaderView
            headerView.introductionLabel.text = myWinesHeaderVM?.introduction

            return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
                                                      withHorizontalFittingPriority: .required,
                                                      verticalFittingPriority: .fittingSizeLevel)
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if isLoadingAnimationPlaying {
            if section == 0 {
                return CGSize(width: collectionView.frame.width, height: 100)
            } else {
                return CGSize.zero
            }
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MyWinesCollectionViewCell else { return }
        let cellColor = cell.backColorView.backgroundColor        
        let storyboard = UIStoryboard(name: "Community", bundle: nil)
        let postDetailVC = storyboard.instantiateViewController(identifier: "PostDetail") as! PostDetail
        
        if anotherUserUid != nil {//다른 유저
            if indexPath.section == 0 {
                postDetailVC.postDetailData = posts[indexPath.row]
                postDetailVC.postDetailVM = PostDetailVM(posts[indexPath.row], myWinesHeaderVM!.nickname, myWinesHeaderVM?.profileImageURL, cellColor ?? .white)
            }
        } else if Auth.auth().currentUser != nil {
            if indexPath.section == 0 {
                postDetailVC.postDetailData = posts[indexPath.row]
                postDetailVC.postDetailVM = PostDetailVM(posts[indexPath.row], myWinesHeaderVM!.nickname, myWinesHeaderVM?.profileImageURL, cellColor ?? .white)
            } else { //회원 - 공유하지 않은 게시물
                postDetailVC.noteDetailData = notes[indexPath.row]
                postDetailVC.postDetailVM = PostDetailVM(notes[indexPath.row], cellColor ?? .white)
            }
        } else { //비회원
            postDetailVC.noteDetailData = notes[indexPath.row]
            postDetailVC.postDetailVM = PostDetailVM(notes[indexPath.row], cellColor ?? .white)
        }
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MyWinesHeaderView", for: indexPath) as! MyWinesHeaderView

            self.navigationItem.title = self.myWinesHeaderVM?.nickname

            guard let vm = self.myWinesHeaderVM else { return headerView }
            
            if anotherUserUid != nil || Auth.auth().currentUser?.uid != nil {
                headerView.update(vm: vm, isMember: true)
            } else {
                headerView.update(vm: vm, isMember: false)
            }

            return headerView
        } else {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyWinesFooterView", for: indexPath)
           
            footerView.addSubview(loadingAnimationView)
//            animationView.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 100)
            
            loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
            
            let constraints = [
                loadingAnimationView.widthAnchor.constraint(equalToConstant: 100),
                loadingAnimationView.heightAnchor.constraint(equalToConstant: 100),
                loadingAnimationView.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
                loadingAnimationView.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
            ]
            NSLayoutConstraint.activate(constraints)

            return footerView
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 10 {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        }
        
        if scrollView.contentOffset.y > collectionView.contentSize.height - scrollView.frame.size.height - 100 {
            beginBatchFetch()
        }
    }
}

// MARK: - Notification

extension MyWinesViewController {
    static let uploadUpdateDelete = Notification.Name(rawValue: "uploadUpdateDelete")
}

// MARK: - UICollectionViewFlowLayout

final class StretchableUICollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        layoutAttributes?.forEach({ attributes in
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader {
                guard let collectionView = collectionView else { return }
                let contentOffsetY = collectionView.contentOffset.y
                if contentOffsetY > 0 {
                    return
                }
                let width = collectionView.frame.width
                let height = attributes.frame.height - contentOffsetY

                attributes.frame = CGRect(x: 0, y: contentOffsetY, width: width, height: height)
            }
        })
        return layoutAttributes
    }
}
