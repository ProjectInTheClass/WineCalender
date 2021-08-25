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
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUserProfile()

        if Auth.auth().currentUser != nil {
            PostManager.shared.fetchMyPosts()
        } else {
            DataManager.shared.fetchWineTastingNote()
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(forName: SignInViewController.userStateChangeNoti, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
//            self?.fetchUserProfile()
//        }

    }
    
    func fetchUserProfile() {
        profileImageView.layer.borderColor = UIColor.systemIndigo.cgColor
        profileImageView.layer.borderWidth = 1
        
        DispatchQueue.main.async {
            if Auth.auth().currentUser == nil {
                self.profileImageView.image = UIImage(systemName: "person.circle.fill")
                self.nicknameLabel.text = "비회원"
            } else {
                AuthenticationManager.shared.fetchUserNicknameAndProfileImage { nickname, profileImageURL in
                    self.nicknameLabel.text = nickname
                    if profileImageURL == nil {
                        self.profileImageView.image = UIImage(systemName: "person.circle.fill")?.withTintColor(.systemPurple, renderingMode: .alwaysOriginal)
                    } else {
                        self.profileImageView.kf.setImage(with: profileImageURL)
                    }
                }
            }
        }
    }
}

// MARK: - Table view data source

extension MyWinesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return wines.count
        if Auth.auth().currentUser != nil {
            return 0
        } else {
            return DataManager.shared.wineTastingNoteList.count
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "winesCell", for: indexPath) as! MyWinesTableViewCell
        
        //cell.wineNameLabel.text = wines[indexPath.row].name
        //cell.wineCategoryLabel.text = wines[indexPath.row].category
        cell.wineCellBG.layer.cornerRadius = 15
        cell.wineImageView.layer.cornerRadius = 10
        
        if Auth.auth().currentUser != nil {
            
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
