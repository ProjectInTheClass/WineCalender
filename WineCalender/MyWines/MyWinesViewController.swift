//
//  MyWinesTableViewController.swift
//  WineCalender
//
//  Created by GnoJng on 8/6/21.
//

import UIKit
import Firebase
import Kingfisher

class MyWinesViewController: UIViewController {
    
    //@IBOutlet weak var profileImageView: UIImageView!
    //@IBOutlet weak var nicknameLabel: UILabel!
    //@IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var postIDs: [String] = []
    var myPosts: [Post] = []
    var postImageURLs: [URL] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyPosts()
        //fetchUserProfile()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: AddTastingNoteViewController.uploadPost, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.fetchMyPosts()
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.layoutIfNeeded()
    }
    
    func fetchMyPosts() {
        DispatchQueue.main.async {
            if Auth.auth().currentUser != nil {
                PostManager.shared.fetchMyPosts { postIDs, myPosts  in
                    self.postIDs = postIDs
                    self.myPosts = myPosts
                    self.postImageURLs = myPosts.map { URL(string: $0.postImageURL[0])! }
                    //self.tableView.reloadData()
                    self.collectionView.reloadData()
                }
            } else {
                DataManager.shared.fetchWineTastingNote()
                //self.tableView.reloadData()
                self.collectionView.reloadData()
            }
        }
    }
    
//    func fetchUserProfile() {
//        profileImageView.layer.borderColor = UIColor.systemGray2.cgColor
//        profileImageView.layer.borderWidth = 1
//
//        DispatchQueue.main.async {
//            if Auth.auth().currentUser == nil {
//                self.profileImageView.image = UIImage(systemName: "person.circle.fill")
//                self.nicknameLabel.text = "비회원"
//            } else {
//                AuthenticationManager.shared.fetchUserNicknameAndProfileImage { nickname, profileImageURL in
//                    self.nicknameLabel.text = nickname
//                    if profileImageURL == nil {
//                        self.profileImageView.image = UIImage(systemName: "person.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
//                    } else {
//                        self.profileImageView.kf.setImage(with: profileImageURL)
//                    }
//                }
//            }
//        }
//    }
}

// MARK: - Table view data source
/*
extension MyWinesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Auth.auth().currentUser != nil {
            return self.myPosts.count
        } else {
            return DataManager.shared.wineTastingNoteList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "winesCell", for: indexPath) as! MyWinesTableViewCell

        cell.wineCellBG.layer.cornerRadius = 15
        cell.wineImageView.layer.cornerRadius = 10
        
        if Auth.auth().currentUser != nil {
            let post = self.myPosts[indexPath.row]
            cell.wineNameLabel.text = post.tastingNote.wineName
            cell.wineCategoryLabel.text = post.tastingNote.category
            cell.wineImageView.kf.setImage(with: self.postImageURLs[indexPath.row])
        } else {
            let note = DataManager.shared.wineTastingNoteList[indexPath.row]
            cell.wineNameLabel.text = note.name
            cell.wineCategoryLabel.text = note.category
            cell.wineImageView.image = note.image[0]
        }
   
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {(ac:UIContextualAction, view: UIView, success:(Bool) -> Void) in })
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: {(ac:UIContextualAction, view: UIView, success:(Bool) -> Void) in success(true)})
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}
*/

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MyWinesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if Auth.auth().currentUser != nil {
            return self.myPosts.count
        } else {
            return DataManager.shared.wineTastingNoteList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWinesCell", for: indexPath) as! MyWinesCollectionViewCell
        if Auth.auth().currentUser != nil {
            //let post = self.myPosts[indexPath.row]
            //cell.wineNameLabel.text = post.tastingNote.wineName
            //cell.wineCategoryLabel.text = post.tastingNote.category
            cell.imageView.kf.setImage(with: self.postImageURLs[indexPath.row])
        } else {
            let note = DataManager.shared.wineTastingNoteList[indexPath.row]
            //cell.wineNameLabel.text = note.name
            //cell.wineCategoryLabel.text = note.category
            cell.imageView.image = note.image[0]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = 2
        let spacing: CGFloat = 2
        let width = (collectionView.bounds.width - margin * 2 - spacing) / 2
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyWinesHeaderView", for: indexPath) as! MyWinesHeaderView
        
        if Auth.auth().currentUser != nil {
            AuthenticationManager.shared.fetchUserNicknameAndProfileImage { nickname, profileImageURL in
                headerView.nicknameLabel.text = nickname
                if profileImageURL == nil {
                    headerView.profileImageView.image = UIImage(systemName: "person.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
                } else {
                    headerView.profileImageView.kf.setImage(with: profileImageURL)
                }
            }
        } else {
            headerView.profileImageView.image = UIImage(systemName: "person.circle.fill")
            headerView.nicknameLabel.text = "비회원"
        }
        
        return headerView
    }
}
