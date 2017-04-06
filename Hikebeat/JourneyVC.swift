//
//  JourneyVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/30/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift
import SwiftyDrop

class JourneyVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var socialContainerView: UIView!
    @IBOutlet weak var journeyMap: MKMapView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefaults = UserDefaults.standard
    var followersButton: GreenIconButton!
    var beatsButton: GreenIconButton!
    var followButton: LargeFollowButton!
    var syncButton: LargeSyncButton!
    
    @IBOutlet weak var beatIcon: UIImageView!
    var journey: Journey?
//    var save = true
    var pins = [BeatPin]()
    var indexOfChosenPin: Int?
    var fromVC = ""
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        self.goToProfile()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let width = UIScreen.main.bounds.width
        
        // Do any additional setup after loading the view.
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        let socialGradient = CAGradientLayer()
        socialGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.bounds.size.width*2, height: socialContainerView.bounds.height))
        socialGradient.colors = [UIColor(hexString: "054D51")!.cgColor, UIColor(hexString: "2E7E5D")!.cgColor]
        socialGradient.zPosition = -1
        socialContainerView.layer.addSublayer(socialGradient)
        
        let initialLocation = CLLocation(latitude: 55.6596349, longitude: 12.5909584)
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        journeyMap.setRegion(coordinateRegion, animated: true)
        journeyMap.showsUserLocation = false
        
//        titleButton.layer.cornerRadius = titleButton.bounds.height/2
//        titleButton.layer.masksToBounds = true
        
        profileImage.layer.cornerRadius = profileImage.bounds.height/2
        profileImage.layer.masksToBounds = true
        setUpPins()
        
        if fromVC != "journeys" {
            if (journey?.beats.isEmpty)! {
                getBeatsForJourney(userId: (journey?.userId)!, journeyId: (journey?.journeyId)!)
                .onSuccess(callback: { (beatsJson) in
                    let realm = try! Realm()
                    try! realm.write {
                        print("here")
                        for (_, beatJson) in beatsJson {
                            print("___________________________")
                            print(beatJson)
                            let beat = Beat()
                            let mediaType = beatJson["media"]["type"].stringValue
                            let mediaUrl = beatJson["media"]["path"].stringValue
                            let mediaDataId = beatJson["media"]["_id"].stringValue
                            beat.fill(beatJson["emotion"].stringValue, journeyId: (self.journey?.journeyId)!, message: beatJson["text"].stringValue, latitude: beatJson["lat"].stringValue, longitude: beatJson["lng"].stringValue, altitude: beatJson["alt"].stringValue, timestamp: beatJson["timeCapture"].stringValue, mediaType: beatJson["media"]["type"].stringValue, mediaData: nil, mediaDataId: mediaDataId, mediaUrl: mediaUrl, messageId: beatJson["_id"].stringValue, mediaUploaded: true, messageUploaded: true, journey: self.journey!)
                            self.journey!.beats.append(beat)
                        }
                        self.updateNumberOfbeats()
//                        self.beatsButton.textLabel.text = self.journey.
                        print("john")
                        self.setUpPins()
                    }
                }).onFailure(callback: { (error) in
                    print("problem getting full journey, error: ", error)
                })
            }
            
            let followButtonFrame = CGRect(x: width/2 + 40, y: 12, width: (width/6.5)*2 + 20, height: 29)
            followButton = LargeFollowButton(frame: followButtonFrame, isFollowing: (journey?.isFollowed)!, journey: self.journey!, onPress: {
                success in
                if success {
                    self.followersButton.textLabel.text = "\((self.journey?.numberOfFollowers)!)"
                }
            })
            self.socialContainerView.addSubview(followButton)
            self.setBeatsAndFollowersButtons(numberOfBeats: (journey?.numberOfBeats)!, numberOfFollowers: (journey?.numberOfFollowers)!)
        } else {
//            setUpPins()
            
            let syncButtonFrame = CGRect(x: width/2 + 40, y: 12, width: (width/6.5)*2 + 20, height: 29)
            let inSync = journeyIsInSync(journeyId: journey!.journeyId)
            syncButton = LargeSyncButton(frame: syncButtonFrame, inSync: inSync, onPress: {
                if !self.syncButton.inSync {
                    self.tabBarController?.selectedIndex = 4
                } else {
                    Drop.down("There is no media or any messages to sync. Have an awesome day!", state: .success)
                }
            })
            self.socialContainerView.addSubview(syncButton)
            self.setBeatsAndFollowersButtons(numberOfBeats: (journey?.beats.count)!, numberOfFollowers: (journey?.numberOfFollowers)!)
            getNumberOfFollowersFor(journeyId: (journey?.journeyId)!)
            .onSuccess(callback: { (count) in
                self.followersButton.textLabel.text = "\(count)"
                let realm = try! Realm()
                try! realm.write {
                    self.journey?.numberOfFollowers = count
                }
            }).onFailure(callback: { (error) in
                print("Error getting followers: ", error)
            })
        }

