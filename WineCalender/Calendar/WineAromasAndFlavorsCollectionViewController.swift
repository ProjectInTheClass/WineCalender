//
//  WineAromasAndFlavorsCollectionViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/13.
//

import UIKit

class WineAromasAndFlavorsCollectionViewController: UICollectionViewController {
    
    lazy var selectedWineAromasAndFlavors: [String] = [] {
        didSet {
            print(selectedWineAromasAndFlavors)
        }
    }
    
    var completionHandler: (([String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        if let completionHandler = completionHandler {
            completionHandler(selectedWineAromasAndFlavors)
        }
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

// MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wineAromasAndFlavors.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WineAromasAndFlavorsCell", for: indexPath) as! WineAromasAndFlavorsCollectionViewCell
        let wineAromasAndFlavors = wineAromasAndFlavors[indexPath.row]
        cell.wineAromasAndFlavorsLabel.text = wineAromasAndFlavors
        if selectedWineAromasAndFlavors.contains(wineAromasAndFlavors) {
            cell.contentView.layer.borderWidth = 2.0
            cell.contentView.layer.borderColor = UIColor.brown.cgColor
            cell.wineAromasAndFlavorsLabel.textColor = UIColor(named: "whiteAndBlack")
        }
        return cell
    }

// MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! WineAromasAndFlavorsCollectionViewCell
        if selectedWineAromasAndFlavors.contains(wineAromasAndFlavors[indexPath.row]) == false {
            cell.contentView.layer.borderWidth = 2.0
            cell.contentView.layer.borderColor = UIColor.brown.cgColor
            cell.wineAromasAndFlavorsLabel.textColor = UIColor(named: "whiteAndBlack")
            selectedWineAromasAndFlavors.append(wineAromasAndFlavors[indexPath.row])
        } else {
            if let index = selectedWineAromasAndFlavors.firstIndex(of: wineAromasAndFlavors[indexPath.row]) {
                cell.contentView.layer.borderWidth = 0
                cell.wineAromasAndFlavorsLabel.textColor = .systemGray2
                selectedWineAromasAndFlavors.remove(at: index)
            }
        }
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
