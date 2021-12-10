//
//  WineDetailController.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/12/10.
//

import UIKit
import PanModal

struct WineDetailVM {
    let name: String
    let category: String
    let varieties: String
    let producingCountry: String
    let producer: String
    let vintage: String
    let price: String
    let alcoholContent: String
    let aromasAndFlavors: String
    let sweet: Int
    let acidity: Int
    let tannin: Int
    let body: Int
    let memo: String
    let rating: Int
    
    init(_ tastingNote: WineTastingNote) {
        self.name = tastingNote.wineName
        
        self.category = tastingNote.category ?? ""
        self.varieties = (tastingNote.varieties ?? []).joined(separator: " | ")
        self.producingCountry = tastingNote.producingCountry ?? ""
        self.producer = tastingNote.producer ?? ""
        self.vintage = tastingNote.vintage ?? ""
        
        self.price = tastingNote.price > 0 ? "₩ \(tastingNote.price)" : ""
        self.alcoholContent = "\(tastingNote.alcoholContent) %"
        
        self.aromasAndFlavors = (tastingNote.aromasAndFlavors ?? []).compactMap{$0}.joined(separator: ", ")
        self.sweet = Int(tastingNote.sweet)
        self.acidity = Int(tastingNote.acidity)
        self.tannin = Int(tastingNote.tannin)
        self.body = Int(tastingNote.body)
        
        self.memo = tastingNote.memo ?? ""
        self.rating = Int((tastingNote.rating - 1) % 6)
    }
}

class WineDetailController: UITableViewController {
    
    var viewModel: WineDetailVM?
    
    @IBOutlet weak var wineNameTF: UITextField!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var varietyTF: UITextField!
    @IBOutlet weak var countryTF: UITextField!
    @IBOutlet weak var producerTF: UITextField!
    @IBOutlet weak var vintageTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var alcoholTF: UITextField!
    @IBOutlet weak var aromaAndFlavor: UITextField!
    @IBOutlet weak var sweetnessSC: UISegmentedControl!
    @IBOutlet weak var aciditySC: UISegmentedControl!
    @IBOutlet weak var tanninSC: UISegmentedControl!
    @IBOutlet weak var bodySC: UISegmentedControl!
    @IBOutlet weak var tastingNoteTV: UITextView!
    @IBOutlet weak var ratingSC: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
    }
    
    func updateView() {
        guard let vm = viewModel else { return }
        wineNameTF.text = vm.name
        categoryTF.text = vm.category
        varietyTF.text = vm.varieties
        countryTF.text = vm.producingCountry
        producerTF.text = vm.producer
        vintageTF.text = vm.vintage
        priceTF.text = vm.price
        alcoholTF.text = vm.alcoholContent
        aromaAndFlavor.text = vm.aromasAndFlavors
        sweetnessSC.selectedSegmentIndex = vm.sweet
        aciditySC.selectedSegmentIndex = vm.acidity
        tanninSC.selectedSegmentIndex = vm.tannin
        bodySC.selectedSegmentIndex = vm.body
        tastingNoteTV.text = vm.memo
        ratingSC.selectedSegmentIndex = vm.rating
    }
}

extension WineDetailController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        tableView
    }
    
    var longFormHeight: PanModalHeight {
        .contentHeight(500)
    }
}

