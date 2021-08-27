//
//  AddTastingNoteViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/11.
//

import UIKit
import YPImagePicker
import FirebaseAuth

class AddTastingNoteViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, YPImagePickerDelegate, UITextViewDelegate {
    
    var selectedImages: [UIImage] = []
    var selectedCateory: String?
    var selectedWineVarieties: [String]?
    var selectedWineProducingCountry: String?
    var selectedVintage: String?
    var selectedWineAromasAndFlavors: [String]?
    
    var price: Int32?
    var alcoholContent: Float?
    
    @IBOutlet weak var addTastingNoteScrollView: UIScrollView!
    @IBOutlet weak var wineTastingdate: UIDatePicker!
    @IBOutlet weak var wineTastingPlaceTextField: UITextField!
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
    @IBOutlet weak var wineNameTextField: UITextField!
    @IBOutlet weak var wineCategorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var wineVarietiesLabel: UILabel!
    @IBOutlet weak var wineProducingCountryLabel: UILabel!
    @IBOutlet weak var wineProducerTextField: UITextField!
    @IBOutlet weak var wineVintageLabel: UILabel!
    @IBOutlet weak var winePriceTextField: UITextField!
    @IBOutlet weak var wineAlcoholContentTextField: UITextField!
    @IBOutlet weak var sweetSegmentedControl: UISegmentedControl!
    @IBOutlet weak var aciditySegmentedControl: UISegmentedControl!
    @IBOutlet weak var tanninSegmentedControl: UISegmentedControl!
    @IBOutlet weak var bodySegmentedControl: UISegmentedControl!
    @IBOutlet weak var wineAromasAndFlavorsLabel: UILabel!
    @IBOutlet weak var wineMemoTextView: UITextView!
    @IBOutlet weak var ratingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabelIndent()
        registerForKeyboard()
    }
    
    func setLabelIndent() {
        wineVarietiesLabel.attributedText = wineVarietiesLabel.labelIndent(string: "품종을 선택해 주세요.")
        wineProducingCountryLabel.attributedText = wineProducingCountryLabel.labelIndent(string: "생산국을 선택해 주세요.")
        wineVintageLabel.attributedText = wineVintageLabel.labelIndent(string: "빈티지를 선택해 주세요.")
        wineAromasAndFlavorsLabel.attributedText = wineAromasAndFlavorsLabel.labelIndent(string: "향, 맛을 선택해 주세요.")
    }
    
    func registerForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        addTastingNoteScrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func keyboardWillShow(noti: Notification) {
        guard let userInfo = noti.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if noti.name == UIResponder.keyboardWillShowNotification {
            let keyboardHeight = keyboardFrame.size.height
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardHeight, right: 0.0)
            addTastingNoteScrollView.contentInset = contentInsets
            addTastingNoteScrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc func keyboardWillHide(noti: Notification) {
        addTastingNoteScrollView.contentInset = UIEdgeInsets.zero
        addTastingNoteScrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func keboardReturnKeyTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.library.itemOverlayType = .grid
        config.usesFrontCamera = false
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = .library
        config.screens = [.library, .photo]
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.maxCameraZoomFactor = 2.0
        config.library.maxNumberOfItems = 3
        config.gallery.hidesRemoveButton = false
        
        let picker = YPImagePicker(configuration: config)
        picker.imagePickerDelegate = self
        picker.didFinishPicking { [weak picker] items, cancelled in
            if cancelled {
                print("Picker was canceled")
                picker?.dismiss(animated: true, completion: nil)
                return
            }

            var selectedItems = [UIImage]()
            for item in items {
                switch item {
                case .photo(let photo):
                    selectedItems.append(photo.image)
                    let count = selectedItems.count
                    if count == 1 {
                        self.firstImageView.image = selectedItems[0]
                        self.secondImageView.image = nil
                        self.thirdImageView.image = nil
                    } else if count == 2 {
                        self.firstImageView.image = selectedItems[0]
                        self.secondImageView.image = selectedItems[1]
                        self.thirdImageView.image = nil
                    } else if count == 3 {
                        self.firstImageView.image = selectedItems[0]
                        self.secondImageView.image = selectedItems[1]
                        self.thirdImageView.image = selectedItems[2]
                    } else {
                        return
                    }
                    picker?.dismiss(animated: true, completion: {
                        self.selectedImages = selectedItems
                        if self.wineNameTextField.text != "" {
                            self.doneButton.isUserInteractionEnabled = true
                            self.doneButton.backgroundColor = UIColor.brown
                        }
                    })
                case .video:
                    print("video")
                }
            }
        }
        present(picker, animated: true, completion: nil)
    }
    
    func noPhotos() {
        print("noPhotos")
    }
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true
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
                    self.wineVarietiesLabel.text = "품종을 선택해 주세요."
                } else if self.selectedWineVarieties?.count == 1 {
                    self.wineVarietiesLabel.textColor = UIColor(named: "blackAndWhite")
                    self.wineVarietiesLabel.text = self.selectedWineVarieties!.first!
                } else {
                    if let wineVarietiesString = self.selectedWineVarieties?.joined(separator: "\n") {
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
                    self.wineProducingCountryLabel.text = country
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
                self.wineVintageLabel.text = selectedVintage
            }
        }))
        alert.addAction(UIAlertAction(title: "선택 안 함", style: .default, handler: nil))
        
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
                    self.wineAromasAndFlavorsLabel.text = "향, 맛을 선택해 주세요."
                } else if self.selectedWineAromasAndFlavors?.count == 1 {
                    self.wineAromasAndFlavorsLabel.textColor = UIColor(named: "blackAndWhite")
                    self.wineAromasAndFlavorsLabel.text = self.selectedWineAromasAndFlavors!.first!
                } else {
                    if let wineAromasAndFlavorsString = self.selectedWineAromasAndFlavors?.joined(separator: ", ") {
                        self.wineAromasAndFlavorsLabel.textColor = UIColor(named: "blackAndWhite")
                        self.wineAromasAndFlavorsLabel.text = wineAromasAndFlavorsString
                    }
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "메모를 입력해 주세요." {
            textView.text = ""
            textView.textColor = UIColor(named: "blackAndWhite")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" || textView.text == "메모를 입력해 주세요." {
            textView.text = "메모를 입력해 주세요."
            textView.textColor = UIColor.systemGray2
        }
    }
    
    @IBAction func wineNameTextFieldEditingChanged(_ sender: UITextField) {
        if sender.text != "", firstImageView.image != nil  {
            doneButton.isUserInteractionEnabled = true
            doneButton.backgroundColor = UIColor.brown
        } else {
            doneButton.isUserInteractionEnabled = false
            doneButton.backgroundColor = UIColor.systemGray4
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "테이스팅 노트 등록", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [self] action in
            let date = wineTastingdate.date
            var place: String? = nil
            if wineTastingPlaceTextField.text == "" {
                place = nil
            } else {
                place = wineTastingPlaceTextField.text
            }
            let name = wineNameTextField.text ?? ""
            if let index = wineCategorySegmentedControl?.selectedSegmentIndex{
                if index > -1 && index < 5 {
                    selectedCateory = wineCategorySegmentedControl.titleForSegment(at: index)
                } else {
                    selectedCateory = nil
                }
            }
            var producer: String? = nil
            if wineProducerTextField.text == "" {
                producer = nil
            } else {
                producer = wineProducerTextField.text
            }
            if let priceString = winePriceTextField.text {
                if let p = Int32(priceString) {
                    price = p
                } else {
                    print("가격 입력 오류")
                }
            }
            if let alcoholContentString = wineAlcoholContentTextField.text {
                if let a = Float(alcoholContentString) {
                    alcoholContent = a
                } else {
                    print("알코올 도수 입력 오류")
                }
            }
            let sweet = sweetSegmentedControl.selectedSegmentIndex + 1
            let acidity = aciditySegmentedControl.selectedSegmentIndex + 1
            let tannin = tanninSegmentedControl.selectedSegmentIndex + 1
            let body = bodySegmentedControl.selectedSegmentIndex + 1
            let memo: String? = {
            if wineMemoTextView.text == "메모를 입력해 주세요." {
                let text: String? = nil
                return text
            } else {
                let text = wineMemoTextView.text
                return text
            }
            }()
            var selectedRating: Int16? = Int16(ratingSegmentedControl.selectedSegmentIndex) + 1
            if selectedRating == 0 {
                selectedRating = nil
            }
            
            let tastingNote = WineTastingNotes(tastingDate: date, place: place, wineName: name, category: selectedCateory, varieties: selectedWineVarieties, producingCountry: selectedWineProducingCountry, producer: producer, vintage: selectedVintage, price: price, alcoholContent: alcoholContent, sweet: Int16(sweet), acidity: Int16(acidity), tannin: Int16(tannin), body: Int16(body), aromasAndFlavors: selectedWineAromasAndFlavors, memo: memo, rating: selectedRating)
            
            //print(wineTastingNote)
            
            if Auth.auth().currentUser == nil {
                DataManager.shared.addWineTastingNote(tastingNote: tastingNote, images: selectedImages)
            } else {
                PostManager.shared.uploadPost(tastingNote: tastingNote, images: selectedImages) {result in
                    if result == true {
                        NotificationCenter.default.post(name: AddTastingNoteViewController.uploadPost, object: nil)
                    }
                }
            }
            
            dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
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

extension AddTastingNoteViewController {
    static let uploadPost = Notification.Name(rawValue: "uploadPost")
}
