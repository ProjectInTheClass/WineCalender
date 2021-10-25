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
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var wineName: UILabel!
    @IBOutlet weak var mainText: UILabel!
    
    var currentCelIndex = 0
    
    var postDetailData : Post?
    //nonmember
    var postDetailVM : PostDetailVM?
    
    var noteDetailData : WineTastingNote?
    
    override func viewDidLoad() {
         super.viewDidLoad()

         postCollection.delegate = self
         postCollection.dataSource = self
         
         detailProfile.image = UIImage(named: "AppIcon")
         detailProfile.layer.cornerRadius = detailProfile.frame.height/2
         detailProfile.layer.borderWidth = 3.5 
         detailProfile.layer.borderColor = UIColor.white.cgColor
        
        wineName.text = postDetailVM?.wineName
        mainText.text = postDetailVM?.memo
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
    
//    func updateView() {
//        guard let vmm = PostDetailVM else { return }
//
////        postCollection.backgroundColor =
//    }
}


extension PostDetail : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {
    func MoveToNextIndex(){
        currentCelIndex += 1
        postCollection.scrollToItem(at: IndexPath(item: currentCelIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var num = 0
        if let n = postDetailData?.postImageURL.count {
            num = n
        } else if let n = noteDetailData?.image.count {
            num = n
        }
        return num
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postCell = postCollection.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        postCell.backgroundColor = postDetailVM?.postCardColor
        
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
