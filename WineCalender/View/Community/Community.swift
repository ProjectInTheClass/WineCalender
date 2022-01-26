//
//  ComuVC.swift
//  WineCalender
//
//  Created by 강재권 on 2021/07/26.
//

import Foundation
import UIKit
import Firebase
import Parchment
import Lottie


class Community : UICollectionViewController {
    
    // MARK: - Properties
    
    private let cellId = "ThumbnailCell"
    var posts = [(post: Post, username: String, profileImageUrl: URL?)]()
    
    lazy var lastFetchedValue: String? = nil
    lazy var fetchingMore = false
    lazy var endReached = false
    
    lazy var loadingAnimationView: AnimationView = {
        let aniView = AnimationView(name: "loading")
        aniView.contentMode = .scaleAspectFill
        aniView.loopMode = .loop
        aniView.layer.cornerRadius = 50
        aniView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        return aniView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: "ThumbnailCell", bundle: nil), forCellWithReuseIdentifier: cellId)

        guard let layout = collectionView.collectionViewLayout as? ZigzagLayout else { return }
        layout.contentWidth = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
        
//        setupCollectionViewInsets()
        
        fetchPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if view.subviews.contains(loadingAnimationView) {
            loadingAnimationPlay()
        }
    }
    
    // MARK: - helpers
    
    func fetchPosts() {
        beginBatchFetch { [weak self] in
            self?.fetchingMore = false
            self?.lastFetchedValue = self?.posts.last?.post.postID
            self?.loadingAnimationStop()
            self?.collectionView.reloadData()
        }
    }
        
    func beginBatchFetch(completion: @escaping () -> Void) {
        guard !fetchingMore && !endReached else { return }
        fetchingMore = true
        loadingAnimationPlay()

        let queryLimited: UInt = 6
        var queryRef: DatabaseQuery
        
        if lastFetchedValue == nil {
            queryRef = PostManager.shared.recentPostRef.queryOrdered(byChild: "postID").queryLimited(toLast: queryLimited)
        } else {
            queryRef = PostManager.shared.recentPostRef.queryOrdered(byChild: "postID").queryEnding(beforeValue: lastFetchedValue).queryLimited(toLast: queryLimited)
        }
        
        queryRef.observeSingleEvent(of: .value, with: { snapshot in
            let snashotCount = snapshot.childrenCount
            if snashotCount == 0 {
                self.endReached = true
                completion()
            }
            var fetchCount = 0 {
                didSet {
                    if snashotCount == fetchCount {
                        completion()
                    }
                }
            }
            
            for child in snapshot.children {
                let snapshot = child as! DataSnapshot
                guard let dictionary = snapshot.value as? [String:Any] else { return }

                guard let authorID = dictionary["authorID"] as? String, let postID = dictionary["postID"] as? String else { return }
                
                PostManager.shared.postRef.child(authorID).child(postID).observeSingleEvent(of: .value) { snapshot in
                    guard let d = snapshot.value as? [String : Any] else { return }
                    
                    guard let data = try? JSONSerialization.data(withJSONObject: d, options: []) else { return }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    
                    guard let post = try? decoder.decode(Post.self, from: data) else { return }
                    if let isReported = post.isReported, isReported == true {
                        fetchCount += 1
                        return
                    } else {
                        AuthenticationManager.shared.fetchUserProfile(uid: post.authorUID) { url, username in
                            self.posts.append((post,username,url))
                            self.posts.sort{ $0.post.postingDate > $1.post.postingDate }
                            fetchCount += 1
                        }
                    }
                }
            }
        })
    }
    
    func loadingAnimationPlay() {
        view.addSubview(loadingAnimationView)
        loadingAnimationView.center = view.center
        loadingAnimationView.play()
    }
    
    func loadingAnimationStop() {
        loadingAnimationView.stop()
        loadingAnimationView.removeFromSuperview()
    }
}

// MARK: - CollectionViewDataSource, CollectionViewDelegate

extension Community {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PostThumbnailCell
        let postInfo = posts[indexPath.row]
        cell.postThumbnailVM = PostThumbnailVM(postInfo.post, postInfo.username ,postInfo.profileImageUrl, indexPath.row)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Community", bundle: nil)
        let postDetail = storyboard.instantiateViewController(identifier: "PostDetail") as! PostDetail
        postDetail.delegate = self
        let row = indexPath.row
        postDetail.postDetailData = posts[row].0
        let data = posts[row]
        let cell = collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? PostThumbnailCell
        self.navigationController?.pushViewController(postDetail, animated: true)
        postDetail.postDetailVM = PostDetailVM(data.0, data.1, data.2, cell?.postThumbnailVM?.color ?? .white)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > collectionView.contentSize.height - scrollView.frame.size.height - 100 {
            fetchPosts()
        }
    }
}

// MARK: - UICollectionViewCell

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var postImage: UIImageView!
}

// MARK: - PostDetailDelegate

extension Community: PostDetailDelegate {
    func userDidReport() {
        posts = []
        lastFetchedValue = nil
        endReached = false
        fetchPosts()
    }
}
