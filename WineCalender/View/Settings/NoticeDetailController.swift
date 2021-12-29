//
//  NoticeDetailController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/12/29.
//

import UIKit

private let reuseIdentifier = "NoticeDetailCell"

class NoticeDetailController: UITableViewController {
    
    lazy var notice: Notice? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(NoticeDetailCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.allowsSelection = false
    }
}

extension NoticeDetailController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NoticeDetailCell
        cell.dateLabel.text = notice?.date
        cell.titleLabel.text = notice?.title
        cell.detailLabel.text = notice?.detail
        return cell
    }
}
