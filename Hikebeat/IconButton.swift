//
//  IconButton.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class GreenIconButton: UIView {
    
    var iconImageView: UIImageView
    var textLabel: UILabel
    var button: UIButton
    var onPress = {}
    
    var oldBounds: CGRect?
    
    init(frame: CGRect, icon: UIImage, text: String, textColor: UIColor, boldText: Bool, ratio: CGFloat, onPress: @escaping () -> ()) {
        let ratioDivider = 1/ratio
        let padding:CGFloat = 7
        textLabel = UILabel(frame: CGRect(x: frame.width/ratioDivider , y: 0, width: frame.width/ratioDivider, height: frame.height))
        textLabel.text = text
        textLabel.textColor = textColor
        textLabel.textAlignment = .center
        if boldText {
            textLabel.font = UIFont.boldSystemFont(ofSize: 14)
        } else {
            textLabel.font = UIFont.systemFont(ofSize: 14)
        }
        textLabel.adjustsFontSizeToFitWidth = true
        let iconY = (frame.size.height - icon.size.height)/2
        iconImageView = UIImageView(frame: CGRect(x: padding, y: iconY, width: icon.size.width, height: icon.size.height))
        iconImageView.image = icon
        iconImageView.contentMode = .scaleAspectFit
        button = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.onPress = onPress
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(touchDownOnButton), for: .touchDown)
        self.layer.borderWidth = 1
        self.layer.borderColor = lightGreen.cgColor
        
        self.addSubview(textLabel)
        self.addSubview(iconImageView)
        self.addSubview(button)
        self.layer.cornerRadius = 7
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(text: String) {
        self.textLabel.text = text
    }
    
//    func hideIcon() {
//        self.iconImageView.isHidden = true
//        self.oldBounds = textLabel.bounds
//        self.textLabel.bounds = self.bounds
//    }
//    
//    func showIcon() {
//        self.iconImageView.isHidden = false
//        if oldBounds != nil {
//            self.textLabel.bounds = self.oldBounds!
//        }
//    }
//    
//    func change(text: String) {
//        self.textLabel.text = text
//    }
    
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
