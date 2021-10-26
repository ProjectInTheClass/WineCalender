//
//  WineAromasAndFlavorsCollectionViewController.swift
//  WineCalender
//
//  Created by Minju Lee on 2021/08/13.
//

import UIKit

class WineAromasAndFlavorsCollectionViewController: UICollectionViewController {
    
    lazy var selectedWineAromasAndFlavors: [String] = []
    
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

// MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return wineAromasAndFlavors0.count
        case 1:
            return wineAromasAndFlavors1.count
        case 2:
            return wineAromasAndFlavors2.count
        case 3:
            return wineAromasAndFlavors3.count
        default:
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WineAromasAndFlavorsCell", for: indexPath) as! WineAromasAndFlavorsCollectionViewCell
        
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 6
        
        if indexPath.section == 0 {
            let wineAromasAndFlavors = wineAromasAndFlavors0[indexPath.row]
            configureCellUI(section: 0, item: wineAromasAndFlavors)
        } else if indexPath.section == 1 {
            let wineAromasAndFlavors = wineAromasAndFlavors1[indexPath.row]
            configureCellUI(section: 1, item: wineAromasAndFlavors)
        } else if indexPath.section == 2 {
            let wineAromasAndFlavors = wineAromasAndFlavors2[indexPath.row]
            configureCellUI(section: 2, item: wineAromasAndFlavors)
        } else if indexPath.section == 3 {
            let wineAromasAndFlavors = wineAromasAndFlavors3[indexPath.row]
            configureCellUI(section: 3, item: wineAromasAndFlavors)
        }
        
        func configureCellUI(section: Int, item: String) {
            let wineAromasAndFlavors: String = item
            cell.wineAromasAndFlavorsLabel.text = wineAromasAndFlavors
            cell.layer.borderColor = UIColor(named: "postCard\(section)")!.cgColor
            if selectedWineAromasAndFlavors.contains(wineAromasAndFlavors) {
                cell.wineAromasAndFlavorsLabel.textColor = .label
                cell.backView.backgroundColor = UIColor(named: "postCard\(section)")!
            }
        }        
        return cell
    }

// MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! WineAromasAndFlavorsCollectionViewCell
        
        if indexPath.section == 0 {
            let wineAromasAndFlavors = wineAromasAndFlavors0[indexPath.row]
            configureCellUI(section: 0, item: wineAromasAndFlavors)
        } else if indexPath.section == 1 {
            let wineAromasAndFlavors = wineAromasAndFlavors1[indexPath.row]
            configureCellUI(section: 1, item: wineAromasAndFlavors)
        } else if indexPath.section == 2 {
            let wineAromasAndFlavors = wineAromasAndFlavors2[indexPath.row]
            configureCellUI(section: 2, item: wineAromasAndFlavors)
        } else if indexPath.section == 3 {
            let wineAromasAndFlavors = wineAromasAndFlavors3[indexPath.row]
            configureCellUI(section: 3, item: wineAromasAndFlavors)
        }
        
        func configureCellUI(section: Int, item: String) {
            if selectedWineAromasAndFlavors.contains(item) == false {
                cell.wineAromasAndFlavorsLabel.textColor = .label
                cell.backView.backgroundColor = UIColor(named: "postCard\(section)")!
                selectedWineAromasAndFlavors.append(item)
            } else {
                if let index = selectedWineAromasAndFlavors.firstIndex(of: item) {
                    cell.wineAromasAndFlavorsLabel.textColor = .systemGray2
                    cell.backView.backgroundColor = UIColor.systemBackground
                    selectedWineAromasAndFlavors.remove(at: index)
                }
            }
        }
    }
}
