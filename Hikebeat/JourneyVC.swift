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
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var journey: Journey?
    var pins = [BeatPin]()
    var indexOfChosenPin: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        let socialGradient = CAGradientLayer()
        socialGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: socialContainerView.bounds.size)
        socialGradient.colors = [UIColor(hexString: "054D51")!.CGColor, UIColor(hexString: "2E7E5D")!.CGColor]
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
    }
    
    func setUpPins() {

        var pinArr = [BeatPin]()
        
        print("There are saved parkings")
        for beat in (self.journey?.beats)! {
            var title = ""
            var subtitle = ""
            
            if beat.title != nil {
                title = beat.title!
            }
            
            if beat.message != nil {
                subtitle = beat.message!
            }
            
            // Getting the image
            var image: UIImage? = nil
            if beat.mediaData != nil {
                image = getImageWithName(beat.mediaData!)
            }
            
            
            let beatPin = BeatPin(title: title, timestamp: beat.timestamp, subtitle: subtitle, locationName: "Somewhere", discipline: beat.journeyId, coordinate: CLLocationCoordinate2D(latitude: Double(beat.latitude)!, longitude: Double(beat.longitude)!), lastPin: false, image: image)
            self.journeyMap.addAnnotation(beatPin)
            pinArr.append(beatPin)
        }
        self.pins = pinArr
        pinArr.sortInPlace()
        let lastElement = pinArr.last
        lastElement?.lastPin = true
        self.zoomToFitMapAnnotations(self.journeyMap)
        self.createPolyline(self.journeyMap)
    }
    
    func zoomToFitMapAnnotations(aMapView: MKMapView) {
        if aMapView.annotations.count == 0 {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        for annotation: MKAnnotation in aMapView.annotations {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.8
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.8
        region = aMapView.regionThatFits(region)
        aMapView.setRegion(region, animated: true)
    }
    
    func getImageWithName(name: String) -> UIImage? {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let dataPath = documentsDirectory.stringByAppendingPathComponent(name)
        return UIImage(contentsOfFile: dataPath)
    }

func mapView(localMapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? BeatPin {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = localMapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: 0, y: 0)
                
                let button = UIButton(type: .DetailDisclosure)
                button.addTarget(self, action: #selector(showBeat), forControlEvents: UIControlEvents.TouchUpInside)

                view.rightCalloutAccessoryView = button as UIView
                
                if annotation.image != nil  {
                    let imgView = UIImageView()
                    let image = annotation.image!
                    if image.size.height > image.size.width {
                        let ratio = image.size.width/image.size.height
                        let newWidth = 40 * ratio
                        imgView.frame = CGRect(x: 0, y: 0, width: newWidth, height: 40)
                    } else {
                        let ratio = image.size.height/image.size.width
                        let newHeight = 40 * ratio
                        imgView.frame = CGRect(x: 0, y: 0, width: 40, height: newHeight)
                    }
                    
                    imgView.image = annotation.image!
                    view.leftCalloutAccessoryView = imgView
                }
               
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
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        print("this is run")
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        let polyline = overlay as! BeatPolyline
        polylineRenderer.strokeColor = polyline.color
        polylineRenderer.lineWidth = 3
        return polylineRenderer
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Pin button tapped")
        self.indexOfChosenPin = pins.indexOf(view.annotation as! BeatPin)
        performSegueWithIdentifier("showBeat", sender: self)
    }
    
    func createPolyline(mapView: MKMapView) {
        
        let beats = journey?.beats
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        for beat in beats! {
            let point = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(beat.latitude)!), longitude: CLLocationDegrees(Double(beat.longitude)!))
            points.append(point)
        }
        
        let polyline = BeatPolyline(coordinates: &points, count: points.count)
        polyline.color = UIColor.blueColor()
        mapView.addOverlay(polyline)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func goBack(sender: AnyObject) {
        
        if appDelegate.fastSegueHack=="social"{
            performSegueWithIdentifier("unwindSocialHack", sender: self)
        }else{
            performSegueWithIdentifier("unwindJourneysHack", sender: self)
        }
        
    }
    
    @IBAction func unwindToJourney(unwindSegue: UIStoryboardSegue) {
        
    }

    @IBAction func showFirstBeat(sender: AnyObject) {
        
        //performSegueWithIdentifier("showBeat", sender: self)
        
    }
    
    
    @IBAction func shareButton(sender: AnyObject) {
        
        let slug = journey?.slug
        let user = userDefaults.stringForKey("username")
        let base = "https://hikebeat.io/user/"
        let shareString = base+user!+"/"+slug!
        let objectsToShare = [shareString]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare as [AnyObject], applicationActivities: nil)
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBeat" {
            let vc = segue.destinationViewController as! BeatsVC
            vc.startingIndex = self.indexOfChosenPin!
            vc.journey = self.journey
        }
    }

}
