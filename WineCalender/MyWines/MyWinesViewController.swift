//
//  MyWinesTableViewController.swift
//  WineCalender
//
//  Created by GnoJng on 8/6/21.
//

import UIKit
import FirebaseAuth
import Kingfisher

class MyWinesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let myWinesHeaderViewModel = MyWinesHeaderViewModel()
    
    var posts = [Post]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var notes = [WineTastingNote]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        myWinesHeaderViewModel.onUpdated = {
            self.collectionView.reloadData()
        }
        myWinesHeaderViewModel.fetchUserProfile()

        setNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyPosts()
    }
    
    func setNotificationObserver() {
        NotificationCenter.default.addObserver(forName: AddTastingNoteViewController.uploadPost, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.fetchMyPosts()
        }
    }
    
    func fetchMyPosts() {
        if Auth.auth().currentUser != nil {
            PostManager.shared.fetchMyPosts { myPosts in
                self.posts = myPosts
            }
        } else {
            DataManager.shared.fetchWineTastingNote { notes in
                self.notes = notes
            }
        }
    }
    
    func resetModels() {
        myWinesHeaderViewModel.fetchUserProfile()
        fetchMyPosts()
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        let superview = sender.superview?.superview?.superview?.superview

        guard let cell = superview as? MyWinesCollectionViewCell else { return }
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        print(indexPath.row)

        let storyboard = UIStoryboard(name: "Community", bundle: nil)
        let comuDetailVC = storyboard.instantiateViewController(identifier: "ComuDetailVC") as! PostDetail

        if Auth.auth().currentUser != nil {
            comuDetailVC.postDetailData = posts[indexPath.row]
        } else {
//            comuDetailVC.postData = Post(note: notes[indexPath.row])
            comuDetailVC.postDetailData = nil
        }
        
        self.navigationController?.pushViewController(comuDetailVC, animated: true)
        
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension MyWinesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if Auth.auth().currentUser != nil {
            return posts.count
        } else {
            return notes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyWinesCell", for: indexPath) as! MyWinesCollectionViewCell
        
        cell.label1.isHidden = true
        cell.label2.isHidden = true
        cell.label3.isHidden = true
        cell.moreButton.isHidden = true
        cell.imageView.alpha = 1.0
        
        if Auth.auth().currentUser != nil {
            cell.post = posts[indexPath.row]
        } else {
            cell.note = notes[indexPath.row]
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

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MyWinesHeaderView", for: indexPath) as! MyWinesHeaderView
        
        headerView.update(user: myWinesHeaderViewModel)
        return headerView
    }
}
