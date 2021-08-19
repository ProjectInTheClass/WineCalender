//
//  ComuDetailVC.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/08/16.
//

import Foundation
import UIKit

class ComuDetailVC : UIViewController {
    @IBOutlet weak var detailProfile: UIImageView!
    @IBOutlet weak var detailMainImg: UIImageView!
    @IBOutlet weak var memoTxt: UILabel!
    @IBOutlet weak var userName: UILabel!
    
    
    var post : UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailProfile.image = UIImage(named: "wine_red")
        detailMainImg.image = UIImage(named: "AppIcon")
        memoTxt.text = post?.postText
        userName.text = post?.userName
        
        
    }
}
