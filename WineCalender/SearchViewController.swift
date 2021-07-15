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
    Wine(name: "Item1", category: "Red"),
    Wine(name: "Item2", category: "Red"),
    Wine(name: "Item3", category: "Red"),
    Wine(name: "Item4", category: "Red"),
    Wine(name: "nonono", category: "Red"),
    Wine(name: "nonono1", category: "Red"),
    Wine(name: "nonono2", category: "Red"),
    Wine(name: "nonono3", category: "Red"),
    Wine(name: "nonono4", category: "Red"),
]



class ResultsVC : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

}

class SearchViewController : UITableViewController,UISearchResultsUpdating, UISearchBarDelegate {
    let searchController = UISearchController(searchResultsController: ResultsVC())
    var filteredWines = [Wine]()
    
    override func viewDidLoad() {
        title = "Search"
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Wines"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell",for:indexPath)
        let wine:Wine
        
        if isFiltering(){
            wine = filteredWines[indexPath.row]
        }else {
            wine = wines[indexPath.row]
        }
        cell.textLabel?.text = wines[indexPath.row].name
        cell.detailTextLabel?.text = wines[indexPath.row].category
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "searchDetail", let SearchDetailViewController = segue.description as? SearchDetailViewController else { return }
        
        let indexPath = tableView.indexPathForSelectedRow!
        SearchDetailViewController.wine = wines[indexPath.row]
    }
    
    
}
