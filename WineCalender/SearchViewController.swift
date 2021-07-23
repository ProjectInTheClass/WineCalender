//
//  SearchViewController.swift
//  WineCalender
//
//  Created by 강재권 on 2021/07/15.
//

import Foundation
import UIKit

struct Wine {
    let name : String
    let category: String
}

var wines = [
    Wine(name: "LIV", category: "Red"),
    Wine(name: "CIGAR BOX PINOT NOIR", category: "Red"),
    Wine(name: "CIGAR BOX CABERNET SAUVIGNON", category: "Red"),
    Wine(name: "CHATEAU RELAIS DE LA POSTE", category: "Red"),
    Wine(name: "CIGAR BOX MALBEC", category: "Red"),
    Wine(name: "MOET & CHANDON IMPERIAL", category: "Red"),
    Wine(name: "RUINART ROSE 12.5%", category: "Red"),
    Wine(name: "CHIANTI CLASSICO", category: "Red"),
    Wine(name: "Test1", category: "Red"),
    Wine(name: "Test2", category: "Red"),
    Wine(name: "Test3", category: "Red"),
    Wine(name: "Test4", category: "Red"),
    Wine(name: "TestTestTestTestTestTestTestTestTestTest", category: "Red"),
]



class ResultsVC : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

}

class SearchViewController : UITableViewController,UISearchResultsUpdating, UISearchBarDelegate {
    @IBOutlet var wineTableView: UITableView!
    let searchController = UISearchController(searchResultsController: ResultsVC())
    var filteredWines = [Wine]()
    
    override func viewDidLoad() {
        wineTableView.dataSource = self
        wineTableView.delegate = self
        title = "Wine Search"
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Wines"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        wineTableView.separatorStyle = .none
        wineTableView.showsVerticalScrollIndicator = false
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        let vc = searchController.searchResultsController as? ResultsVC
        filterContentForSearchText(searchController.searchBar.text!)

        print(text)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
     
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    func filterContentForSearchText(_ searchText:String, scope:String = "All"){
        filteredWines = wines.filter({(wine:Wine)->Bool in
            return wine.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    
    
}
extension SearchViewController  {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering(){
            return filteredWines.count
        }
        return wines.count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell",for:indexPath) as! SearchTableViewCell
        let wine:Wine
        
        if isFiltering(){
            wine = filteredWines[indexPath.row]
        }else {
            wine = wines[indexPath.row]
        }
        cell.cellTitle.text = wine.name
        cell.cellSubTitle.text = wine.category
        
        cell.SearchView.layer.cornerRadius = cell.SearchView.frame.height / 5
        cell.cellImage.layer.cornerRadius = cell.cellImage.frame.height / 2
        
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "searchDetail", let SearchDetailViewController = segue.description as? SearchDetailViewController else { return }
        
        let indexPath = tableView.indexPathForSelectedRow!
        SearchDetailViewController.wine = wines[indexPath.row]
    }
    
    
}
