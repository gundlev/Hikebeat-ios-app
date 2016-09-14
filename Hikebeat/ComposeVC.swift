//
//  ComposeVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/23/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import RealmSwift
import AVKit
import AVFoundation
import Alamofire
import SwiftyJSON
import MessageUI
import BrightFutures
import Result
import CoreLocation

class ComposeVC: UIViewController, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate {

    var activeJourney: Journey?
    var realm = try! Realm()
    var messageText: String?
    var emotion: String?
    var audioHasBeenRecordedForThisBeat = false
    var imagePicker = UIImagePickerController()
    var currentMediaURL:NSURL?
    var currentImage:UIImage?
    var currentBeat: Beat?
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let greenColor = UIColor(red:189/255.0, green:244/255.0, blue:0, alpha:1.00)
    var beatPromise: Promise<Bool, NoError>!
    
    var currentModal: ModalVC?
    
    // Audio variables
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    var meterTimer:NSTimer!
    var soundFileURL:NSURL!
    var filledin: Int = 0
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var editMessageButton: UIImageView!
    @IBOutlet weak var editEmotionButton: UIImageView!
    @IBOutlet weak var editImageButton: UIImageView!
    @IBOutlet weak var sendBeatButton: UIButton!
    @IBOutlet weak var editMemoButton: UIImageView!
    @IBOutlet weak var editVideoButton: UIImageView!
    
    @IBOutlet weak var rightTree: UIImageView!
    @IBOutlet weak var leftTree: UIImageView!
    @IBOutlet weak var middleHouse: UIImageView!
    
    @IBOutlet weak var composeContainer: aCustomView!
    @IBOutlet weak var imageBG: UIImageView!
    
    @IBOutlet weak var NoActiveContainer: aCustomView!
    
    @IBOutlet weak var journeysButton: UIButton!
    
    @IBOutlet weak var noactiveTop: NSLayoutConstraint!
    
    @IBAction func sendBeat(sender: AnyObject) {
        print("up")
        rightTree.stopAnimating()
        stopSendAnimation()
        self.beatPromise = Promise<Bool, NoError>()
        checkForCorrectInput()
    }
    
    @IBAction func startHoldingToSend(sender: AnyObject) {
        print("down")
        startSendAnimation()
    }
    
    @IBAction func letGoOfHoldingOutside(sender: AnyObject) {
        print("up")
        rightTree.stopAnimating()
//        stopSendAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scaling the view for the screensize.
        if (UIDevice.isIphone5){
            composeContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.80, 0.80);
            composeContainer.transform = CGAffineTransformTranslate( composeContainer.transform, 0.0, -50.0  )
            
            NoActiveContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.80, 0.80);
            NoActiveContainer.transform = CGAffineTransformTranslate( NoActiveContainer.transform, 0.0, -50.0  )
            
            NoActiveContainer.button = journeysButton
            composeContainer.button = sendBeatButton
            
