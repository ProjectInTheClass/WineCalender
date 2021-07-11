//
//  CameraTabController.swift
//  WineCalender
//
//  Created by 강재권 on 2021/06/17.
//
import UIKit
import SwiftyCam

class SearchViewController :  SwiftyCamViewController ,SwiftyCamViewControllerDelegate {
    
    @IBOutlet weak var CaptureButton: UIButton!
    
//
//        = {
//            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//            button.layer.cornerRadius = 50
//            button.layer.borderWidth = 10
//            button.layer.borderColor = UIColor.white.cgColor
//
//            return button
//        }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray

        cameraDelegate = self
        
       // shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
    }
    
    
    
    
    @IBAction func ChageCam(_ sender: Any) {
        switchCamera()
    }
    
}
