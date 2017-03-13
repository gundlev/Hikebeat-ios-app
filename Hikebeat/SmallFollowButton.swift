//
//  SmallFollowButton.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 13/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import SwiftyDrop

class SmallFollowButton: UIView {
    var iconImageView: UIImageView
    var textLabel: UILabel
    var button: UIButton
    var onPress: (Bool) -> ()
    var isFollowing = false
    var journey: Journey!
    //    var innerView: UIView
    
    var oldBounds: CGRect?
    
    init(frame: CGRect, isFollowing: Bool, journey: Journey, onPress: @escaping (Bool) -> ()) {
        self.journey = journey
        self.isFollowing = isFollowing
        self.onPress = onPress
        textLabel = UILabel(frame: CGRect(x: 0 , y: 0, width: frame.width, height: frame.height))
        textLabel.text = "Follow"
        textLabel.textColor = lightGreen
        textLabel.textAlignment = .center
        textLabel.font = UIFont.boldSystemFont(ofSize: 13)
        textLabel.adjustsFontSizeToFitWidth = true
        iconImageView = UIImageView(frame: CGRect(x: 0, y: frame.height/4, width: frame.width, height: frame.height/2))
        iconImageView.image = UIImage(named: "follow_button_following")
        iconImageView.contentMode = .scaleAspectFit
        button = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        super.init(frame: frame)
        if isFollowing {
            self.setToFollowing()
        } else {
            self.setToUnfollowing()
        }
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(touchDownOnButton), for: .touchDown)
        self.layer.borderWidth = 1
        self.layer.borderColor = lightGreen.cgColor
        
        self.addSubview(textLabel)
        self.addSubview(iconImageView)
        self.addSubview(button)
        self.layer.cornerRadius = frame.height/2
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeJourneyTo(journey: Journey) {
        self.journey = journey
        self.isFollowing = journey.isFollowed
        if isFollowing {
            self.setToFollowing()
        } else {
            self.setToUnfollowing()
        }
    }
    
    func setToUnfollowing() {
        iconImageView.isHidden = true
        textLabel.isHidden = false
        self.backgroundColor = .clear
    }
    
    func setToFollowing() {
        iconImageView.isHidden = false
        textLabel.isHidden = true
        self.backgroundColor = lightGreen
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
                }
                self.onPress(true)
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
                }
                self.onPress(true)
            }).onFailure(callback: { (error) in
                // do nothing
                Drop.down("Could not follow journey, try again later.", state: .error)
                self.setToUnfollowing()
                self.onPress(false)
            })
        }
    }
    
    
}
