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

class Community : UIViewController{
    @IBOutlet var collectionView: UICollectionView!
    
    var posts = [Post]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        PostManager.shared.postRef.queryOrdered(byChild: "postingDate").observe(DataEventType.value, with: { snapshot in
            self.posts.removeAll()
            for child in snapshot.children.reversed() {
                let snapshot = child as! DataSnapshot
                guard let dictionary = snapshot.value as? [String:Any] else { return }

//                let datas = Array(dictionary.values)
                
                guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else { return }
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                
                guard let post = try? decoder.decode(Post.self, from: data) else { return }
                
                self.posts.append(post)
//                print(posts.map({ post in
//                    post.tastingNote.wineName
//                }))
            }
            
            self.collectionView.reloadData()

        })
    }
}

extension Community : UICollectionViewDelegate,UICollectionViewDataSource {
    // 컬렉션 뷰의 마진설정
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath) as! PostThumbnailCell
        cell.postThumbnailVM = PostThumbnailVM(post: posts[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "collectionDetail", sender: collectionView.cellForItem(at: indexPath))
//            collectionView.deselectItem(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "PostDetailSeque", sender: posts[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "PostDetailSeque" , let PostDetail = segue.destination as? PostDetail else {return}
        guard let item = sender as? Post else { return }
        PostDetail.postDetailData = item
                 
    }
}

extension Community : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
        // 위 아래 간격
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
        //옆간격
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //cell 크기
        let width = collectionView.frame.width / 2 - 1
        let size = CGSize(width: width, height: 200)
        return size
    }
    
}

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var postImage: UIImageView!
}
