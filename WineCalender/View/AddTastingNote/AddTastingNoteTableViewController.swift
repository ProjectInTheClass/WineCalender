//
//  AddTastingNoteTableViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/10/25.
//

import UIKit
import YPImagePicker
import FirebaseAuth

class AddTastingNoteTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, YPImagePickerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    var selectedImages: [UIImage] = []
    var selectedCateory: String?
    var selectedWineVarieties: [String]?
    var selectedWineProducingCountry: String?
    var selectedVintage: String?
    var selectedWineAromasAndFlavors: [String]?
    
    var price: Int32?
    var alcoholContent: Float?
    
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
    @IBOutlet weak var wineAromasAndFlavorsLabel: UILabel!
    @IBOutlet weak var sweetSegmentedControl: UISegmentedControl!
    @IBOutlet weak var aciditySegmentedControl: UISegmentedControl!
    @IBOutlet weak var tanninSegmentedControl: UISegmentedControl!
    @IBOutlet weak var bodySegmentedControl: UISegmentedControl!
    @IBOutlet weak var wineMemoTextView: UITextView!
    @IBOutlet weak var ratingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstImageView.layer.borderWidth = 1
        self.firstImageView.layer.borderColor = UIColor.systemPink.cgColor
        self.secondImageView.layer.borderWidth = 1
        self.secondImageView.layer.borderColor = UIColor.gray.cgColor
        self.thirdImageView.layer.borderWidth = 1
        self.thirdImageView.layer.borderColor = UIColor.gray.cgColor

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }

    @IBAction func keboardReturnKeyTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    // MARK: - image
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        var config = YPImagePickerConfiguration()
        config.isScrollToChangeModesEnabled = false
        config.screens = [.library, .photo]
        config.startOnScreen = .library
        config.library.maxNumberOfItems = 3
        config.library.mediaType = .photo
        config.library.onlySquare = true
        config.library.itemOverlayType = .grid
        config.usesFrontCamera = false
        config.maxCameraZoomFactor = 2.0
        config.showsPhotoFilters = true
        config.onlySquareImagesFromCamera = true
        config.shouldSaveNewPicturesToAlbum = false
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.hidesCancelButton = false
        config.gallery.hidesRemoveButton = false
        
        config.wordings.libraryTitle = "앨범"
        config.wordings.cancel = "취소"
        config.wordings.next = "다음"
        config.wordings.albumsTitle = "앨범"
        config.wordings.cameraTitle = "카메라"
        config.wordings.done = "완료"
        config.wordings.filter = "필터"
        config.wordings.warningMaxItemsLimit = "최대 3장까지 선택할 수 있습니다."
        config.colors.tintColor = .label
        config.colors.multipleItemsSelectedCircleColor = .systemPurple

        let picker = YPImagePicker(configuration: config)
        picker.imagePickerDelegate = self
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        picker.navigationBar.scrollEdgeAppearance = navBarAppearance
        
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
                        self.firstImageView.layer.borderColor = UIColor.gray.cgColor
                        if self.wineNameTextField.text != "" {
                            self.doneButton.isEnabled = true
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
    
    // MARK: - name
    @IBAction func wineNameTextFieldEditingChanged(_ sender: UITextField) {
        if sender.text != "", firstImageView.image != nil  {
            doneButton.isEnabled = true
            self.firstImageView.layer.borderColor = UIColor.gray.cgColor
        } else {
            doneButton.isEnabled = false
            self.firstImageView.layer.borderColor = UIColor.systemPink.cgColor
        }
    }
    
    // MARK: - varieties
    @IBAction func wineVarietiesButtonTapped(_ sender: UIButton) {
        if let WineVarietiesTVC = storyboard?.instantiateViewController(identifier: "WineVarietiesTVC") as? WineVarietiesTableViewController {
            WineVarietiesTVC.selectedWineVarieties = selectedWineVarieties ?? []
            self.navigationController?.pushViewController(WineVarietiesTVC, animated: true)
            
            WineVarietiesTVC.completionHandler = { wineVarieties in
                self.selectedWineVarieties = wineVarieties
                if self.selectedWineVarieties == [] {
                    self.wineVarietiesLabel.textColor = .systemGray2
                    self.wineVarietiesLabel.text = "포도 품종 선택"
                } else if self.selectedWineVarieties?.count == 1 {
                    self.wineVarietiesLabel.textColor = .label
                    self.wineVarietiesLabel.text = self.selectedWineVarieties!.first!
                } else {
                    if let wineVarietiesString = self.selectedWineVarieties?.joined(separator: "\n") {
                        self.wineVarietiesLabel.textColor = .label
                        self.wineVarietiesLabel.text = wineVarietiesString
                    }
                }
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
    
    // MARK: - producing country
    @IBAction func wineProducingCountryButtonTapped(_ sender: UIButton) {
        if let wineProducingCountriesTVC = storyboard?.instantiateViewController(identifier: "WineProducingCountriesTVC") as? WineProducingCountriesTableViewController {
            wineProducingCountriesTVC.selectedCountry = self.selectedWineProducingCountry ?? ""
            self.navigationController?.pushViewController(wineProducingCountriesTVC, animated: true)
            
            wineProducingCountriesTVC.completionHandler = { country in
                self.selectedWineProducingCountry = country
                if let country = self.selectedWineProducingCountry {
                    self.wineProducingCountryLabel.textColor = .label
                    self.wineProducingCountryLabel.text = country
                }
            }
        }
    }
    
    // MARK: - vintage
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
                self.wineVintageLabel.textColor = .label
                self.wineVintageLabel.text = selectedVintage
            }
        }))
        alert.addAction(UIAlertAction(title: "선택 안 함", style: .default, handler: {_ in
            self.selectedVintage = nil
            self.wineVintageLabel.text = "빈티지 선택"
            self.wineVintageLabel.textColor = .systemGray2
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    //UIPickerViewDataSource, UIPickerViewDelegate
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
    
    // MARK: - price
    @IBAction func winePriceTextFieldEditingChanged(_ sender: UITextField) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        guard let currentText = sender.text else { return }
        let commaRemovedString = currentText.replacingOccurrences(of: ",", with: "")
        
        if let p = Int32(commaRemovedString) {
            price = p
            sender.text = numberFormatter.string(for: p)
        } else {
            price = nil
            sender.text = ""
        }
    }
    
    // MARK: - alcohol content
    @IBAction func wineAlcoholContentTextFieldEditingChanged(_ sender: UITextField) {
        guard let currentText = sender.text else { return }
        if let a = Float(currentText) {
            alcoholContent = a
        } else {
            alcoholContent = nil
            sender.text = ""
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if textField == winePriceTextField {
            return updatedText.count <= 11
        } else if textField == wineAlcoholContentTextField {
            return updatedText.count <= 5
        } else {
            return updatedText.count <= 1
        }
    }    
    
    // MARK: - aromas and flavors
    @IBAction func wineAromasAndFlavorsButtonTapped(_ sender: UIButton) {
        if let wineAromasAndFlavorsCVC = storyboard?.instantiateViewController(identifier: "wineAromasAndFlavorsCVC") as? WineAromasAndFlavorsCollectionViewController {
            wineAromasAndFlavorsCVC.selectedWineAromasAndFlavors = selectedWineAromasAndFlavors ?? []
            self.navigationController?.pushViewController(wineAromasAndFlavorsCVC, animated: true)
            
            wineAromasAndFlavorsCVC.completionHandler = { aromasAndFlavors in
                self.selectedWineAromasAndFlavors = aromasAndFlavors
                if self.selectedWineAromasAndFlavors == [] {
                    self.wineAromasAndFlavorsLabel.textColor = .systemGray2
                    self.wineAromasAndFlavorsLabel.text = "향, 맛 선택"
                } else if self.selectedWineAromasAndFlavors?.count == 1 {
                    self.wineAromasAndFlavorsLabel.textColor = .label
                    self.wineAromasAndFlavorsLabel.text = self.selectedWineAromasAndFlavors!.first!
                } else {
                    if let wineAromasAndFlavorsString = self.selectedWineAromasAndFlavors?.joined(separator: ", ") {
                        self.wineAromasAndFlavorsLabel.textColor = .label
                        self.wineAromasAndFlavorsLabel.text = wineAromasAndFlavorsString
                    }
                }
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
    
    // MARK: - memo UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "와인 테이스팅 메모를 입력해 주세요." {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.tableView.layoutIfNeeded()
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" || textView.text == "와인 테이스팅 메모를 입력해 주세요." {
            textView.text = "와인 테이스팅 메모를 입력해 주세요."
            textView.textColor = UIColor.systemGray2
        }
    }
    
    // MARK: - cancel and done
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "작성 취소", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
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
            
            var sweet: Int16? = Int16(sweetSegmentedControl.selectedSegmentIndex) + 1
            if sweet == 6 {
                sweet = nil
            }
            var acidity: Int16? = Int16(aciditySegmentedControl.selectedSegmentIndex) + 1
            if acidity == 6 {
                acidity = nil
            }
            var tannin: Int16? = Int16(tanninSegmentedControl.selectedSegmentIndex) + 1
            if tannin == 6 {
                tannin = nil
            }
            var body: Int16? = Int16(bodySegmentedControl.selectedSegmentIndex) + 1
            if body == 6 {
                body = nil
            }
            let memo: String? = {
                if wineMemoTextView.text == "와인 테이스팅 메모를 입력해 주세요." {
                    let text: String? = nil
                    return text
                } else {
                    let text = wineMemoTextView.text
                    return text
                }
            }()
            var rating: Int16? = Int16(ratingSegmentedControl.selectedSegmentIndex) + 1
            if rating == 6 {
                rating = nil
            }
            
            let tastingNote = WineTastingNotes(tastingDate: date, place: place, wineName: name, category: selectedCateory, varieties: selectedWineVarieties, producingCountry: selectedWineProducingCountry, producer: producer, vintage: selectedVintage, price: price, alcoholContent: alcoholContent, sweet: sweet, acidity: acidity, tannin: tannin, body: body, aromasAndFlavors: selectedWineAromasAndFlavors, memo: memo, rating: rating)

            if Auth.auth().currentUser == nil {
                DataManager.shared.addWineTastingNote(tastingNote: tastingNote, images: selectedImages)
                NotificationCenter.default.post(name: AddTastingNoteTableViewController.uploadPost, object: nil)
            } else {
                PostManager.shared.uploadPost(tastingNote: tastingNote, images: selectedImages) {result in
                    if result == true {
                        NotificationCenter.default.post(name: AddTastingNoteTableViewController.uploadPost, object: nil)
                    }
                }
            }
            dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 8
        case 2:
            return 7
        default:
            return 0
        }
    }
}

extension AddTastingNoteTableViewController {
    static let uploadPost = Notification.Name(rawValue: "uploadPost")
}
