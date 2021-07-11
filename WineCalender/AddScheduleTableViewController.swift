//
//  AddScheduleTableViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/07/09.
//

import UIKit

class AddScheduleTableViewController: UITableViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var receivedDateAndTime = Date()
    let receivedDateFormatter = DateFormatter()
    let dateFormatter = DateFormatter()
    var event: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "일정 추가"
        
        receivedDateFormatter.locale = Locale(identifier: "ko_KR")
        receivedDateFormatter.dateFormat = "yyyy-MM-dd E a h:00"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short

        let receivedDateAndTimeStr = receivedDateFormatter.string(from: receivedDateAndTime)
        datePicker.date = receivedDateFormatter.date(from: receivedDateAndTimeStr)!
        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        dateLabel.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let dateStr = dateLabel.text ?? ""
        let date = dateFormatter.date(from: dateStr)!
        let place = placeTextField.text ?? ""
        let description = descriptionTextField.text ?? ""
        let fullDescription = "\(place) / \(description)"

        DataManager.shared.addEvent(eventDate: date, eventDescription: fullDescription, wineName: "", category: "Schedule")
        
        NotificationCenter.default.post(name: AddScheduleTableViewController.newScheduleDidInsert, object: nil)
        
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

extension AddScheduleTableViewController {
    static let newScheduleDidInsert = Notification.Name(rawValue: "newScheduleDidInsert")
}
