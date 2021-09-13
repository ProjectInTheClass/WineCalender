//
//  ComuDetailVC.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/08/16.
//

import Foundation
import UIKit

class ComuDetailVC : UIViewController,UIGestureRecognizerDelegate{
    @IBOutlet weak var detailProfile: UIImageView!
    @IBOutlet weak var postCollection: UICollectionView!
    @IBOutlet weak var memoTxt: UILabel!
    @IBOutlet weak var hashTag: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var userName: UILabel!
    
    var currentCelIndex = 0
    
    var arrProductPhotos = [
            UIImage(named: "postImage01"),
            UIImage(named: "postImage02"),
            UIImage(named: "postImage03"),
            UIImage(named: "postImage04"),
            UIImage(named: "postImage05")
       ]
    var postData : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        postCollection.delegate = self
        postCollection.dataSource = self
        
        detailProfile.image = UIImage(named: "AppIcon")
        detailProfile.layer.cornerRadius = detailProfile.frame.height/2
        detailProfile.layer.borderWidth = 0.1
        detailProfile.layer.borderColor = UIColor.lightGray.cgColor
        
//        detailMainImg.image = UIImage(named: "AppIcon")
        
        memoTxt.font = UIFont.systemFont(ofSize: 16)
        
        hashTag.font = UIFont.boldSystemFont(ofSize: 13)
        
        
        followBtn.layer.cornerRadius = 5
        
    }
    @IBAction func followBtnTap(_ sender: Any) {
        
    }
    
  
}

extension ComuDetailVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {
    func MoveToNextIndex(){
        currentCelIndex += 1
        postCollection.scrollToItem(at: IndexPath(item: currentCelIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arrProductPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postCell = postCollection.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        postCell.postImage.image = arrProductPhotos[indexPath.row]
        return postCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: postCollection.frame.width, height: postCollection.frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
