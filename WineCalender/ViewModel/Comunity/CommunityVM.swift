//
//  ComuVC.swift
//  WineCalender
//
//  Created by 강재권 on 2021/07/26.
//

import Foundation
import UIKit
import Parchment

struct PostData {
    var userName : String
    var profileImageName : String
    var followed : Bool
    var postText : String
    var userPostImages : [String]
    var hashTag: String?
}

class ComuVC : UIViewController{
    @IBOutlet var collectionView: UICollectionView!
    
    var posts = [PostData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}

class defaultCell : UICollectionViewCell {
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
}

extension ComuVC : UICollectionViewDelegate,UICollectionViewDataSource {
    // 컬렉션 뷰의 마진설정
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath) as! defaultCell
        
        cell.cellImage.image = UIImage(named: posts[indexPath.row].userPostImages[0])
        cell.cellImage.frame.size = CGSize(width: collectionView.frame.width / 2, height: collectionView.frame.width/2)
        cell.cellImage.layer.cornerRadius = 10
        cell.mainTitle.text = posts[indexPath.row].postText
        cell.subTitle.text = posts[indexPath.row].hashTag
        cell.profileName.text = posts[indexPath.row].userName
        cell.profileImage.image = UIImage(named: posts[indexPath.row].profileImageName)
        cell.profileImage.backgroundColor = .white
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
        cell.profileImage.layer.borderWidth = 0.1
        cell.profileImage.layer.borderColor = UIColor.lightGray.cgColor
        // 뷰의 경계에 맞춰준다
        cell.profileImage.clipsToBounds = true
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "collectionDetail", sender: collectionView.cellForItem(at: indexPath))
//            collectionView.deselectItem(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "collectionDetail", sender: posts[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "collectionDetail" , let ComuDetailVC = segue.destination as? ComuDetailVC else {return}
        guard let item = sender as? PostData else { return }
        ComuDetailVC.postData = item
                 
    }
}

extension ComuVC : UICollectionViewDelegateFlowLayout {
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