            imageBG.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.15, 1.15);
            imageBG.transform = CGAffineTransformTranslate( imageBG.transform, 0.0, +40.0  )
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            composeContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            composeContainer.transform = CGAffineTransformTranslate( composeContainer.transform, 0.0, 40.0  )
            
            
            NoActiveContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            NoActiveContainer.transform = CGAffineTransformTranslate( NoActiveContainer.transform, 0.0, 40.0  )
            
            NoActiveContainer.button = journeysButton
            composeContainer.button = sendBeatButton
            
            imageBG.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.85, 0.85);
            imageBG.transform = CGAffineTransformTranslate( imageBG.transform, 0.0, -45.0  )
        }else if (UIDevice.isIphone4 || UIDevice.isIpad){
            composeContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.65, 0.65);
            composeContainer.transform = CGAffineTransformTranslate( composeContainer.transform, 0.0, -110.0  )
            
            NoActiveContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75);
            NoActiveContainer.transform = CGAffineTransformTranslate( NoActiveContainer.transform, 0.0, -100.0  )
            
            NoActiveContainer.button = journeysButton
            composeContainer.button = sendBeatButton
            
            imageBG.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.15, 1.15);
            imageBG.transform = CGAffineTransformTranslate( imageBG.transform, 0.0, +80.0  )
        }
        
        sendBeatButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(startSendAnimation)))
        

        NoActiveContainer.button = journeysButton
        composeContainer.button = sendBeatButton
        
        filledin = 0
        clearButton.hidden = true
        
        editMessageButton.layer.cornerRadius = editMessageButton.bounds.width/2
        editEmotionButton.layer.cornerRadius = editEmotionButton.bounds.width/2
        editVideoButton.layer.cornerRadius = editVideoButton.bounds.width/2
        editMemoButton.layer.cornerRadius = editMemoButton.bounds.width/2
        editImageButton.layer.cornerRadius = editImageButton.bounds.width/2
        sendBeatButton.layer.cornerRadius = sendBeatButton.bounds.height/2
        journeysButton.layer.cornerRadius = journeysButton.bounds.height/2

        editMessageButton.layer.masksToBounds = true
        editEmotionButton.layer.masksToBounds = true
        editImageButton.layer.masksToBounds = true
        editVideoButton.layer.masksToBounds = true
        editMemoButton.layer.masksToBounds = true
        sendBeatButton.layer.masksToBounds = true
        journeysButton.layer.masksToBounds = true
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        
        editMessageButton.userInteractionEnabled = true
        editMemoButton.userInteractionEnabled = true
        editImageButton.userInteractionEnabled = true
        editVideoButton.userInteractionEnabled = true
        editEmotionButton.userInteractionEnabled = true
        
        editMessageButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(textButtonTapped)))
        editMemoButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(memoButtonTapped)))
        editImageButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(imageButtonTapped)))
        editVideoButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(videoButtonTapped)))
        editEmotionButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(emotionsButtonTapped)))
        
        
        if !findActiveJourney() {
            composeContainer.hidden = true
            NoActiveContainer.hidden = false
        }else{
            composeContainer.hidden = false
            NoActiveContainer.hidden = true
        }

    }
    
    
    
    override func viewWillAppear(animated: Bool) {
//        let isActiveJourney = findActiveJourney()
//        
//        if isActiveJourney{
//            print("There is an active journey!")
//        }
        
        if !findActiveJourney() {
            composeContainer.hidden = true
            NoActiveContainer.hidden = false
            
        }else{
            composeContainer.hidden = false
            NoActiveContainer.hidden = true
        }
    }
    
    @IBAction func unwindToCompose(sender: UIStoryboardSegue)
    {
//        let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
        filledin==0 ? hideClearButton() : showClearButton()
    }
    
    func longTap(sender : UIGestureRecognizer){
        print("Long tap")
        if sender.state == .Ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .Began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
        }
    }
    
    func startSendAnimation() {
        print("press")
//        let width = self.view.frame.width
//        UIImageView.animateWithDuration(NSTimeInterval(2)) {
//            self.leftTree.transform = CGAffineTransformTranslate(self.leftTree.transform, -width/5, 0)
//            self.rightTree.transform = CGAffineTransformTranslate(self.rightTree.transform, width/5, 0)
//            self.middleHouse.transform = CGAffineTransformTranslate(self.middleHouse.transform, 0, -30)
//        }
    }
    
    func stopSendAnimation() {
        UIView.animateWithDuration(NSTimeInterval(2)) {
            self.leftTree.transform = CGAffineTransformTranslate(self.leftTree.transform, 0, 0)
            self.rightTree.transform = CGAffineTransformTranslate(self.rightTree.transform, 0, 0)
            self.middleHouse.transform = CGAffineTransformTranslate(self.middleHouse.transform, 0, 0)
        }

    }


    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func textButtonTapped() {
        print("text")
        performSegueWithIdentifier("editMessageModal", sender: self)
    }

    func memoButtonTapped() {
        print("memo")
        performSegueWithIdentifier("recordAudio", sender: self)
    }
    
    
    @IBAction func clearButtonTapped(sender: AnyObject) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Clear it!") {
            self.clearAllForNewBeat()
        }
        alertView.addButton("Cancel") {}
        
        alertView.showWarning("Clear Beat?", subTitle: "\nAre you sure you want to clear what progress you have made on this beat?")
    }
    
    func imageButtonTapped() {
        print("image")
        self.chooseImage()
    }
    
    func videoButtonTapped() {
        print("video")
        self.chooseVideo()
    }
    
    func emotionsButtonTapped() {
        print("emotions")
        performSegueWithIdentifier("editEmotionsModal", sender: self)
    }
    
    func applyGreenBorder(view :UIImageView) {
        filledin += 1
        view.layer.borderWidth = 4
        view.layer.borderColor = greenColor.CGColor
    }
    
    func removeGreenBorder(view: UIImageView) {
        view.layer.borderWidth = 0
    }
    
    func showClearButton(){
        clearButton.hidden = false
    }
    
    func hideClearButton(){
        clearButton.hidden = true
    }
    
    func clearAllForNewBeat() {
        print("Clearing for new beat")
        removeGreenBorder(self.editMessageButton)
        removeGreenBorder(self.editEmotionButton)
        removeGreenBorder(self.editMemoButton)
        removeGreenBorder(self.editImageButton)
        removeGreenBorder(self.editVideoButton)
        self.messageText = nil
        self.emotion = nil
        self.currentBeat = nil
        self.currentImage = nil
        self.currentMediaURL = nil
        filledin = 0
        hideClearButton()
        enableMediaView(self.editMemoButton)
        enableMediaView(self.editImageButton)
        enableMediaView(self.editVideoButton)
        editEmotionButton.image = UIImage(named: "ComposeMessage")
    }
    
    func disableMediaView(view :UIImageView) {
        view.userInteractionEnabled = false
        view.alpha = 0.4
    }
    
    func enableMediaView(view :UIImageView) {
        view.userInteractionEnabled = true
        view.alpha = 1
    }

    
    @IBAction func gotoJourneys(sender: AnyObject) {
        self.tabBarController?.selectedIndex = 0
        let tabVC = self.tabBarController as! HikebeatTabBarVC
        tabVC.deselectCenterButton()
        
    }
    
    func mediaChosen(type: String) {
        switch type {
            case "video":
                applyGreenBorder(editVideoButton)
                disableMediaView(editMemoButton)
                disableMediaView(editImageButton)
                showClearButton()
            case "image":
                applyGreenBorder(editImageButton)
                disableMediaView(editMemoButton)
                disableMediaView(editVideoButton)
                showClearButton()
            case "audio":
                applyGreenBorder(editMemoButton)
                disableMediaView(editVideoButton)
                disableMediaView(editImageButton)
                showClearButton()
        default: print("Type not matching: ", type)
        }
    }
    
    