//        titleButton.setTitle(journey?.headline, for: UIControlState())
        titleLabel.text = journey?.headline
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(showLatestBeat))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(showLatestBeat))
        
        beatIcon.addGestureRecognizer(tap1)
        followersLabel.addGestureRecognizer(tap2)
        beatIcon.isUserInteractionEnabled = true
        followersLabel.isUserInteractionEnabled = true
        
        self.setProfileImage()
        self.setUsername()
    }
    
    func setBeatsAndFollowersButtons(numberOfBeats: Int, numberOfFollowers: Int) {
        print("Settings info with: ", numberOfBeats, " and ", numberOfFollowers)
        let width = UIScreen.main.bounds.width

        let followerButtonFrame = CGRect(x: 20, y: 12, width: width/6.5, height: 29)
        followersButton = GreenIconButton(frame: followerButtonFrame,
                                          icon: UIImage(named: "Journey_VC_followers")!,
                                          text: "\(numberOfFollowers)",
                                            textColor: .white,
                                            boldText: false,
                                            ratio: 0.5,
                                            onPress: {
                                                print("follower button tapped")
                                                self.showFollowers()
                                            })
        
        let beatsButtonFrame = CGRect(x: (width/6.5) + 40, y: 12, width: width/6.5, height: 29)
        beatsButton = GreenIconButton(frame: beatsButtonFrame,
                                      icon: UIImage(named: "Journey_VC_beats")!,
                                      text: "\(numberOfBeats)",
                                        textColor: .white,
                                        boldText: false,
                                        ratio: 0.5,
                                        onPress: {
                                            print("beats button tapped")
                                            self.showLatestBeat()
                                        })
        
        self.socialContainerView.addSubview(followersButton)
        self.socialContainerView.addSubview(beatsButton)
    }
    
    func showFollowers () {
        guard hasNetworkConnection(show: true) else { return }
        self.performSegue(withIdentifier: "showFollowers", sender: self)
    }
    
    func updateNumberOfbeats() {
        print("Updating beat number")
        guard beatsButton != nil else { return }
        guard journey != nil else { return }
        beatsButton.textLabel.text = "\(self.journey!.beats.count)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if fromVC == "journeys" {
            let inSync = journeyIsInSync(journeyId: journey!.journeyId)
            if inSync {
                self.syncButton.setToInSync()
            } else {
                self.syncButton.setToNotInSync()
            }
        }
        setUpPins()
        updateNumberOfbeats()
    }
    
    
    
