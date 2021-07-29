//
//  ComuTVC.swift
//  WineCalender
//
//  Created by 강재권 on 2021/07/27.
//

import Foundation
import UIKit

class ComuTVC : UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension ComuTVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SlideCell",for:indexPath) as! SearchTableViewCell
        
        return cell
    }
}