/*
     Realm calls
*/
    
    func findActiveJourney() -> Bool {
        let journeys = realm.objects(Journey).filter("active = %@", true)
        if journeys.isEmpty {
            return false
        } else {
            self.activeJourney = journeys[0]
            return true
        }

    }
    
    
/*
     Sending beat functions
*/
    
    func checkForCorrectInput() {
        print("Now checking")
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            print("has gps permission")
            let locationTupleFuture = self.getTimeAndLocation()
            locationTupleFuture.onSuccess { (locationTuple) in
                if locationTuple != nil {
                    if ((self.messageText == nil && self.emotion == nil && self.currentImage == nil && self.currentMediaURL == nil) || self.activeJourney == nil || locationTuple!.latitude == "" || locationTuple!.longitude == "" || locationTuple!.altitude == "") {
                        print(0.3)
                        // Give a warning that there is not text or no active journey.
                        print("Something is missing")
                        print("Text: ", self.messageText == nil && self.emotion == nil && self.currentImage == nil && self.currentMediaURL == nil)
                        print("Journey: ", self.activeJourney == nil)
                        print("Lat: ", locationTuple!.latitude)
                        print("Lng: ", locationTuple!.longitude)
                        
                    } else {
                        
                        print(0.4)
                        var mediaData: String? = nil
                        var mediaType: String? = nil
                        print(0.7)
                        if self.currentImage != nil {
                            //print(1)
                            let imageData = UIImageJPEGRepresentation(self.currentImage!, 0.4)
                            mediaType = MediaType.image
                            //print(2)
                            mediaData = self.saveMediaToDocs(imageData!, journeyId: (self.activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp, fileType: ".jpg")
                            
                        } else if self.currentMediaURL != nil {
                            mediaType = MediaType.video
                            let newPath = self.getPathToFileFromName("vid-temp.mp4")
                            let success = covertToMedia(self.currentMediaURL!, pathToOuputFile: newPath!, fileType: AVFileTypeMPEG4)
                            if success {
                                let videoData = NSData(contentsOfURL: self.currentMediaURL!)
                                mediaData = self.saveMediaToDocs(videoData!, journeyId: (self.activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp, fileType: ".mp4")
                                if mediaData != nil {
                                    self.removeMediaWithURL(self.currentMediaURL!)
                                }
                                //print("mediaData: ", mediaData)
                            }
                            
                        } else if self.audioHasBeenRecordedForThisBeat {
                            mediaType = MediaType.audio
                            let pathToAudio = self.getPathToFileFromName("audio-temp.acc")
                            let newPath = self.getPathToFileFromName("audio-temp.m4a")
                            covertToMedia(pathToAudio!, pathToOuputFile: newPath!, fileType: AVFileTypeAppleM4A)
                            let audioData = NSData(contentsOfURL: newPath!)
                            mediaData = self.saveMediaToDocs(audioData!, journeyId: (self.activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp, fileType: ".m4a")
                            //self.recorder.deleteRecording()
                        }
                        
                        //            let locationTuple = self.getTimeAndLocation()
                        print("Just Before Crash!")
                        self.currentBeat = Beat()
                        self.currentBeat!.fill( self.emotion, journeyId: self.activeJourney!.journeyId, message: self.messageText, latitude: locationTuple!.latitude, longitude: locationTuple!.longitude, altitude: locationTuple!.altitude, timestamp: locationTuple!.timestamp, mediaType: mediaType, mediaData: mediaData, mediaDataId: nil, mediaUrl: nil, messageId: nil, mediaUploaded: false, messageUploaded: false, journey: self.activeJourney!)
                        //                try! realm.write() {
                        //                    realm.add(self.currentBeat!)
                        //                }
                        
                        print("Just After Crash!")
                        self.sendBeat()
                    }
                } else {
                    print("location tuple is nil")
                }
                
            }

        } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            
            alertView.addButton("Yes") {
                UIApplication.openAppSettings()
            }
            alertView.addButton("No", action: {})
            alertView.showInfo("Allow GPS?", subTitle: "\nYou have previously said no to allowing the app access to your location. Would you like to go to settings and change this?")

        } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            
            alertView.addButton("Yes") {
                self.appDelegate.startLocationManager()
            }
            alertView.addButton("No") {}
            
            alertView.showInfo("Allow GPS?", subTitle: "\nTo be able to show people your awesome journey and place you on a map we need your location. Will you allow the app access to your location?")
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("change in location status to: ", status)
        if (status == CLAuthorizationStatus.Denied) {
            // The user denied authorization
            // Discuss with the guys what to do here
        } else if (status == CLAuthorizationStatus.AuthorizedWhenInUse) {
            // The user accepted authorization
            self.checkForCorrectInput()
        }
    }
    
    func sendBeat() {
            print("sending beat start")
            // Check if there is any network connection and send via the appropriate means.
            if SimpleReachability.isConnectedToNetwork() {
                // TODO: send via alamofire
                let url = IPAddress + "journeys/" + (activeJourney?.journeyId)! + "/messages"
                print("url: ", url)

                // "headline": localTitle, "text": localMessage,
                var parameters = ["lat": currentBeat!.latitude, "lng": currentBeat!.longitude, "alt": currentBeat!.altitude, "timeCapture": currentBeat!.timestamp]
                if currentBeat!.emotion != nil {
                    parameters["emotion"] = emotionToNumber((currentBeat?.emotion)!)
                }
                if currentBeat!.message != nil {
                    parameters["text"] = currentBeat?.message
                }
                // Sending the beat message
                performSegueWithIdentifier("showGreenModal", sender: nil)
                Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
                    print("The Response")
                    print(response.response?.statusCode)
                    print(response)
                    
                    // if response is 200 OK from server go on.
                    if response.response?.statusCode == 200 {
                        print("The text was send")
                        
                        
                        // Save the messageId to the currentBeat
                        let rawMessageJson = JSON(response.result.value!)
                        let messageJson = rawMessageJson["data"][0]
                        //try! self.realm.write() {
                            self.currentBeat?.messageUploaded = true
                            self.currentBeat?.messageId = messageJson["_id"].stringValue
                        //}
 
                        
                        // If the is an image in the currentBeat, send the image.
                        if self.currentBeat?.mediaData != nil {
                            print("There is an image or video")
                            // Send Image
                            
                            let filePath = self.getPathToFileFromName((self.currentBeat?.mediaData)!)
                            if filePath != nil {
                                let urlMedia = IPAddress + "journeys/" + (self.activeJourney?.journeyId)! + "/media"
                                print(urlMedia)
                                
                                var customHeader = Headers
                                
                                customHeader["x-hikebeat-timeCapture"] = self.currentBeat?.timestamp
                                customHeader["x-hikebeat-type"] = self.currentBeat?.mediaType!
                                
                                // Get and set progressView
                                self.currentModal!.addProgressBar("Uploading " + (self.currentBeat?.mediaType!)!)
                                
                                Alamofire.upload(.POST, urlMedia,headers: customHeader, file: filePath!).progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                                    //print(totalBytesWritten)
                                    
                                    // This closure is NOT called on the main queue for performance
                                    // reasons. To update your ui, dispatch to the main queue.
                                    dispatch_async(dispatch_get_main_queue()) {
                                        
                                        print("Total bytes written on main queue: \(totalBytesWritten) out of \(totalBytesExpectedToWrite)")
                                        print("Bytes writtn now: \(totalBytesWritten)")
                                        
                                        let bytePercentage = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                                        self.currentModal?.progressBar?.progress = bytePercentage
//                                        let localIncrease = increase * byteIncreasePercentage
//                                        progressView.progress = progressView.progress + localIncrease
                                    }
                                    }.responseJSON { mediaResponse in
                                    print("This is the media response: ", mediaResponse)
                                    print("Response", mediaResponse.response)
                                    print("Debug Description", mediaResponse.debugDescription)
                                    print("Description", mediaResponse.description)
                                    print("Request", mediaResponse.request)
                                    
                                    // If everything is 200 OK from server save the imageId in currentBeat variable mediaDataId.
                                    if mediaResponse.response?.statusCode == 200 {
                                        let rawImageJson = JSON(mediaResponse.result.value!)
                                        let mediaJson = rawImageJson["data"][0]
                                        print(mediaResponse)
                                        print("The image has been posted")
                                        
                                        // Set the imageId in currentBeat
                                        print("messageId: ", mediaJson["_id"].stringValue)
                                        
                                        
                                        // Set the uploaded variable to true as the image has been uplaoded.
                                        
                                        try! self.realm.write {
                                            self.currentBeat?.mediaDataId = mediaJson["_id"].stringValue
                                            self.currentBeat?.mediaUploaded = true
                                            self.activeJourney?.beats.append(self.currentBeat!)
                                        }
                                        
                                        self.clearAllForNewBeat()
                                    } else {
                                        print("Error posting the image")
                                        
                                        try! self.realm.write {
                                            self.currentBeat?.mediaUploaded = false
                                            self.activeJourney?.beats.append(self.currentBeat!)
                                        }
                                    }
                                    self.beatPromise.success(true)
                                }
                            }
                        } else {
                            print("There's no image")
                            
                            try! self.realm.write {
                                self.currentBeat?.mediaUploaded = true
                                self.activeJourney?.beats.append(self.currentBeat!)
                            }
                            self.clearAllForNewBeat()
                            self.beatPromise.success(true)
                        }
                        
                        //Likely not usefull call to saveContext -> Test it!!
                    } else {
                        // Response is not 200
                        print("Error posting the message")
//                        alert("Problem sending", alertMessage: "Some error has occured when trying to send, it will be saved and syncronized later", vc: self, actions:
//                            (title: "Ok",
//                                style: UIAlertActionStyle.Cancel,
//                                function: {}))
                        let appearance = SCLAlertView.SCLAppearance(
                            showCloseButton: false
                        )
                        let alertView = SCLAlertView(appearance: appearance)
                        
                        alertView.addButton("Yes") {
                            self.sendTextMessage()
                        }
                        alertView.addButton("No thanks") {}
                        
                        alertView.showInfo("Problem sending", subTitle: "\nSome error has occured when contacting the server, would you like to send a text message instead?")
//                        SCLAlertView().showError("Problem sending", subTitle: "Some error has occured when contacting the server, would you like to send a text message instead?")
                        
                        // Is set to true now but should be changed to false
                        // TODO: This should be uncommented when
//                        try! self.realm.write {
//                            self.currentBeat?.mediaUploaded = false
//                            self.currentBeat?.messageUploaded = false
//                            self.activeJourney?.beats.append(self.currentBeat!)
//                        }
                    }
                    
                }

            } else {
                // check for permitted phoneNumber
                //                }
                sendTextMessage()
                // The save and setInitial is done in the message methods as it knows whether it fails.
            }
            
            // TODO: save
    }
    
    func sendTextMessage() {
        guard let phoneNumbers = userDefaults.stringForKey("permittedPhoneNumbers") else {
            presentMissingPhoneNumberAlert()
            return
        }
        
        guard phoneNumbers != "" else {
            presentMissingPhoneNumberAlert()
            return
        }
        
        //                if phoneNumbers == "" {
        //                    presentMissingPhoneNumberAlert()
        ////                    try! realm.write() {
        ////                        realm.delete(self.currentBeat!)
        ////                    }
        //                } else {
        // This will send it via SMS.
        print("Not reachable, should send sms")
        var emotionString = ""
        var messageString = ""
        if self.messageText != nil {
            messageString = self.messageText!
        }
        if self.emotion != nil {
            emotionString = emotionToNumber(self.emotion!)
        }
        
        let messageText = self.genSMSMessageString(emotionString, message: messageString, seqNumber: self.activeJourney!.seqNumber!)
        self.sendSMS(messageText)

    }
    
    func presentMissingPhoneNumberAlert() {
        let alertView = SCLAlertView()
        alertView.addButton("Go to profile") {
            print("Second button tapped")
            self.tabBarController?.selectedIndex = 3
            let tabVC = self.tabBarController as! HikebeatTabBarVC
            tabVC.deselectCenterButton()
        }
        alertView.showWarning("Missing Phone number", subTitle: "You have to add a phone number in your profile to be able to send text messages. We need to know the text is comming from you")
    }
    
