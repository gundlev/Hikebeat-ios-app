//
//  JourneyVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/30/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import MapKit

class JourneyVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var socialContainerView: UIView!
    @IBOutlet weak var journeyMap: MKMapView!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var beatIcon: UIImageView!
    var journey: Journey?
    var pins = [BeatPin]()
    var indexOfChosenPin: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        let socialGradient = CAGradientLayer()
        socialGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: socialContainerView.bounds.size)
        socialGradient.colors = [UIColor(hexString: "054D51")!.cgColor, UIColor(hexString: "2E7E5D")!.cgColor]
        socialGradient.zPosition = -1
        socialContainerView.layer.addSublayer(socialGradient)
        
        let initialLocation = CLLocation(latitude: 55.6596349, longitude: 12.5909584)
        let regionRadius: CLLocationDistance = 500
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        journeyMap.setRegion(coordinateRegion, animated: true)
        journeyMap.showsUserLocation = false
        
        titleButton.layer.cornerRadius = titleButton.bounds.height/2
        titleButton.layer.masksToBounds = true
        
        profileImage.layer.cornerRadius = profileImage.bounds.height/2
        profileImage.layer.masksToBounds = true
        setUpPins()
        if self.pins.count==0{
            followersLabel.text = "No beats"
        }else if self.pins.count == 1 {
            followersLabel.text = String(self.pins.count)+" beat"
        } else {
            followersLabel.text = String(self.pins.count)+" beats"
        }
        
        titleButton.setTitle(journey?.headline, for: UIControlState())
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(showLatestBeat))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(showLatestBeat))
        
        beatIcon.addGestureRecognizer(tap1)
        followersLabel.addGestureRecognizer(tap2)
        beatIcon.isUserInteractionEnabled = true
        followersLabel.isUserInteractionEnabled = true
        
        self.setProfileImage()
    }
    
    func showLatestBeat() {
        self.indexOfChosenPin = pins.count - 1
        performSegue(withIdentifier: "showBeat", sender: self)
    }
    
    func setProfileImage() {
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
    }
    
    func goToProfile() {
        print("go to profile now")
        self.tabBarController?.selectedIndex = 3
    }
    
    func getProfileImagePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let fileName = "media/profile_image.jpg"
        let dataPath = documentsDirectory.appending("/"+fileName)
        return dataPath
    }
    
    func setUpPins() {

        var pinArr = [BeatPin]()
        
        print("There are saved parkings")
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
    }
    
    func getImageWithName(_ name: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let dataPath = documentsDirectory.appending("/media/"+name)
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
        self.indexOfChosenPin = pins.index(of: view.annotation as! BeatPin)
        performSegue(withIdentifier: "showBeat", sender: self)
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
        
        let slug = journey?.slug
        let user = userDefaults.string(forKey: "username")
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
        }
    }

}
