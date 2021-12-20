//
//  AddTastingNoteTableViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/10/25.
//

import UIKit
import YPImagePicker
import FirebaseAuth
import Lottie

class AddTastingNoteTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, YPImagePickerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    lazy var postID: String? = nil
    lazy var updatePost: Post? = nil
    lazy var updateNote: WineTastingNote? = nil
    
    var selectedImages: [UIImage] = []
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
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var imageWarningLabel: UILabel!
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
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        configureUI()
        configureImageViewsUI()
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }

    @IBAction func keboardReturnKeyTapped(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    func configureUI() {
        if self.postID != nil {
            self.navigationItem.title = "테이스팅 노트 수정"
            self.doneButton.isEnabled = true
            setupDataForUpdatePost()
        } else if self.updateNote != nil {
            self.navigationItem.title = "테이스팅 노트 수정"
            self.doneButton.isEnabled = true
            setupDataForUpdateNote()
        } else {
            self.navigationItem.title = "테이스팅 노트 작성"
        }
    }
    
    func setupDataForUpdatePost() {
        PostManager.shared.fetchMyPost(postID: self.postID ?? "") { myPost in
            self.updatePost = myPost
            
            self.wineTastingdate.date = self.updatePost?.tastingNote.tastingDate ?? Date()
            self.wineTastingPlaceTextField.text = self.updatePost?.tastingNote.place
            let numberOfPostImage = self.updatePost?.postImageURL.count
            if numberOfPostImage == 1 {
                self.firstImageView.kf.setImage(with: URL(string: self.updatePost?.postImageURL[0] ?? ""))
            }
            if numberOfPostImage == 2 {
                self.firstImageView.kf.setImage(with: URL(string: self.updatePost?.postImageURL[0] ?? ""))
                self.secondImageView.kf.setImage(with: URL(string: self.updatePost?.postImageURL[1] ?? ""))
            }
            if numberOfPostImage == 3 {
                self.firstImageView.kf.setImage(with: URL(string: self.updatePost?.postImageURL[0] ?? ""))
                self.secondImageView.kf.setImage(with: URL(string: self.updatePost?.postImageURL[1] ?? ""))
                self.thirdImageView.kf.setImage(with: URL(string: self.updatePost?.postImageURL[2] ?? ""))
            }
            self.wineNameTextField.text = self.updatePost?.tastingNote.wineName
            for index in 0...4 {
                if self.wineCategorySegmentedControl.titleForSegment(at: index) == self.updatePost?.tastingNote.category {
                    self.wineCategorySegmentedControl.selectedSegmentIndex = index
                }
            }
            self.selectedWineVarieties = self.updatePost?.tastingNote.varieties
            self.setupWineVarietiesLable()
            self.selectedWineProducingCountry = self.updatePost?.tastingNote.producingCountry
            self.setupWineProducingCoutryLable()
            self.wineProducerTextField.text = self.updatePost?.tastingNote.producer
            self.selectedVintage = self.updatePost?.tastingNote.vintage
            self.setupWineVintageLable()
            if let p = self.updatePost?.tastingNote.price {
                self.price = p
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                self.winePriceTextField.text = numberFormatter.string(for: p)
            }
            if let ac = self.updatePost?.tastingNote.alcoholContent {
                self.alcoholContent = ac
                let alcoholContentString = String(ac)
//                alcoholContentString = alcoholContentString.replacingOccurrences(of: ".0", with: "")
                self.wineAlcoholContentTextField.text = alcoholContentString
            }
            self.selectedWineAromasAndFlavors = self.updatePost?.tastingNote.aromasAndFlavors
            self.setupWineAromasAndFlavorsLable()
            if let s = self.updatePost?.tastingNote.sweet {
                for index in 0...4 {
                    if self.sweetSegmentedControl.titleForSegment(at: index) == String(s) {
                        self.sweetSegmentedControl.selectedSegmentIndex = index
                    }
                }
            }
            if let a = self.updatePost?.tastingNote.acidity {
                for index in 0...4 {
                    if self.aciditySegmentedControl.titleForSegment(at: index) == String(a) {
                        self.aciditySegmentedControl.selectedSegmentIndex = index
                    }
                }
            }
            if let t = self.updatePost?.tastingNote.tannin {
                for index in 0...4 {
                    if self.tanninSegmentedControl.titleForSegment(at: index) == String(t) {
                        self.tanninSegmentedControl.selectedSegmentIndex = index
                    }
                }
            }
            if let b = self.updatePost?.tastingNote.body {
                for index in 0...4 {
                    if self.bodySegmentedControl.titleForSegment(at: index) == String(b) {
                        self.bodySegmentedControl.selectedSegmentIndex = index
                    }
                }
            }
            if let memo = self.updatePost?.tastingNote.memo {
                self.wineMemoTextView.text = memo
                self.wineMemoTextView.textColor = .label
            }
            if let r = self.updatePost?.tastingNote.rating {
                for index in 0...4 {
                    if self.ratingSegmentedControl.titleForSegment(at: index) == String(r) {
                        self.ratingSegmentedControl.selectedSegmentIndex = index
                    }
                }
            }
        }
    }
    
    func setupDataForUpdateNote() {
        self.wineTastingdate.date = updateNote?.tastingDate ?? Date()
        self.wineTastingPlaceTextField.text = updateNote?.place
        let numberOfPostImage = updateNote?.image.count
        if numberOfPostImage == 1 {
            self.firstImageView.image = updateNote?.image[0]
        }
        if numberOfPostImage == 2 {
            self.firstImageView.image = updateNote?.image[0]
            self.secondImageView.image = updateNote?.image[1]
        }
        if numberOfPostImage == 3 {
            self.firstImageView.image = updateNote?.image[0]
            self.secondImageView.image = updateNote?.image[1]
            self.thirdImageView.image = updateNote?.image[2]
        }
        self.wineNameTextField.text = updateNote?.wineName
        for index in 0...4 {
            if wineCategorySegmentedControl.titleForSegment(at: index) == updateNote?.category {
                wineCategorySegmentedControl.selectedSegmentIndex = index
            }
        }
        self.selectedWineVarieties = updateNote?.varieties
        self.setupWineVarietiesLable()
        self.selectedWineProducingCountry = updateNote?.producingCountry
        self.setupWineProducingCoutryLable()
        self.wineProducerTextField.text = updateNote?.producer
        self.selectedVintage = updateNote?.vintage
        self.setupWineVintageLable()
        if let p = updateNote?.price {
            if p != 0 {
                self.price = p
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = .decimal
                self.winePriceTextField.text = numberFormatter.string(for: p)
            }
        }
        if let ac = updateNote?.alcoholContent {
            if ac != 0 {
                self.alcoholContent = ac
                var alcoholContentString = String(ac)
                if alcoholContentString.hasSuffix(".0") {
                    alcoholContentString.removeLast()
                    alcoholContentString.removeLast()
                }
                self.wineAlcoholContentTextField.text = alcoholContentString
            }
        }
        self.selectedWineAromasAndFlavors = updateNote?.aromasAndFlavors
        self.setupWineAromasAndFlavorsLable()
        if let s = updateNote?.sweet {
            for index in 0...4 {
                if sweetSegmentedControl.titleForSegment(at: index) == String(s) {
                    sweetSegmentedControl.selectedSegmentIndex = index
                }
            }
        }
        if let a = updateNote?.acidity {
            for index in 0...4 {
                if aciditySegmentedControl.titleForSegment(at: index) == String(a) {
                    aciditySegmentedControl.selectedSegmentIndex = index
                }
            }
        }
        if let t = updateNote?.tannin {
            for index in 0...4 {
                if tanninSegmentedControl.titleForSegment(at: index) == String(t) {
                    tanninSegmentedControl.selectedSegmentIndex = index
                }
            }
        }
        if let b = updateNote?.body {
            for index in 0...4 {
                if bodySegmentedControl.titleForSegment(at: index) == String(b) {
                    bodySegmentedControl.selectedSegmentIndex = index
                }
            }
        }
        if let memo = updateNote?.memo {
            self.wineMemoTextView.text = memo
            self.wineMemoTextView.textColor = .label
        }
        if let r = updateNote?.rating {
            for index in 0...4 {
                if ratingSegmentedControl.titleForSegment(at: index) == String(r) {
                    ratingSegmentedControl.selectedSegmentIndex = index
                }
            }
        }
    }
    
    // MARK: - image
    func configureImageViewsUI() {
        self.firstImageView.layer.borderWidth = 1
        if self.postID != nil || self.updateNote != nil {
            self.firstImageView.layer.borderColor = UIColor.gray.cgColor
            self.addImageButton.isHidden = true
            self.imageWarningLabel.isHidden = true
        } else {
            self.firstImageView.layer.borderColor = UIColor.systemPink.cgColor
        }
        self.secondImageView.layer.borderWidth = 1
        self.secondImageView.layer.borderColor = UIColor.gray.cgColor
        self.thirdImageView.layer.borderWidth = 1
        self.thirdImageView.layer.borderColor = UIColor.gray.cgColor
    }
    
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
                    self.selectedImages = selectedItems
                    self.firstImageView.layer.borderColor = UIColor.gray.cgColor
                    self.imageWarningLabel.isHidden = true
                    if self.wineNameTextField.text != "" {
                        self.doneButton.isEnabled = true
                    }
                    picker?.dismiss(animated: true, completion: nil)
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
        if sender.text != "", firstImageView.image != nil {
            doneButton.isEnabled = true
        }
        if sender.text == "" {
            doneButton.isEnabled = false
        }
    }
    
    // MARK: - varieties
    @IBAction func wineVarietiesButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if let WineVarietiesTVC = storyboard?.instantiateViewController(identifier: "WineVarietiesTVC") as? WineVarietiesTableViewController {
            WineVarietiesTVC.selectedWineVarieties = selectedWineVarieties ?? []
            self.navigationController?.pushViewController(WineVarietiesTVC, animated: true)
            
            WineVarietiesTVC.completionHandler = { wineVarieties in
                self.selectedWineVarieties = wineVarieties
                self.setupWineVarietiesLable()
            }
        }
    }
    
    func setupWineVarietiesLable() {
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
    
    // MARK: - producing country
    @IBAction func wineProducingCountryButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if let wineProducingCountriesTVC = storyboard?.instantiateViewController(identifier: "WineProducingCountriesTVC") as? WineProducingCountriesTableViewController {
            wineProducingCountriesTVC.selectedCountry = self.selectedWineProducingCountry ?? ""
            self.navigationController?.pushViewController(wineProducingCountriesTVC, animated: true)
            
            wineProducingCountriesTVC.completionHandler = { country in
                self.selectedWineProducingCountry = country
                self.setupWineProducingCoutryLable()
            }
        }
    }
    
    func setupWineProducingCoutryLable() {
        if let country = self.selectedWineProducingCountry {
            self.wineProducingCountryLabel.textColor = .label
            self.wineProducingCountryLabel.text = country
        }
    }
    
    // MARK: - vintage
    @IBAction func wineVintageButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
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
            self.setupWineVintageLable()
        }))
        alert.addAction(UIAlertAction(title: "선택 안 함", style: .default, handler: {_ in
            self.selectedVintage = nil
            self.wineVintageLabel.text = "빈티지 선택"
            self.wineVintageLabel.textColor = .systemGray2
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func setupWineVintageLable() {
        if let selectedVintage = self.selectedVintage {
            self.wineVintageLabel.textColor = .label
            self.wineVintageLabel.text = selectedVintage
        }
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
        self.view.endEditing(true)
        if let wineAromasAndFlavorsCVC = storyboard?.instantiateViewController(identifier: "wineAromasAndFlavorsCVC") as? WineAromasAndFlavorsCollectionViewController {
            wineAromasAndFlavorsCVC.selectedWineAromasAndFlavors = selectedWineAromasAndFlavors ?? []
            self.navigationController?.pushViewController(wineAromasAndFlavorsCVC, animated: true)
            
            wineAromasAndFlavorsCVC.completionHandler = { aromasAndFlavors in
                self.selectedWineAromasAndFlavors = aromasAndFlavors
                self.setupWineAromasAndFlavorsLable()
            }
        }
    }
    
    func setupWineAromasAndFlavorsLable() {
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
    
    // MARK: - memo UITextViewDelegate
    let memoTextViewPlaceholder = "와인 테이스팅 메모를 입력해 주세요."
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == memoTextViewPlaceholder {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" || textView.text == memoTextViewPlaceholder {
            textView.text = memoTextViewPlaceholder
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
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
            
            let animationView: AnimationView = {
                let aniView = AnimationView(name: "swirling-wine")
                aniView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                aniView.contentMode = .scaleAspectFill
                aniView.loopMode = .loop
                aniView.backgroundColor = .white
                aniView.layer.cornerRadius = 50
                return aniView
            }()
            
            func animationPlay() {
                self.tableView.isUserInteractionEnabled = false
                self.cancelButton.isEnabled = false
                self.doneButton.isEnabled = false
                self.view.superview?.addSubview(animationView)
                animationView.center = self.view.center
                animationView.play()
            }
            
            func animationStop() {
                animationView.stop()
                animationView.removeFromSuperview()
                self.tableView.isUserInteractionEnabled = true
                self.cancelButton.isEnabled = true
                self.doneButton.isEnabled = true
            }
            
            animationPlay()
            
            let date = self.wineTastingdate.date
            var place: String? = nil
            if self.wineTastingPlaceTextField.text == "" {
                place = nil
            } else {
                place = self.wineTastingPlaceTextField.text
            }
            let name = self.wineNameTextField.text ?? ""
            let selectedCategoryIndex = self.wineCategorySegmentedControl.selectedSegmentIndex
            let category = self.wineCategorySegmentedControl.titleForSegment(at: selectedCategoryIndex)
            var producer: String? = nil
            if self.wineProducerTextField.text == "" {
                producer = nil
            } else {
                producer = self.wineProducerTextField.text
            }
            var sweet: Int16? = Int16(self.sweetSegmentedControl.selectedSegmentIndex) + 1
            if sweet == 6 {
                sweet = nil
            }
            var acidity: Int16? = Int16(self.aciditySegmentedControl.selectedSegmentIndex) + 1
            if acidity == 6 {
                acidity = nil
            }
            var tannin: Int16? = Int16(self.tanninSegmentedControl.selectedSegmentIndex) + 1
            if tannin == 6 {
                tannin = nil
            }
            var body: Int16? = Int16(self.bodySegmentedControl.selectedSegmentIndex) + 1
            if body == 6 {
                body = nil
            }
            let memo: String? = {
                if self.wineMemoTextView.text == self.memoTextViewPlaceholder {
                    let text: String? = nil
                    return text
                } else {
                    let text = self.wineMemoTextView.text
                    return text
                }
            }()
            var rating: Int16? = Int16(self.ratingSegmentedControl.selectedSegmentIndex) + 1
            if rating == 6 {
                rating = nil
            }
            
            let tastingNote = WineTastingNotes(tastingDate: date, place: place, wineName: name, category: category, varieties: self.selectedWineVarieties, producingCountry: self.selectedWineProducingCountry, producer: producer, vintage: self.selectedVintage, price: self.price, alcoholContent: self.alcoholContent, sweet: sweet, acidity: acidity, tannin: tannin, body: body, aromasAndFlavors: self.selectedWineAromasAndFlavors, memo: memo, rating: rating)
            
            if Auth.auth().currentUser == nil {
                //비회원 - 처음 작성
                if self.updateNote == nil {
                    DataManager.shared.addWineTastingNote(posting: nil, updated: nil, tastingNote: tastingNote, images: self.selectedImages, completion: { result in
                        if result == true {
                            animationStop()
                            NotificationCenter.default.post(name: MyWinesViewController.uploadUpdateDelete, object: nil)
                        }
                    })
                } else {
                    //비회원 - 수정
                    self.updateNote?.updatedDate = Date()
                    self.updateNote?.tastingDate = date
                    self.updateNote?.place = place
                    self.updateNote?.wineName = name
                    self.updateNote?.category = category
                    self.updateNote?.varieties = self.selectedWineVarieties
                    self.updateNote?.producingCountry = self.selectedWineProducingCountry
                    self.updateNote?.producer = producer
                    self.updateNote?.vintage = self.selectedVintage
                    self.updateNote?.price = self.price ?? 0
                    self.updateNote?.alcoholContent = self.alcoholContent ?? 0
                    self.updateNote?.sweet = sweet ?? 0
                    self.updateNote?.acidity = acidity ?? 0
                    self.updateNote?.tannin = tannin ?? 0
                    self.updateNote?.body = body ?? 0
                    self.updateNote?.aromasAndFlavors = self.selectedWineAromasAndFlavors
                    self.updateNote?.memo = memo
                    self.updateNote?.rating = rating ?? 0
                    DataManager.shared.updateWineTastingNote(completion: { result in
                        if result == true {
                            animationStop()
                            NotificationCenter.default.post(name: MyWinesViewController.uploadUpdateDelete, object: nil)
                        }
                    })
                }
                self.dismiss(animated: true, completion: nil)
            } else {
                if self.updatePost == nil {
                    //회원 - 처음 작성
                    PostManager.shared.uploadPost(posting: nil, updated: nil, tastingNote: tastingNote, images: self.selectedImages) {result in
                        switch result {
                        case .success(_):
                            animationStop()
                            NotificationCenter.default.post(name: MyWinesViewController.uploadUpdateDelete, object: nil)
                            self.dismiss(animated: true, completion: nil)
                        case .failure(let error):
                            animationStop()
                            let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                } else {
                    //회원 - 수정
                    PostManager.shared.updateMyPost(postID: self.updatePost?.postID ?? "", tastingNote: tastingNote) { result in
                        switch result {
                        case .success(_):
                            animationStop()
                            NotificationCenter.default.post(name: MyWinesViewController.uploadUpdateDelete, object: nil)
                            self.dismiss(animated: true, completion: nil)
//                            let navVC = self.presentingViewController?.children.first
//                            let postDetailVC = navVC?.children.last
                            //데이터넘기기?
                        case .failure(let error):
                            animationStop()
                            let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
//            dismiss(animated: true, completion: nil)
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
