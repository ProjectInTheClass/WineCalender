//
//  DetailScheduleTableViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/07/13.
//

import UIKit

class DetailScheduleTableViewController: UITableViewController {

    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    var schedule: Schedule?
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let schedule = schedule {
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .short

            datePicker.date = schedule.eventDate!
            dateLabel.text = dateFormatter.string(from: datePicker.date)
            placeTextField.text = schedule.schedulePlace
            descriptionTextField.text = schedule.scheduleDescription
        }
        
       // detailTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        dateLabel.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let date = datePicker.date
        let place = placeTextField.text ?? ""
        let description = descriptionTextField.text ?? ""
        
        if let schedule = schedule {
            schedule.eventDate = date
            schedule.schedulePlace = place
            schedule.scheduleDescription = description
            DataManager.shared.saveContext()
        }
        NotificationCenter.default.post(name: DetailScheduleTableViewController.scheduleDidChange , object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "삭제", message: "일정을 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] (action) in
            DataManager.shared.deleteSchedule(schedule: self?.schedule)
            NotificationCenter.default.post(name: DetailScheduleTableViewController.scheduleDidChange, object: nil)
            self?.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
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

extension DetailScheduleTableViewController {
    static let scheduleDidChange = Notification.Name(rawValue: "scheduleDidChnage")
}
