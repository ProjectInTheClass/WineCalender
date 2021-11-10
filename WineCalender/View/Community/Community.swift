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



class Community : UICollectionViewController {
    private let cellId = "ThumbnailCell"
    var posts = [(post: Post, username: String, profileImageUrl: URL?)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: "ThumbnailCell", bundle: nil), forCellWithReuseIdentifier: cellId)

        guard let layout = collectionView.collectionViewLayout as? ZigzagLayout else { return }
        layout.contentWidth = collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right
        
//        setupCollectionViewInsets()
        
        PostManager.shared.recentPostRef.queryOrdered(byChild: "postedDate").queryLimited(toFirst: 10).observe(DataEventType.value, with: { snapshot in
            self.posts = []
            
            for child in snapshot.children.reversed() {
                let snapshot = child as! DataSnapshot
                guard let dictionary = snapshot.value as? [String:Any] else { return }

                guard let authorID = dictionary["authorID"] as? String, let postID = dictionary["postID"] as? String else { return }
                
                PostManager.shared.postRef.child(authorID).child(postID).observeSingleEvent(of: .value) { snapshot in
                    guard let d = snapshot.value as? [String : Any] else { return }
                    
                    guard let data = try? JSONSerialization.data(withJSONObject: d, options: []) else { return }
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    
                    guard let post = try? decoder.decode(Post.self, from: data) else { return }
                    AuthenticationManager.shared.fetchUserProfile(AuthorUID: post.authorUID) { url, username in
                        self.posts.append((post,username,url))
                        self.posts.sort{ $0.post.postingDate > $1.post.postingDate }
                        self.collectionView.reloadData()
                    }
                }
            }
            self.collectionView.reloadData()
        })
    }
}

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
        let row = indexPath.row
        postDetail.postDetailData = posts[row].0
        let data = posts[row]
        let cell = collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? PostThumbnailCell
        self.navigationController?.pushViewController(postDetail, animated: true)
        postDetail.postDetailVM = PostDetailVM(data.0, data.1, data.2, cell?.postThumbnailVM?.color ?? .white)
    }
}

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var postImage: UIImageView!
}
