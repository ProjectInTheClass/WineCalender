//
//  MyWinesFooterView.swift
//  WineCalender
//
//  Created by Minju Lee on 2022/02/06.
//

import UIKit
import Lottie

class MyWinesFooterView: UICollectionReusableView {
    
    let loadingAnimationView: AnimationView = {
        let aniView = AnimationView(name: "loading")
        aniView.contentMode = .scaleAspectFill
        aniView.loopMode = .loop
        aniView.layer.cornerRadius = 50
        aniView.translatesAutoresizingMaskIntoConstraints = false
        return aniView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(loadingAnimationView)

        NSLayoutConstraint.activate([
            loadingAnimationView.widthAnchor.constraint(equalToConstant: 100),
            loadingAnimationView.heightAnchor.constraint(equalToConstant: 100),
            loadingAnimationView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loadingAnimationView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadingAnimationPlay() {
        loadingAnimationView.play()
    }
    
    func loadingAnimationStop() {
        loadingAnimationView.stop()
    }
}
