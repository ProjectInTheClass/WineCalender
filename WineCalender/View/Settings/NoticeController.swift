//
//  NoticeController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/12/29.
//

import UIKit

struct Notice: Decodable {
    let title: String
    let detail: String
    let date: String
}

private let reuseIdentifier = "NoticeCell"

class NoticeController: UITableViewController {
    
    //private let notice: [[String:String]] = [["title":"공지사항1","date":"2021.12.29"], ["title":"공지사항2","date":"2021.12.30"], ["title":"공지사항3 공지사항3 공지 사항3공 지 사항3 공지사 항3공지 사항3 공지사 항3공지사항3공지사항3공지사항3공지사항3공지사항3공지사항3공지사항3공지사항3공지사항3공지사항3공지사항3","date":"2022.01.01"]]
    private var notice = [Notice]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "공지사항"
        configureTableView()
        fetchNotice()
    }
    
    func configureTableView() {        
        tableView.register(NoticeCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
    }
    
    func fetchNotice() {
        NoticeManager.shared.fetchNotice { [weak self] notice in
            self?.notice = notice.reversed()
            self?.tableView.reloadData()
        }
    }
}

extension NoticeController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notice.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NoticeCell
        cell.dateLabel.text = notice[indexPath.row].date
        cell.titleLabel.text = notice[indexPath.row].title

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let vc = NoticeDetailController()
        vc.notice = notice[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