//    func genSmallButton() -> GreenIconButton {
//        
//    }
    
    func showLatestBeat() {
        if self.pins.count != 0 {
            self.indexOfChosenPin = pins.count - 1
            _ = performSegue(withIdentifier: "showBeat", sender: self)
        }
    }
    
    func setProfileImage() {
        if fromVC == "journeys" {
            let dataPath = getProfileImagePath()
            let image = UIImage(contentsOfFile: dataPath)
            if image != nil {
                self.profileImage.image = image
            } else {
                self.profileImage.image = UIImage(named: "DefaultProfile")
            }
            let tabGesture = UITapGestureRecognizer(target: self, action: #selector(goToProfile))
            self.profileImage.addGestureRecognizer(tabGesture)
            self.profileImage.isUserInteractionEnabled = true
        } else {
            if self.journey?.ownerProfilePhoto != nil {
                self.profileImage.image = UIImage(data: (self.journey?.ownerProfilePhoto!)!)
                let tabGesture = UITapGestureRecognizer(target: self, action: #selector(self.test))
                self.profileImage.addGestureRecognizer(tabGesture)
            } else {
                downloadImage(imageUrl: (self.journey?.ownerProfilePhotoUrl)!)
                .onSuccess(callback: { (image) in
                    self.profileImage.image = image
                    let tabGesture = UITapGestureRecognizer(target: self, action: #selector(self.test))
                    self.profileImage.addGestureRecognizer(tabGesture)
                }).onFailure(callback: { (error) in
                    self.profileImage.image = UIImage(named: "DefaultProfile")
                    let tabGesture = UITapGestureRecognizer(target: self, action: #selector(self.test))
                    self.profileImage.addGestureRecognizer(tabGesture)
                })
            }
        }
    }
    
    func test() {
        print("WHAAAAt")
    }
    
    func setUsername() {
        print(self.journey)
        self.usernameLabel.text = "by \((self.journey?.username)!)"
    }
    
    func goToProfile() {
        print("go to profile now")
        switch fromVC {
        case "showAll":
            performSegue(withIdentifier: "showProfile", sender: self)
            return
        case "search":
            performSegue(withIdentifier: "showProfile", sender: self)
            return
        case "publicProfile":
            performSegue(withIdentifier: "backToPublicProfile", sender: self)
            return
        default: self.tabBarController?.selectedIndex = 3
        }
    }
    
    func getProfileImagePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let fileName = "/media/profile_image.jpg"
        let dataPath = documentsDirectory.appending(fileName)
        return dataPath
    }
    
    func setUpPins() {
        print("Setup pins")
        var pinArr = [BeatPin]()
        print("There are saved beats")
        self.journeyMap.removeAnnotations(self.journeyMap.annotations)
        for beat in (self.journey?.beats)! {
            var message = ""
            var subtitle = ""
            
            if beat.message != nil {
                message = beat.message!
            }
            
            if beat.message != nil {
                subtitle = beat.message!
            }
            
            // Getting the image
            var image: UIImage? = nil
            if beat.mediaData != nil {
                image = getImageWithName(beat.mediaData!)
            }
            
            
            let beatPin = BeatPin(title: message, timestamp: beat.timestamp, subtitle: subtitle, locationName: "Somewhere", discipline: beat.journeyId, coordinate: CLLocationCoordinate2D(latitude: Double(beat.latitude)!, longitude: Double(beat.longitude)!), lastPin: false, image: image)
            self.journeyMap.addAnnotation(beatPin)
            pinArr.append(beatPin)
        }
        self.pins = pinArr
        pinArr.sort()
        let lastElement = pinArr.last
        lastElement?.lastPin = true
        self.journeyMap.showAnnotations(self.journeyMap.annotations, animated: true)
        self.createPolyline(self.journeyMap)
        
        if self.pins.count==0{
            followersLabel.text = "No beats"
        }else if self.pins.count == 1 {
            followersLabel.text = String(self.pins.count)+" beat"
        } else {
            followersLabel.text = String(self.pins.count)+" beats"
        }
    }
    
    func getImageWithName(_ name: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let dataPath = documentsDirectory.appending(name)
        return UIImage(contentsOfFile: dataPath)
    }

    func mapView(_ localMapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("This is the place")
        if let annotation = annotation as? BeatPin {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = localMapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.calloutOffset = CGPoint(x: 0, y: 0)
                
//                let button = UIButton(type: .DetailDisclosure)
//                button.addTarget(self, action: #selector(showBeat), forControlEvents: UIControlEvents.TouchUpInside)
//
//                view.rightCalloutAccessoryView = button as UIView
//                
//                if annotation.image != nil  {
//                    let imgView = UIImageView()
//                    let image = annotation.image!
//                    if image.size.height > image.size.width {
//                        let ratio = image.size.width/image.size.height
//                        let newWidth = 40 * ratio
//                        imgView.frame = CGRect(x: 0, y: 0, width: newWidth, height: 40)
//                    } else {
//                        let ratio = image.size.height/image.size.width
//                        let newHeight = 40 * ratio
//                        imgView.frame = CGRect(x: 0, y: 0, width: 40, height: newHeight)
//                    }
//                    
//                    imgView.image = annotation.image!
//                    view.leftCalloutAccessoryView = imgView
//                }
               
                let pinImage = UIImage(named: "HikebeatPin")
                view.image = pinImage
                view.centerOffset.y = -((pinImage?.size.height)!/2)
                let point = CGPoint(x: view.center.x + view.frame.width/2, y: (view.center.y + (view.frame.height)))
                
                if annotation.lastPin == true {
                    let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:40, position:point)
                    pulseEffect.pulseInterval = 0
                    view.layer.insertSublayer(pulseEffect, below: view.layer)
                }

            }
            return view
        }
        return nil
    }
    
    func showBeat() {
        print("yeah")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("this is run")
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        let polyline = overlay as! BeatPolyline
        polylineRenderer.strokeColor = polyline.color
        polylineRenderer.lineWidth = 3
        return polylineRenderer
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        print("Pin button tapped")
//        self.indexOfChosenPin = pins.indexOf(view.annotation as! BeatPin)
//        performSegueWithIdentifier("showBeat", sender: self)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("pressed an annotation")
        if let index = pins.index(of: view.annotation as! BeatPin) {
            self.indexOfChosenPin = index
            performSegue(withIdentifier: "showBeat", sender: self)
        }
    }
    
    func createPolyline(_ mapView: MKMapView) {
        
        let beats = journey?.beats
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        for beat in beats! {
            let point = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(beat.latitude)!), longitude: CLLocationDegrees(Double(beat.longitude)!))
            points.append(point)
        }
        
        let polyline = BeatPolyline(coordinates: &points, count: points.count)
        polyline.color = UIColor(hexString: "#15676C")!
        polyline.lineWidth = 6.0
        
        mapView.add(polyline)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: AnyObject) {
        switch fromVC {
        case "showAll":
            performSegue(withIdentifier: "journeyToShowAll", sender: self)
            return
        case "search":
            performSegue(withIdentifier: "journeyToSearch", sender: self)
            return
        case "publicProfile":
            performSegue(withIdentifier: "backToPublicProfile", sender: self)
            return
        default: print("nothing here")
        }
        
//        guard save else {
//            performSegue(withIdentifier: "journeyToSearch", sender: self)
//            return
//        }
        
        if appDelegate.fastSegueHack=="social"{
            performSegue(withIdentifier: "unwindSocialHack", sender: self)
        }else{
            performSegue(withIdentifier: "unwindJourneysHack", sender: self)
        }
        
    }
    
    @IBAction func unwindToJourney(_ unwindSegue: UIStoryboardSegue) {
        
    }

    @IBAction func showFirstBeat(_ sender: AnyObject) {
        
        //performSegueWithIdentifier("showBeat", sender: self)
        
    }
    
    
    @IBAction func shareButton(_ sender: AnyObject) {
        // Real implementation
        let slug = journey?.slug
        let user = journey?.username
        let base = "https://hikebeat.io/"
        let shareString = base+user!+"/"+slug!
        let objectsToShare = [shareString]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare as [AnyObject], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBeat" {
            let vc = segue.destination as! BeatsVC
            vc.startingIndex = self.indexOfChosenPin!
            vc.journey = self.journey
            vc.save = self.fromVC == "journeys"
        } else if segue.identifier == "showFollowers" {
            let vc = segue.destination as! PaginatingVC
            vc.list = JourneyFollowersList(journeyId: (self.journey?.journeyId)!)
            vc.fromVC = "journey"
        } else if segue.identifier == "showProfile" {
            let vc = segue.destination as! PublicProfileVC
            print("showing user With ID: ", journey!.userId)
            vc.userId = journey!.userId
            vc.fromVC = "journey"
        }
    }

}
