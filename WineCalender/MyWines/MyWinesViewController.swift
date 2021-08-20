//
//  MyWinesTableViewController.swift
//  WineCalender
//
//  Created by GnoJng on 8/6/21.
//

import UIKit
import Firebase

class MyWinesViewController: UIViewController {
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateNicknameLabel()
        
        NotificationCenter.default.addObserver(forName: SignInViewController.userStateChangeNoti, object: nil, queue: OperationQueue.main) { [weak self] (noti) in
            self?.updateNicknameLabel()
        }
    }
    
    func updateNicknameLabel() {
        if Auth.auth().currentUser != nil {
            nicknameLabel.text = Auth.auth().currentUser?.email
        } else {
            nicknameLabel.text = "비회원"
        }
    }
}

// MARK: - Table view data source

extension MyWinesViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return wines.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "winesCell", for: indexPath) as! MyWinesTableViewCell

        // Configure the cell...
        cell.wineNameLabel.text = wines[indexPath.row].name
        cell.wineCategoryLabel.text = wines[indexPath.row].category
        cell.wineCellBG.layer.cornerRadius = 15
        cell.wineImageView.layer.cornerRadius = 10

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
