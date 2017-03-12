//
//  LargeFollowButton.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class LargeFollowButton: UIView {
    var iconImageView: UIImageView
    var textLabel: UILabel
    var unFollowingTextLabel: UILabel
    var button: UIButton
    var onPress = {}
    var isFollowing = false
//    var innerView: UIView
    
    var oldBounds: CGRect?
    
    init(frame: CGRect, isFollowing: Bool, onPress: @escaping () -> ()) {
        self.isFollowing = isFollowing
        let innerView = UIView(frame: CGRect(x: frame.width/6, y: 0, width: frame.width-frame.width/3, height: frame.height))
        textLabel = UILabel(frame: CGRect(x: frame.width/5 , y: 0, width: (frame.width/2), height: frame.height))
        textLabel.text = "Following"
        textLabel.textColor = lightGreen
        textLabel.textAlignment = .left
        textLabel.font = UIFont.boldSystemFont(ofSize: 13)
        textLabel.adjustsFontSizeToFitWidth = true
        iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width/8, height: frame.height))
        iconImageView.image = UIImage(named: "Checkcheck")
        iconImageView.contentMode = .scaleAspectFit
        unFollowingTextLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        unFollowingTextLabel.text = "Follow"
        unFollowingTextLabel.textColor = lightGreen
        unFollowingTextLabel.textAlignment = .center
        unFollowingTextLabel.font = UIFont.boldSystemFont(ofSize: 13)
        unFollowingTextLabel.adjustsFontSizeToFitWidth = true
        if isFollowing {
            unFollowingTextLabel.isHidden = true
        } else {
            textLabel.isHidden = true
            iconImageView.isHidden = true
        }
        button = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        super.init(frame: frame)
        self.backgroundColor = darkGreen
        self.onPress = onPress
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(touchDownOnButton), for: .touchDown)
        self.layer.borderWidth = 1
        self.layer.borderColor = lightGreen.cgColor
        
        innerView.addSubview(textLabel)
        innerView.addSubview(iconImageView)
        innerView.addSubview(button)
        self.addSubview(unFollowingTextLabel)
        self.addSubview(innerView)
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setToUnfollowing() {
        self.iconImageView.isHidden = true
        self.textLabel.isHidden = true
        self.unFollowingTextLabel.isHidden = false
    }

    func setToFollowing() {
        self.iconImageView.isHidden = false
        self.textLabel.isHidden = false
        self.unFollowingTextLabel.isHidden = true
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
