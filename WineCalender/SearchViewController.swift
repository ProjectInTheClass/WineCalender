//
//  CameraTabController.swift
//  WineCalender
//
//  Created by 강재권 on 2021/06/17.
//
import UIKit
import SwiftyCam

class SearchViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    
    @IBOutlet weak var captureButton: SwiftyCamButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray

        cameraDelegate = self
        captureButton.layer.backgroundColor = UIColor.gray.cgColor
        captureButton.layer.borderWidth = 3
        captureButton.layer.borderColor = UIColor.white.cgColor
        captureButton.layer.cornerRadius = 38
        
        
        
       // shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureButton.delegate = self
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        self.photo = photo
        performSegue(withIdentifier: "photoSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoViewController {
            vc.photo = photo
        }
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        if flashMode == .auto {
            flashMode = .on
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControl.State())
        }else if flashMode == .on{
            flashMode = .off
            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControl.State())
        }else if flashMode == .off{
            flashMode = .auto
            flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        }
        
        print("Toggle flash mode: \(flashMode)")
    }
    
    @IBAction func cameraSwitchTapped(_ sender: Any) {
        switchCamera()
        print("Camera switched to \(currentCamera)")
    }
    
}
