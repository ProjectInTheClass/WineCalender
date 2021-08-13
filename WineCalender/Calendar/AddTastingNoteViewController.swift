//
//  AddTastingNoteViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/11.
//

import UIKit

class AddTastingNoteViewController: UIViewController {

    var selectedWineVarieties: [String]?
    var selectedWineProducingCountry: String?
    
    @IBOutlet weak var addTastingNoteScrollView: UIScrollView!
    @IBOutlet weak var wineNameTextField: UITextField!
    @IBOutlet weak var wineCategorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var wineVarietiesLabel: UILabel!
    @IBOutlet weak var wineProducingCountryLabel: UILabel!
    @IBOutlet weak var winePriceTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboard()
    }
    
    func registerForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustScrollView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustScrollView), name: UIResponder.keyboardWillHideNotification, object: nil)
        addTastingNoteScrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

    @objc func adjustScrollView(noti: Notification) {
        guard let userInfo = noti.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if noti.name == UIResponder.keyboardWillShowNotification {
            let keyboardHeight = keyboardFrame.size.height
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            addTastingNoteScrollView.contentInset = contentInsets
        } else {
            addTastingNoteScrollView.contentInset = UIEdgeInsets.zero
        }
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func keboardReturnKeyTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func resetWineCategorybuttonTapped(_ sender: UIButton) {
        wineCategorySegmentedControl.selectedSegmentIndex = -1
    }
    
    @IBAction func wineVarietiesButtonTapped(_ sender: UIButton) {
        if let WineVarietiesTVC = storyboard?.instantiateViewController(identifier: "WineVarietiesTVC") as? WineVarietiesTableViewController {
            WineVarietiesTVC.seletedWineVarieties = selectedWineVarieties ?? []
            self.navigationController?.pushViewController(WineVarietiesTVC, animated: true)
            
            WineVarietiesTVC.completionHandler = { wineVarieties in
                self.selectedWineVarieties = wineVarieties
                if self.selectedWineVarieties == [] {
                    self.wineVarietiesLabel.textColor = .systemGray2
                    self.wineVarietiesLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                    self.wineVarietiesLabel.text = "  품종을 선택해 주세요."
                } else if self.selectedWineVarieties?.count == 1 {
                    self.wineVarietiesLabel.textColor = UIColor(named: "blackAndWhite")
                    self.wineVarietiesLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                    self.wineVarietiesLabel.text = "  " + self.selectedWineVarieties!.first!
                } else {
                    if let wineVarietiesString = self.selectedWineVarieties?.reduce("", { $0 + "  " + $1 + "\n" }) {
                        self.wineVarietiesLabel.textColor = UIColor(named: "blackAndWhite")
                        self.wineVarietiesLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                        self.wineVarietiesLabel.text = wineVarietiesString
                    }
                }
            }
        }
    }
    
    @IBAction func wineProducingCountryButtonTapped(_ sender: UIButton) {
        if let wineProducingCountriesTVC = storyboard?.instantiateViewController(identifier: "WineProducingCountriesTVC") as? WineProducingCountriesTableViewController {
            wineProducingCountriesTVC.selectedCountry = self.selectedWineProducingCountry ?? ""
            self.navigationController?.pushViewController(wineProducingCountriesTVC, animated: true)
            
            wineProducingCountriesTVC.completionHandler = { country in
                self.selectedWineProducingCountry = country
                if let country = self.selectedWineProducingCountry {
                    self.wineProducingCountryLabel.textColor = UIColor(named: "blackAndWhite")
                    self.wineProducingCountryLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                    self.wineProducingCountryLabel.text = "  " + country
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
