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
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = UIViewController()
        firstViewController.view.backgroundColor = .orange
    
        let secondViewController = UIViewController()
        secondViewController.view.backgroundColor = .purple
        
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
        
        // TabBarItem
        let community = (storyboard?.instantiateViewController(identifier: "Community"))!
        let add = UIViewController()
        add.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus"), selectedImage: nil)
        add.tabBarItem.isEnabled = false
        let myWines = (storyboard?.instantiateViewController(identifier: "MyWines"))!
        self.viewControllers = [community, add, myWines]
        
        setAddButton()
    }
    
    func setAddButton() {
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    @objc func addButtonTapped() {
        let addTastingNoteNav = storyboard?.instantiateViewController(identifier: "AddTastingNoteNav")
        addTastingNoteNav?.modalPresentationStyle = .fullScreen
        self.present(addTastingNoteNav!, animated: true, completion: nil)
    }
}
