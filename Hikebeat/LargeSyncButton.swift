//
//  LargeSyncButton.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 12/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class LargeSyncButton: UIView {
    var textLabel: UILabel
    var button: UIButton
    var onPress = {}
    var inSync = false
    //    var innerView: UIView
    
    var oldBounds: CGRect?
    
    init(frame: CGRect, inSync: Bool, onPress: @escaping () -> ()) {
        self.inSync = inSync
        textLabel = UILabel(frame: CGRect(x: 0 , y: 0, width: frame.width, height: frame.height))
        textLabel.textColor = lightGreen
        textLabel.textAlignment = .center
        textLabel.font = UIFont.boldSystemFont(ofSize: 13)
        textLabel.adjustsFontSizeToFitWidth = true
        button = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        super.init(frame: frame)
        self.backgroundColor = darkGreen
        self.onPress = onPress
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(touchDownOnButton), for: .touchDown)
        if inSync {
            self.setToInSync()
        } else {
            self.setToNotInSync()
        }
        self.layer.borderWidth = 1
        self.layer.borderColor = lightGreen.cgColor
        
        self.addSubview(textLabel)
        self.addSubview(button)
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setToInSync() {
        change(text: "Up to date")
        self.layer.borderColor = lightGreen.cgColor
        self.textLabel.textColor = lightGreen
    }
    
    func setToNotInSync() {
        change(text: "Go to sync")
        self.layer.borderColor = yellowColor.cgColor
        self.textLabel.textColor = yellowColor
    }
    
    func change(text: String) {
        self.textLabel.text = text
    }
    
    func buttonTapped() {
        self.alpha = 1
        self.onPress()
    }
    
    func touchDownOnButton() {
        self.alpha = 0.5
    }
    
    func touchUpOutside() {
        self.alpha = 1
    }
    
    
}
