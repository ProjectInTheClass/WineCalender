//
//  WineVarietiesTableViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/11.
//

import UIKit

class WineVarietiesTableViewController: UITableViewController {

    lazy var selectedWineVarieties: [String] = []
    
    var completionHandler: (([String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        if let completionHandler = completionHandler {
            completionHandler(selectedWineVarieties)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WineVarieties.sortedWineVarieties.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WineVarietiesTableViewCell", for: indexPath)
        let wineVarieties = WineVarieties.sortedWineVarieties[indexPath.row].name
        cell.textLabel?.text = wineVarieties
        
        if self.selectedWineVarieties.contains(wineVarieties) {
            cell.textLabel?.textColor = UIColor(named: "blackAndWhite")
            cell.accessoryType = .checkmark
            cell.isSelected = true
        } else {
            cell.textLabel?.textColor = .systemGray2
            cell.accessoryType = .none
            cell.isSelected = false
        }
        tableView.allowsMultipleSelection = true
        cell.selectionStyle = .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        if cell.accessoryType == .none {
            cell.textLabel?.textColor = UIColor(named: "blackAndWhite")
            cell.accessoryType = .checkmark
            cell.isSelected = true
            selectedWineVarieties.append(WineVarieties.sortedWineVarieties[indexPath.row].name)
        } else {
            cell.textLabel?.textColor = .systemGray2
            cell.accessoryType = .none
            cell.isSelected = false
            if let index = selectedWineVarieties.firstIndex(of:WineVarieties.sortedWineVarieties[indexPath.row].name) {
                selectedWineVarieties.remove(at: index)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.textLabel?.textColor = .systemGray2
        cell.accessoryType = .none
        cell.isSelected = false
        if let index = selectedWineVarieties.firstIndex(of:WineVarieties.sortedWineVarieties[indexPath.row].name) {
            selectedWineVarieties.remove(at: index)
        }
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
