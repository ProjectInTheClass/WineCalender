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

class PostDetail : UIViewController,UIGestureRecognizerDelegate{
    @IBOutlet weak var postCollection: UICollectionView!
    @IBOutlet weak var detailProfile: UIImageView!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var wineName: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    var currentCelIndex = 0
    
    var postDetailData : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postCollection.delegate = self
        postCollection.dataSource = self
        
        detailProfile.image = UIImage(named: "AppIcon")
        detailProfile.layer.cornerRadius = detailProfile.frame.height/2
        detailProfile.layer.borderWidth = 0.1
        detailProfile.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configure()
    }
    
    func configure() {
        //Fetch User Profile
        guard let authorUID = postDetailData?.authorUID else { return }
        AuthenticationManager.shared.fetchUserProfile(AuthorUID: authorUID) { imageURL, nickname in
            self.detailProfile.kf.setImage(with: imageURL, placeholder: UIImage(systemName: "person.circle.fill")!.withTintColor(.systemPurple, renderingMode: .alwaysOriginal))
            self.userName.text = nickname
        }
    }
}

extension PostDetail : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {
    func MoveToNextIndex(){
        currentCelIndex += 1
        postCollection.scrollToItem(at: IndexPath(item: currentCelIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let count = postDetailData?.postImageURL.count else { return 0 }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postCell = postCollection.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        guard let imageURL = URL(string: (postDetailData?.postImageURL[indexPath.row])!) else { return postCell }
        postCell.postImage.kf.setImage(with: imageURL)
        return postCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: postCollection.frame.width, height: postCollection.frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
