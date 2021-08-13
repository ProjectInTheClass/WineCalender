//
//  WineVarietiesTableViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/11.
//

import UIKit

class WineVarietiesTableViewController: UITableViewController {

    lazy var selectedItem: Set<String> = []{
        didSet {
            seletedWineVarieties = selectedItem.sorted()
        }
    }
    
    lazy var seletedWineVarieties: [String] = []
    
    var completionHandler: (([String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seletedWineVarieties.map{ selectedItem.insert($0) }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        if let completionHandler = completionHandler {
            completionHandler(seletedWineVarieties)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return WineVarieties.allCases.count
        return WineVarieties.sortedWineVarieties.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WineVarietiesTableViewCell", for: indexPath)
        //let wineVarieties = WineVarieties.allCases[indexPath.row].name
        let wineVarieties = WineVarieties.sortedWineVarieties[indexPath.row].name
        cell.textLabel?.text = wineVarieties
        
        if self.seletedWineVarieties.contains(wineVarieties) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        tableView.allowsMultipleSelection = true
        cell.selectionStyle = .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            //selectedItem.remove(WineVarieties.allCases[indexPath.row].name)
            selectedItem.remove(WineVarieties.sortedWineVarieties[indexPath.row].name)
        } else {
            cell.accessoryType = .checkmark
            //selectedItem.insert(WineVarieties.allCases[indexPath.row].name)
            selectedItem.insert(WineVarieties.sortedWineVarieties[indexPath.row].name)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.accessoryType = .none
        selectedItem.remove(WineVarieties.allCases[indexPath.row].name)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