/*
     SMS functions
*/
    
    func genSMSMessageString(emotion: String, message: String, seqNumber: String) -> String {
        
        print("timestamp deci: ", self.currentBeat?.timestamp)
        print("timestamp hex: ", hex(Double((self.currentBeat?.timestamp)!)!))
        print("lat: ", hex(Double((self.currentBeat?.latitude)!)!))
        print("lng: ", hex(Double((self.currentBeat?.longitude)!)!))
        var mediaComming = ""
        if currentBeat?.mediaData != nil {
            switch currentBeat!.mediaType! {
            case MediaType.image:
                mediaComming = " i"
            case MediaType.video:
                mediaComming = " v"
            case MediaType.audio:
                mediaComming = " a"
            default:
                print("error in setting mediatype in sms")
            }
        }
        let smsMessageText = seqNumber + " " + hex(Double((self.currentBeat?.timestamp)!)!) + " " + hex(Double((self.currentBeat?.latitude)!)!) + " " + hex(Double((self.currentBeat?.longitude)!)!) + " " + hex(Double(self.currentBeat!.altitude)!) + mediaComming + " " + emotion + "##" + message
        
        return smsMessageText
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        
        
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message Cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message Failed")
            
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            print("Message Sent")
            
            /* Save the Beat and setInitial*/
            if currentBeat?.mediaData != nil {
                print("SMS function: There is an image")
                try! realm.write() {
                    self.currentBeat?.mediaUploaded = false
                }
            } else {
                print("SMS function: There is no image")
                try! realm.write() {
                    self.currentBeat?.mediaUploaded = true
                }
            }
            
            try! self.realm.write {
                self.currentBeat?.messageUploaded = true
                self.activeJourney?.beats.append(self.currentBeat!)
            }
            self.clearAllForNewBeat()
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    
    /**
     This method starts a text message view controller with the settings specified.
     
     - parameters:
     - String: The text body composed of title, text, lattitude, longitude, timestamp and journeyId.
     - returns: Nothing as we have a seperate method to handle the result:
     `messageComposeViewController(controller:, didFinishWithResult result:)`.
     
     */
    func sendSMS(smsBody: String) {
        
        print("In sms function")
        let messageVC = MFMessageComposeViewController()
        if MFMessageComposeViewController.canSendText() {
            messageVC.body = smsBody
            messageVC.recipients = [phoneNumber]
            messageVC.messageComposeDelegate = self;
            
            self.presentViewController(messageVC, animated: false, completion: nil)
        }
    }

    
/*
     Utility Functions
*/
    
    /**
     function to get the timestamp and location.
     
     - parameters:
     - nil
     
     - returns: Bundle with 4 strings: timestamp, latitude, longitude, altitude.
     */
    func getTimeAndLocation() -> Future<(timestamp: String, latitude: String, longitude: String, altitude: String)?, NoError> {
        let t = String(NSDate().timeIntervalSince1970)
        let e = t.rangeOfString(".")
        let timestamp = t.substringToIndex((e?.startIndex)!)
        let promise = Promise<(timestamp: String, latitude: String, longitude: String, altitude: String)?, NoError>()
        //        let timeStamp = NSDateFormatter()
        //        timeStamp.dateFormat = "yyyyMMddHHmmss"
        //        let timeCapture = timeStamp.stringFromDate(currentDate)
        
        var longitude = ""
        var latitude = ""
        var altitude = ""
        if let location = appDelegate.getLocation() {
            print("location 2. lat: ", location.coordinate.latitude, "lng: ", location.coordinate.longitude)
            let gpsCheck = userDefaults.boolForKey("GPS-check")
            if gpsCheck {
                // Now performing gps check
                if location.horizontalAccuracy > 200 {
                    // TODO: modal to tell the user that the gps signal is too poor.
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)

                    alertView.addButton("Yes") {
                        longitude = String(location.coordinate.longitude)
                        latitude = String(location.coordinate.latitude)
                        altitude = String(round(location.altitude))
                        print("location 3. lat: ", location.coordinate.latitude, "lng: ", location.coordinate.longitude)
                        promise.success((timestamp: timestamp, latitude: latitude, longitude: longitude, altitude: altitude))
                    }
                    alertView.addButton("No") {
                        promise.success(nil)
                    }
                    
                    alertView.showWarning("Poor GPS precision", subTitle: "\nYour GPS precision is poor, would you like to send a beat anyway?")
                } else {
                    longitude = String(location.coordinate.longitude)
                    latitude = String(location.coordinate.latitude)
                    altitude = String(round(location.altitude))
                    print("location 3. lat: ", location.coordinate.latitude, "lng: ", location.coordinate.longitude)
                    promise.success((timestamp: timestamp, latitude: latitude, longitude: longitude, altitude: altitude))
                }
            } else {
                longitude = String(location.coordinate.longitude)
                latitude = String(location.coordinate.latitude)
                altitude = String(round(location.altitude))
                print("location 4. lat: ", location.coordinate.latitude, "lng: ", location.coordinate.longitude)
                promise.success((timestamp: timestamp, latitude: latitude, longitude: longitude, altitude: altitude))
            }
        } else {
            print("why here")
//            return nil
        }
        return promise.future
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "editEmotionsModal":
            if self.emotion != nil {
                print(1)
                let vc = segue.destinationViewController as! EditTitleVC
                vc.emotion = self.emotion!
                print(1.1)
            }
        case "editMessageModal":
            if self.messageText != nil {
                let vc = segue.destinationViewController as! EditMessageVC
                vc.text = self.messageText!
            }
        case "showGreenModal":
            let vc = segue.destinationViewController as! ModalVC
            vc.future = self.beatPromise.future
            currentModal = vc
        default:
            break
        }
    }
}
