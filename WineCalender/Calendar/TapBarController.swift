//
//  TapBarController.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/08/19.
//

import UIKit
import Parchment

class TabBarController: UITabBarController {
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
    }
}
