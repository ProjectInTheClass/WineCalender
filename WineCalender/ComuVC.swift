//
//  ComuVC.swift
//  WineCalender
//
//  Created by 강재권 on 2021/07/26.
//

import Foundation
import UIKit
import Parchment

struct UserData {
    var userName : String
    var followed : Bool
    var postText : String
}

class ComuVC : UIViewController{
    @IBOutlet var collectionView: UICollectionView!
    
    var posts:[UserData] = [
        UserData(userName: "JaeKwon", followed: false,postText: "Test 1"),
        UserData(userName: "MJ", followed: false,postText: "Test 2"),
        UserData(userName: "METAOX", followed: false,postText: "Test 3"),
        UserData(userName: "Zenn K", followed: false,postText: "Test 4"),
        UserData(userName: "JaeKwon", followed: false,postText: "Test 5"),
        UserData(userName: "MJ", followed: false,postText: "Test 6"),
        UserData(userName: "METAOX", followed: false,postText: "Test 7"),
        UserData(userName: "Zenn K", followed: false,postText: "Test 8"),
        UserData(userName: "Jaekwon", followed: false,postText: "Test 9"),
        UserData(userName: "MJ", followed: false,postText: "Test 10"),
        UserData(userName: "METAOX", followed: false,postText: "Test 11"),
        UserData(userName: "Zenn K", followed: false,postText: "Test 12"),
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath) as! defaultCell
        cell.cellImage.image = UIImage(named: "AppIcon")
        cell.cellImage.frame.size = CGSize(width: collectionView.frame.width / 2, height: collectionView.frame.width/2)
        cell.mainTitle.text = posts[indexPath.row].postText
        cell.subTitle.text = posts[indexPath.row].postText
        cell.profileName.text = posts[indexPath.row].userName
        cell.profileImage.image = UIImage(named: "wine_red")
        cell.profileImage.backgroundColor = .lightGray
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
        cell.profileImage.layer.borderWidth = 1
        cell.profileImage.layer.borderColor = UIColor.clear.cgColor
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
        guard let item = sender as? UserData else { return }
        ComuDetailVC.post = item
         
//        let selectedItem = collectionView.indexPathsForSelectedItems!
//        ComuDetailVC.post = posts[selectedItem]
//        print(selectedItem.count)
        
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
