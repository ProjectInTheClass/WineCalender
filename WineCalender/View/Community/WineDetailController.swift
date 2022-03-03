//
//  WineDetailController.swift
//  WineCalender
//
//  Created by JaeKwon on 2021/12/10.
//

import UIKit
import PanModal

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
        
        [wineNameTF, categoryTF, varietyTF, countryTF, producerTF, vintageTF, priceTF, alcoholTF, aromaAndFlavor, sweetnessSC, tanninSC, bodySC, tastingNoteTV, ratingSC].forEach { view in
            view?.isUserInteractionEnabled = false
        }
        
        [wineNameTF, categoryTF, varietyTF, countryTF, producerTF, vintageTF, priceTF, alcoholTF, aromaAndFlavor].forEach { textView in
            textView?.minimumFontSize = 1
        }
        
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

