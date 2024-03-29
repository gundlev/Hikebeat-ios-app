//
//  LargeFollowButton.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SwiftyDrop

class LargeFollowButton: UIView {
    var iconImageView: UIImageView
    var textLabel: UILabel
    var unFollowingTextLabel: UILabel
    var button: UIButton
    var onPress: (Bool) -> ()
    var isFollowing = false
    var journey: Journey!
//    var innerView: UIView
    
    var oldBounds: CGRect?
    
    init(frame: CGRect, isFollowing: Bool, journey: Journey, onPress: @escaping (Bool) -> ()) {
        self.journey = journey
        self.isFollowing = isFollowing
        let innerView = UIView(frame: CGRect(x: floor(frame.width/6), y: 0, width: frame.width-frame.width/3, height: frame.height))
        textLabel = UILabel(frame: CGRect(x: floor(frame.width/5) , y: 0, width: (frame.width/2), height: frame.height))
        textLabel.text = "Following"
        textLabel.textColor = lightGreen
        textLabel.textAlignment = .left
        textLabel.font = UIFont.boldSystemFont(ofSize: 14)
        textLabel.adjustsFontSizeToFitWidth = false
        iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width/8, height: frame.height))
        iconImageView.image = UIImage(named: "following_checkmark")
        iconImageView.contentMode = .scaleAspectFit
        unFollowingTextLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        unFollowingTextLabel.text = "Follow"
        unFollowingTextLabel.textColor = lightGreen
        unFollowingTextLabel.textAlignment = .center
        unFollowingTextLabel.font = UIFont.boldSystemFont(ofSize: 14)
        unFollowingTextLabel.adjustsFontSizeToFitWidth = false
        if isFollowing {
            unFollowingTextLabel.isHidden = true
        } else {
            textLabel.isHidden = true
            iconImageView.isHidden = true
        }
        button = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        self.onPress = onPress
        super.init(frame: frame)
        self.backgroundColor = .clear
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(touchDownOnButton), for: .touchDown)
        self.layer.borderWidth = 1
        self.layer.borderColor = lightGreen.cgColor
        innerView.addSubview(textLabel)
        innerView.addSubview(iconImageView)
        self.addSubview(unFollowingTextLabel)
        self.addSubview(innerView)
        self.addSubview(button)
        self.layer.cornerRadius = 7
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
        followOrUnfollow()
    }
    
    func touchDownOnButton() {
        self.alpha = 0.5
    }
    
    func touchUpOutside() {
        self.alpha = 1
    }
    
    func followOrUnfollow() {
        guard hasNetworkConnection(show: true) else { return }
        if journey.isFollowed {
            // call unfollow
            self.setToUnfollowing()
            unfollowJourney(journeyId: journey.journeyId)
            .onSuccess(callback: { (success) in
                let realm = try! Realm()
                try! realm.write {
                    self.journey.isFollowed = false
                    self.journey.numberOfFollowers -= 1
                    self.onPress(true)
                }
            }).onFailure(callback: { (error) in
                Drop.down("Could not unfollow journey, try again later.", state: .error)
                self.setToFollowing()
                self.onPress(false)
            })
        } else {
            // call follow
            self.setToFollowing()
            followJourney(journeyId: journey.journeyId)
            .onSuccess(callback: { (success) in
                let realm = try! Realm()
                try! realm.write {
                    self.journey.isFollowed = true
                    self.journey.numberOfFollowers += 1
                    self.onPress(true)
                }
            }).onFailure(callback: { (error) in
                // do nothing
                Drop.down("Could not follow journey, try again later.", state: .error)
                self.setToUnfollowing()
                self.onPress(false)
            })
        }
    }
    

}
