//
//  HelpController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/12/29.
//

import UIKit

struct Help {
    let title: String
    let detail: String
}

private let reuseIdentifier = "HelpCell"

class HelpController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "도움말"
        tableView.register(HelpCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }
}

extension HelpController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        help.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! HelpCell
        cell.titleLabel.text = help[indexPath.row].title
        cell.detailLabel.text = help[indexPath.row].detail
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HelpCell
        tableView.performBatchUpdates {
            cell.showingDetail = !cell.showingDetail
        }
    }
}
