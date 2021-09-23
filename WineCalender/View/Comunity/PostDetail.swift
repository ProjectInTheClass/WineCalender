//
//  ComuDetailVC.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/08/16.
//

import Foundation
import UIKit

class PostDetail : UIViewController,UIGestureRecognizerDelegate{
    @IBOutlet weak var detailProfile: UIImageView!
    @IBOutlet weak var postCollection: UICollectionView!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var wineName: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    var postDetailData : Post!
    
    var currentCellIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var postDetailVM : PostDetailVM?{
            didSet{
                updateView()
            }
        }
        func updateView(){
            guard let vm = postDetailVM else { return }
            
            postCollection.delegate = self
            postCollection.dataSource = self

            wineName.text = vm.wineName
            
            detailProfile.image = UIImage(named: "AppIcon")
            detailProfile.layer.cornerRadius = detailProfile.frame.height/2
            detailProfile.layer.borderWidth = 0.1
            detailProfile.layer.borderColor = UIColor.lightGray.cgColor
        }
        
    }
}

extension PostDetail : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout  {
    func MoveToNextIndex(){
        currentCellIndex += 1
        postCollection.scrollToItem(at: IndexPath(item: currentCellIndex, section: 0), at: .centeredHorizontally, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        postDetailData?.postImageURL.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let postCell = postCollection.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCollectionViewCell else {fatalError("no matched articleTableViewCell identifier")}
//        postCell.postImage = UIImageView(named: postDetailData.postImageURL)
        return postCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: postCollection.frame.width, height: postCollection.frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
