//
//  TapBarController.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/08/19.
//

import UIKit
import Parchment

class TabBarController: UITabBarController {
    
    let addButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        let firstViewController = (storyboard?.instantiateViewController(identifier: "Community"))!
        let secondViewController = (storyboard?.instantiateViewController(identifier: "Community"))!
        
        // Initialize a FixedPagingViewController and pass
        // in the view controllers.
        let pagingViewController = PagingViewController(viewControllers: [
          firstViewController,
          secondViewController
        ])
        
        // Make sure you add the PagingViewController as a child view
        // controller and contrain it to the edges of the view.
        addChild(pagingViewController)
        view.addSubview(pagingViewController.view)
//        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
         
         pagingViewController.tabBarItem = UITabBarItem(title:"Community",image:UIImage(systemName: ""),selectedImage: nil)
         */
        
        let layout = ZigzagLayout()
        let communityCollectionVC = Community(collectionViewLayout: layout)
        communityCollectionVC.tabBarItem = UITabBarItem(title: "Community", image: UIImage(named: "tab_Community"), selectedImage: UIImage(named: "tab_Community"))
        let communityNavContr = UINavigationController(rootViewController: communityCollectionVC)
        
        // TabBarItem
        let add = UIViewController()
        add.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus"), selectedImage: nil)
        let myWines = (storyboard?.instantiateViewController(identifier: "MyWines"))!
        myWines.tabBarItem = UITabBarItem(title: "My Wines", image: UIImage(named: "MyWinesTabBarItem"), selectedImage: nil)
        self.viewControllers = [communityNavContr, add, myWines]
        
        setAddButton()
    }
    
    func setAddButton() {
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        let height = self.tabBar.frame.size.height
        addButton.heightAnchor.constraint(equalToConstant: height).isActive = true
        let width = self.tabBar.frame.size.width / 3
        addButton.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    @objc func addButtonTapped() {
        let addTastingNoteNav = storyboard?.instantiateViewController(identifier: "AddTastingNoteNav")
        addTastingNoteNav?.modalPresentationStyle = .fullScreen
        self.present(addTastingNoteNav!, animated: true, completion: nil)
    }
}
