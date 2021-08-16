//
//  AddTastingNoteViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/11.
//

import UIKit

class AddTastingNoteViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var selectedWineVarieties: [String]?
    var selectedWineProducingCountry: String?
    var selectedVintage: String?
    var selectedWineAromasAndFlavors: [String]?
    
    @IBOutlet weak var addTastingNoteScrollView: UIScrollView!
    @IBOutlet weak var wineNameTextField: UITextField!
    @IBOutlet weak var wineCategorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var wineVarietiesLabel: UILabel!
    @IBOutlet weak var wineProducingCountryLabel: UILabel!
    @IBOutlet weak var wineVintageLabel: UILabel!
    @IBOutlet weak var winePriceTextField: UITextField!
    @IBOutlet weak var wineAromasAndFlavorsLabel: UILabel!
    @IBOutlet weak var wineMemoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerForKeyboard()
    }
    
    func registerForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        addTastingNoteScrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }

//    @objc func adjustScrollView(noti: Notification) {
//        guard let userInfo = noti.userInfo,
//              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
//        if noti.name == UIResponder.keyboardWillShowNotification {
//            let keyboardHeight = keyboardFrame.size.height
//            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
//            addTastingNoteScrollView.contentInset = contentInsets
//        } else if noti.name == UIResponder.keyboardWillShowNotification {
//            addTastingNoteScrollView.contentInset = UIEdgeInsets.zero
//        }
//    }
    
    @objc func keyboardWillShow(noti: Notification) {
        guard let userInfo = noti.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if noti.name == UIResponder.keyboardWillShowNotification {
            let keyboardHeight = keyboardFrame.size.height
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            addTastingNoteScrollView.contentInset = contentInsets
        }
    }
    
    @objc func keyboardWillHide(noti: Notification) {
            addTastingNoteScrollView.contentInset = UIEdgeInsets.zero
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
            WineVarietiesTVC.selectedWineVarieties = selectedWineVarieties ?? []
            self.navigationController?.pushViewController(WineVarietiesTVC, animated: true)
            
            WineVarietiesTVC.completionHandler = { wineVarieties in
                self.selectedWineVarieties = wineVarieties
                if self.selectedWineVarieties == [] {
                    self.wineVarietiesLabel.textColor = .systemGray2
                    self.wineVarietiesLabel.text = "  품종을 선택해 주세요."
                } else if self.selectedWineVarieties?.count == 1 {
                    self.wineVarietiesLabel.textColor = UIColor(named: "blackAndWhite")
                    self.wineVarietiesLabel.text = "  " + self.selectedWineVarieties!.first!
                } else {
                    if let wineVarietiesString = self.selectedWineVarieties?.reduce("", { $0 + "  " + $1 + "\n" }) {
                        self.wineVarietiesLabel.textColor = UIColor(named: "blackAndWhite")
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
                    self.wineProducingCountryLabel.text = "  " + country
                }
            }
        }
    }
    
    @IBAction func wineVintageButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let contentVC = UIViewController()
        let vintagePickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        vintagePickerView.delegate = self
        vintagePickerView.dataSource = self
        if let selectedVintage = self.selectedVintage {
            let index = winevintageList.firstIndex(of: selectedVintage)
            vintagePickerView.selectRow(index!, inComponent: 0, animated: false)
        } else {
            let lastRow = winevintageList.count - 1
            vintagePickerView.selectRow(lastRow, inComponent: 0, animated: false)
        }
        contentVC.view = vintagePickerView
        alert.setValue(contentVC, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { result in
            self.selectedVintage = self.winevintageList[vintagePickerView.selectedRow(inComponent: 0)]
            if let selectedVintage = self.selectedVintage {
                self.wineVintageLabel.textColor = UIColor(named: "blackAndWhite")
                self.wineVintageLabel.text = "  " + selectedVintage
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func wineAromasAndFlavorsButtonTapped(_ sender: UIButton) {
        if let wineAromasAndFlavorsCVC = storyboard?.instantiateViewController(identifier: "wineAromasAndFlavorsCVC") as? WineAromasAndFlavorsCollectionViewController {
            wineAromasAndFlavorsCVC.selectedWineAromasAndFlavors = selectedWineAromasAndFlavors ?? []
            self.navigationController?.pushViewController(wineAromasAndFlavorsCVC, animated: true)
            
            wineAromasAndFlavorsCVC.completionHandler = { aromasAndFlavors in
                self.selectedWineAromasAndFlavors = aromasAndFlavors
                if self.selectedWineAromasAndFlavors == [] {
                    self.wineAromasAndFlavorsLabel.textColor = .systemGray2
                    self.wineAromasAndFlavorsLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                    self.wineAromasAndFlavorsLabel.text = "  향, 맛을 선택해 주세요."
                } else if self.selectedWineAromasAndFlavors?.count == 1 {
                    self.wineAromasAndFlavorsLabel.textColor = UIColor(named: "blackAndWhite")
                    self.wineAromasAndFlavorsLabel.text = "  " + self.selectedWineAromasAndFlavors!.first!
                } else {
                    if let wineAromasAndFlavorsString = self.selectedWineAromasAndFlavors?.reduce("", { $0 + "  " + $1 + "\n" }) {
                        self.wineAromasAndFlavorsLabel.textColor = UIColor(named: "blackAndWhite")
                        self.wineAromasAndFlavorsLabel.text = wineAromasAndFlavorsString
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource, UIPickerViewDelegate
    
    let winevintageList: [String] = {
        var list: [String] = []
        let date = Date()
        let calendar = Calendar.current
        let nextYear = calendar.component(.year, from: date) + 1
        for i in 1960..<nextYear {
            list.append("\(i)")
        }
        list.append("Non-Vintage")
        return list
    }()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return winevintageList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = winevintageList[row]
        return row
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let vintage = winevintageList[row]
        self.selectedVintage = vintage
    }
}
