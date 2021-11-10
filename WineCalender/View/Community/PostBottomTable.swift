//
//  PostBottomTable.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/11/03.
//

import Foundation
import UIKit
import PanModal

class PostBottomTableViewController : UITableViewController,PanModalPresentable {
    var panScrollable: UIScrollView?{
        return tableView
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(300)
    }

    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(40)
    }
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panModalSetNeedsLayoutUpdate()
        panModalTransition(to: .shortForm)
    }
    
}
class BottomTableViewCell : UITableViewCell {
    
}
extension PostBottomTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
}
