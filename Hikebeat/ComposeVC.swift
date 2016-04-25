//
//  ComposeVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/23/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class ComposeVC: UIViewController {

    var titleText = ""
    var messageText = ""
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let greenColor = UIColor(red:189/255.0, green:244/255.0, blue:0, alpha:1.00)
    
    @IBOutlet weak var editTitleButton: UIImageView!
    @IBOutlet weak var editMessageButton: UIImageView!
    @IBOutlet weak var editImageButton: UIImageView!
    @IBOutlet weak var sendBeatButton: UIButton!
    @IBOutlet weak var editMemoButton: UIImageView!
    @IBOutlet weak var editVideoButton: UIImageView!
    
    @IBAction func sendBeat(sender: AnyObject) {
    
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        editTitleButton.layer.cornerRadius = editTitleButton.bounds.width/2
        editMessageButton.layer.cornerRadius = editMessageButton.bounds.width/2
        editVideoButton.layer.cornerRadius = editVideoButton.bounds.width/2
        editMemoButton.layer.cornerRadius = editMemoButton.bounds.width/2
        editImageButton.layer.cornerRadius = editImageButton.bounds.width/2
        sendBeatButton.layer.cornerRadius = sendBeatButton.bounds.height/2
        
        editTitleButton.layer.masksToBounds = true
        editMessageButton.layer.masksToBounds = true
        editImageButton.layer.masksToBounds = true
        editVideoButton.layer.masksToBounds = true
        editMemoButton.layer.masksToBounds = true
        sendBeatButton.layer.masksToBounds = true
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        
        editTitleButton.userInteractionEnabled = true
        editMemoButton.userInteractionEnabled = true
        editImageButton.userInteractionEnabled = true
        editVideoButton.userInteractionEnabled = true
        editMessageButton.userInteractionEnabled = true
        
        editTitleButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(titleButtonTapped)))
        editMemoButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(memoButtonTapped)))
        editImageButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(imageButtonTapped)))
        editVideoButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(videoButtonTapped)))
        editMessageButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(messageButtonTapped)))
        
    }
    
    @IBAction func unwindToCompose(sender: UIStoryboardSegue)
    {
//        let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }


    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func titleButtonTapped() {
        print("title")
        
        performSegueWithIdentifier("editTitleModal", sender: self)
        editTitleButton.layer.borderWidth = 4
        editTitleButton.layer.borderColor = greenColor.CGColor
    }

    func memoButtonTapped() {
        print("memo")
        editMemoButton.layer.borderWidth = 4
        editMemoButton.layer.borderColor = greenColor.CGColor
    }
    
    func imageButtonTapped() {
        print("image")
        editImageButton.layer.borderWidth = 4
        editImageButton.layer.borderColor = greenColor.CGColor
    }
    
    func videoButtonTapped() {
        print("video")
        editVideoButton.layer.borderWidth = 4
        editVideoButton.layer.borderColor = greenColor.CGColor
    }
    
    func messageButtonTapped() {
        print("message")
        editMessageButton.layer.borderWidth = 4
        editMessageButton.layer.borderColor = greenColor.CGColor
    }
    
    
    /**
     function to get the timestamp and location.
     
     - parameters:
     - nil
     
     - returns: Bundle with 4 strings: timestamp, latitude, longitude, altitude.
     */
    func getTimeAndLocation() -> (timestamp: String, latitude: String, longitude: String, altitude: String)? {
        let t = String(NSDate().timeIntervalSince1970)
        let e = t.rangeOfString(".")
        let timestamp = t.substringToIndex((e?.startIndex)!)
        //        let timeStamp = NSDateFormatter()
        //        timeStamp.dateFormat = "yyyyMMddHHmmss"
        //        let timeCapture = timeStamp.stringFromDate(currentDate)
        
        var longitude = ""
        var latitude = ""
        var altitude = ""
        if let location = appDelegate.getLocation() {
            let gpsCheck = userDefaults.boolForKey("GPS-check")
            if gpsCheck {
                // Now performing gps check
                if location.verticalAccuracy > 150 || location.horizontalAccuracy > 150 {
                    // TODO: modal to tell the user that the gps signal is too poor.
                    return nil
                } else {
                    longitude = String(location.coordinate.longitude)
                    latitude = String(location.coordinate.latitude)
                    altitude = String(round(location.altitude))
                    return (timestamp, latitude, longitude, altitude)
                }
            } else {
                longitude = String(location.coordinate.longitude)
                latitude = String(location.coordinate.latitude)
                altitude = String(round(location.altitude))
                return (timestamp, latitude, longitude, altitude)
            }
        } else {
            return nil
        }
    }
}
