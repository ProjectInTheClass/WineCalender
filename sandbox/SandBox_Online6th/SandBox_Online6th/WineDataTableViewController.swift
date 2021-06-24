//
//  WineDataTableViewController.swift
//  SandBox_Online6th
//
//  Created by 강재권 on 2021/06/24.
//

import Foundation
import UIKit

struct WineData {
    var name : String
    var price : String
    var year : Int
    var category : String
}

var wines : [WineData] = []



class WineDataTableViewController : UITableViewController {
    
    
    override func viewDidLoad() {
        wines.append(WineData(name: "wine1", price: "1000원", year: 1880, category: "red"))
        wines.append(WineData(name: "wine2", price: "2000원", year: 1881, category: "white"))
        wines.append(WineData(name: "wine3", price: "3000원", year: 1882, category: "pink"))
        wines.append(WineData(name: "wine4", price: "4000원", year: 1883, category: "another"))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wines.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")!
//        name.text = wines[indexPath.row].name
        cell.textLabel?.text = wines[indexPath.row].name
        cell.detailTextLabel?.text = wines[indexPath.row].price
        
        return cell
    }
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
}
