//
//  PublicProfileVC.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 31/03/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class PublicProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: User?
    var journeys = [Journey]()
    var fromVC = ""
    var chosenJourney: Journey?
    var userId: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingsLabel: UILabel!
    @IBOutlet weak var countriesLabel: UILabel!
    @IBOutlet weak var journeysLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var beatsLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func back(_ sender: Any) {
        switch fromVC {
        case "search": _ = self.performSegue(withIdentifier: "backToSearch", sender: self)
        case "pagination": _ = self.performSegue(withIdentifier: "backToPagination", sender: self)
        case "journey": _ = self.performSegue(withIdentifier: "backToJourney", sender: self)
        default: print("unknown destination for back")
        }
    }
    
    @IBAction func backToPublicProfile(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        profileImageView.layer.cornerRadius = profileImageView.bounds.width/2
    }
    
    @IBAction func share(_ sender: Any) {
        // Should not be used
    }
    
    override func viewDidLoad() {
//        if (UIDevice.isIphone5){
//            //            searchFieldLabelView.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, -40.0  )
//            //            searchField.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, 0.0  )
//            //            searchButton.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, 0.0  )
//            infoContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8);
//            infoContainer.transform = infoContainer.transform.translatedBy(x: 0.0, y: -35.0  )
//            
//        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
//            self.followersButton.transform = followersButton.transform.translatedBy(x: 0.0, y: 10.0  )
//        }else if(UIDevice.isIphone4 || UIDevice.isIpad){
//            profileContentView.transform = CGAffineTransform.identity.scaledBy(x: 0.75, y: 0.75);
//            profileContentView.transform = profileContentView.transform.translatedBy(x: 0.0, y: -100.0  )
//            
//            
//            profilePicture.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6);
//            profilePicture.transform = profilePicture.transform.translatedBy(x: 0, y: 50.0  )
//            
//            editProfileImageButton.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6);
//            editProfileImageButton.transform = editProfileImageButton.transform.translatedBy(x: 0, y: 50.0  )
//            
//            blurryBG.transform = CGAffineTransform.identity.scaledBy(x: 1.2, y: 0.8);
//            blurryBG.transform = blurryBG.transform.translatedBy(x: 0, y: 25  )
//        }
        
        tableView.register(ProfileJourneyCell.self, forCellReuseIdentifier: "journeyCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(red:189/255.0, green:244/255.0, blue:0, alpha:1.00)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = .clear
        tableView.rowHeight = 70
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        spinner.hidesWhenStopped = true
        imageSpinner.hidesWhenStopped = true
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.width/2
        profileImageView.layer.masksToBounds = true
        
        titleLabel.text = ""
        usernameLabel.text = ""
//        usernameLabel.isHidden = true
        
        if user != nil {
            print("User not nil")
            setView()
        } else {
            imageSpinner.startAnimating()
            print("getting user with id: ", self.userId)
            getUserWith(userId: self.userId!)
            .onSuccess(callback: { (user) in
                print("Got user: ", user)
                self.user = user
                self.setView()
            }).onFailure(callback: { (error) in
                print("Problem getting user")
            })
        }
    }
    
    func setView() {
        print("setting views")
        setInfo()
        if user!.profilePhoto != nil {
            self.setImage(image: user!.profilePhoto!)
            imageSpinner.stopAnimating()
        } else {
            downloadImage(imageUrl: user!.profilePhotoUrl)
            .onSuccess { (image) in
                self.setImage(image: image)
                self.imageSpinner.stopAnimating()
            }.onFailure { (error) in
                print("Error: ", error)
                self.profileImageView.image = UIImage(named: "DefaultProfile")
            }
        }
        
        spinner.startAnimating()
        getJourneysWithoutSavingFor(userId: user!.id, ownerProfilePhotoUrl: user!.profilePhotoUrl, ownerProfilePhoto: user!.profilePhoto != nil ? UIImageJPEGRepresentation(user!.profilePhoto!, 1) : nil)
            .onSuccess { (journeys) in
                self.journeys = journeys
                self.tableView.reloadData()
                self.spinner.stopAnimating()
            }.onFailure { (error) in
                self.spinner.stopAnimating()
        }
    }
    
    func setImage(image: UIImage) {
        self.user!.profilePhoto = image
        self.profileImageView.image = self.user!.profilePhoto
        print("setting tap recog")
        let tap = UITapGestureRecognizer(target: self, action: #selector(showImage))
        self.profileImageView.addGestureRecognizer(tap)
    }
    
    func showImage() {
        print("here")
        let agrume = Agrume(image: self.user!.profilePhoto!, backgroundColor: .black)
        agrume.hideStatusBar = true
        agrume.showFrom(self)
    }
    
    func setInfo() {
        print("Setting info for user: ")
        print("\(user!.followerCount) followers")
        print("\(user!.followsCount) follows")
        print("\(user!.visitedCountries.count) countries")
        print("\(user!.mostVisitedCountry != "none" ? Locale(identifier: "en_US").localizedString(forRegionCode: user!.mostVisitedCountry)! : "none")")
        print("\(user!.numberOfJourneys) journeys")
        print("\(user!.numberOfBeats) beats")
        print("\(user!.username)")
        
        followersLabel.text = "\(user!.followerCount) followers"
        followingsLabel.text = "\(user!.followsCount) follows"
        countriesLabel.text = "\(user!.visitedCountries.count) countries"
        favoriteLabel.text = "\(user!.mostVisitedCountry != "none" ? Locale(identifier: "en_US").localizedString(forRegionCode: user!.mostVisitedCountry)! : "none")"
        journeysLabel.text = "\(user!.numberOfJourneys) journeys"
        beatsLabel.text = "\(user!.numberOfBeats) beats"
        titleLabel.text = "@\(user!.username)"
        usernameLabel.text = "\(user!.username)'s public profile"
    }
    
// TableView functions
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getJourneyCell(journey: journeys[indexPath.row], tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenJourney = self.journeys[indexPath.row]
        _ = self.performSegue(withIdentifier: "showJourney", sender: self)
    }
    
    func getJourneyCell(journey: Journey, tableView: UITableView) -> ProfileJourneyCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journeyCell") as! ProfileJourneyCell
        cell.selectionStyle = .none
        cell.journey = journey
        cell.awakeFromNib()
        cell.headline.text = journey.headline
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Profile tableview rows: ", self.journeys.count)
        return self.journeys.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier != nil else { return }
        switch segue.identifier! {
        case "showJourney":
            let vc = segue.destination as! JourneyContainerVC
            vc.journey = chosenJourney
            vc.fromVC = "publicProfile"
            vc.save = false
        default: print("Default...whaat?")
        }
    }
    
}
