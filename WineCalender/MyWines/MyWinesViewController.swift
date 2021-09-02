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
    
    var profileImageURL: URL? = nil
    var nickname: String = ""
    var introduction: String = ""
    var postIDs: [String] = []
    var myPosts: [Post] = []
    var postImageURLs: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.layoutIfNeeded()
        
        setNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyPosts()
        fetchMyProfile()
    }
    
    func setNotificationObserver() {
        NotificationCenter.default.addObserver(forName: SignInViewController.userSignInNoti, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.fetchMyPosts()
            self?.fetchMyProfile()
        }
        
        NotificationCenter.default.addObserver(forName: AddTastingNoteViewController.uploadPost, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.fetchMyPosts()
        }

        NotificationCenter.default.addObserver(forName: SettingsTableViewController.userSignOutNoti, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.profileImageURL = nil
            self?.nickname = ""
            self?.introduction = ""
            self?.postIDs = []
            self?.myPosts = []
            self?.postImageURLs = []
        }
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
    
    func fetchMyProfile() {
        AuthenticationManager.shared.fetchMyProfile { profileImageURL, nickname, introduction in
            self.profileImageURL = profileImageURL
            self.nickname = nickname
            self.introduction = introduction
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        let superview = sender.superview?.superview?.superview?.superview

        guard let cell = superview as? MyWinesCollectionViewCell else { return }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        print(indexPath.row)
    }
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
        
        cell.label1.isHidden = true
        cell.label2.isHidden = true
        cell.label3.isHidden = true
        cell.moreButton.isHidden = true
        
        if Auth.auth().currentUser != nil {
            //let post = self.myPosts[indexPath.row]
            //cell.wineNameLabel.text = post.tastingNote.wineName
            //cell.wineCategoryLabel.text = post.tastingNote.category
            cell.imageView.kf.setImage(with: self.postImageURLs[indexPath.row])
            cell.imageView.alpha = 1.0
        } else {
            let note = DataManager.shared.wineTastingNoteList[indexPath.row]
            //cell.wineNameLabel.text = note.name
            //cell.wineCategoryLabel.text = note.category
            cell.imageView.image = note.image[0]
            cell.imageView.alpha = 1.0
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MyWinesCollectionViewCell
        
        UIView.transition(with: cell.imageView, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        UIView.transition(with: cell.stackView, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        
        if cell.imageView.alpha == 1.0 {
            cell.imageView.alpha = 0.2
            cell.label1.isHidden = false
            cell.label2.isHidden = false
            cell.label3.isHidden = false
            cell.moreButton.isHidden = false
        } else {
            cell.imageView.alpha = 1.0
            cell.label1.isHidden = true
            cell.label2.isHidden = true
            cell.label3.isHidden = true
            cell.moreButton.isHidden = true
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ko_kr")
        
        if Auth.auth().currentUser != nil {
            let post = self.myPosts[indexPath.row]
            cell.label1.text = "🍷 " + post.tastingNote.wineName
            cell.label2.text = "🗓 " + dateFormatter.string(from: post.tastingNote.tastingDate)
            cell.label3.text = "⭐️" + "\(post.tastingNote.rating ?? 0)"
        } else {
            let note = DataManager.shared.wineTastingNoteList[indexPath.row]
            cell.label1.text = "🍷 " + note.name
            cell.label2.text = "🗓 " + dateFormatter.string(from: note.date)
            cell.label3.text = "⭐️" + "\(note.rating)"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MyWinesHeaderView", for: indexPath) as! MyWinesHeaderView
        
        if Auth.auth().currentUser != nil {
            headerView.nicknameLabel.text = nickname
            headerView.introductionLabel.text = introduction
            if profileImageURL == nil {
                headerView.profileImageView.image = UIImage(systemName: "person.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
            } else {
                headerView.profileImageView.kf.setImage(with: profileImageURL)
            }
        } else {
            headerView.profileImageView.image = UIImage(systemName: "person.circle.fill")
            headerView.nicknameLabel.text = "비회원"
            headerView.introductionLabel.text = ""
        }
        
        return headerView
    }
}
