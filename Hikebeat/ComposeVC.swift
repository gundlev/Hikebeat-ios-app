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
    var audioHasBeenRecordedForThisBeat = false
    var imagePicker = UIImagePickerController()
    var currentMediaURL = NSURL()
    var currentImage = UIImage()
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
    }

    func memoButtonTapped() {
        print("memo")

    }
    
    func imageButtonTapped() {
        print("image")
        self.chooseImage()

    }
    
    func videoButtonTapped() {
        print("video")
        self.chooseVideo()

    }
    
    func messageButtonTapped() {
        print("message")
        
        performSegueWithIdentifier("editMessageModal", sender: self)
    }
    
    func applyGreenBorder(view :UIImageView) {
        view.layer.borderWidth = 4
        view.layer.borderColor = greenColor.CGColor
    }
    
    func disableMediaView(view :UIImageView) {
        view.userInteractionEnabled = false
        view.alpha = 0.4
    }

    func mediaChosen(type: String) {
        switch type {
            case "video":
                applyGreenBorder(editVideoButton)
                disableMediaView(editMemoButton)
                disableMediaView(editImageButton)
            case "image":
                applyGreenBorder(editImageButton)
                disableMediaView(editMemoButton)
                disableMediaView(editVideoButton)
            case "audio":
                applyGreenBorder(editMemoButton)
                disableMediaView(editVideoButton)
                disableMediaView(editImageButton)
        default: print("Type not matching: ", type)
        }
    }
    
    /*
     Sending beat functions
     */
    
    func checkForCorrectInput() {
        let locationTuple = self.getTimeAndLocation()
        print(0.1)
        if locationTuple != nil {
            print(0.2)
            if ((titleTextField.text == "" && messageTextView.text == "" && currentImage == nil && currentVideo == nil) || self.activeJourney == nil || locationTuple!.latitude == "" || locationTuple!.longitude == "" || locationTuple!.altitude == "") {
                print(0.3)
                // Give a warning that there is not text or no active journey.
                print("Something is missing")
                print("Text: ", titleTextField.text == "" && messageTextView.text == "" && currentImage == nil && currentVideo == nil)
                print("Journey: ", self.activeJourney == nil)
                print("Lat: ", locationTuple!.latitude)
                print("Lng: ", locationTuple!.longitude)
                
            } else {
                
                print(0.4)
                var title: String? = nil
                var message: String? = nil
                var mediaData: String? = nil
                var orientation: String? = nil
                var mediaType: String? = nil
                print(0.5)
                if titleTextField.text != "" || titleTextField.text != " " || titleTextField.text != "  " || titleText != "   " {
                    title = self.titleTextField.text
                }
                print(0.6)
                if messageTextView.text != "" || titleTextField.text != " " || titleTextField.text != "  " || titleTextField.text != "   "{
                    message = self.messageTextView.text
                }
                print(0.7)
                if currentImage != nil {
                    //print(1)
                    let imageData = UIImageJPEGRepresentation(currentImage!, 0.5)
                    mediaType = MediaType.image
                    //print(2)
                    mediaData = saveMediaToDocs(imageData!, journeyId: (activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp, fileType: ".jpg")

                } else if currentMediaURL != nil {
                    mediaType = MediaType.video
                    let newPath = getPathToFileFromName("vid-temp.mp4")
                    let success = covertToMedia(currentMediaURL!, pathToOuputFile: newPath!, fileType: AVFileTypeMPEG4)
                    if success {
                        let videoData = NSData(contentsOfURL: currentMediaURL!)
                        mediaData = saveMediaToDocs(videoData!, journeyId: (activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp, fileType: ".mp4")
                        if mediaData != nil {
                            self.removeMediaWithURL(currentMediaURL!)
                        }
                        print("mediaData: ", mediaData)
                    }
                    
                } else if audioHasBeenRecordedForThisBeat {
                    mediaType = MediaType.audio
                    let pathToAudio = getPathToFileFromName("audio-temp.acc")
                    let newPath = getPathToFileFromName("audio-temp.m4a")
                    covertToMedia(pathToAudio!, pathToOuputFile: newPath!, fileType: AVFileTypeAppleM4A)
                    let audioData = NSData(contentsOfURL: newPath!)
                    mediaData = saveMediaToDocs(audioData!, journeyId: (activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp, fileType: "m4a")
                    self.recorder.deleteRecording()
                }
                
                
                
                
                //            let locationTuple = self.getTimeAndLocation()
                print("Just Before Crash!")
                self.currentBeat = DataBeat(context: (self.stack?.mainContext)!, title: title, journeyId: activeJourney!.journeyId, message: message, latitude: locationTuple!.latitude, longitude: locationTuple!.longitude, altitude: locationTuple!.altitude, timestamp: locationTuple!.timestamp, mediaType: mediaType, mediaData: mediaData, mediaDataId: nil, messageId: nil, mediaUploaded: false, messageUploaded: false, orientation:  orientation, journey: activeJourney!)
                print("Just After Crash!")
                self.sendBeat()
            }
        } else {
            
        }
    }
    
    func sendBeat() {
        
        if ((titleTextField.text!.characters.count + messageTextView.text.characters.count) > 0) {
            
            // Check if there is any network connection and send via the appropriate means.
            if SimpleReachability.isConnectedToNetwork() {
                // TODO: send via alamofire
                let url = IPAddress + "journeys/" + (activeJourney?.journeyId)! + "/messages"
                print("url: ", url)
                
                var localTitle = ""
                var localMessage = ""
                if currentBeat!.message != nil {
                    localMessage = currentBeat!.message!
                }
                if currentBeat!.title != nil {
                    localTitle = currentBeat!.title!
                }
                // "headline": localTitle, "text": localMessage,
                var parameters = ["lat": currentBeat!.latitude, "lng": currentBeat!.longitude, "alt": currentBeat!.altitude, "timeCapture": currentBeat!.timestamp]
                if localTitle != "" {
                    parameters["headline"] = localTitle
                }
                if localMessage != "" {
                    parameters["text"] = localMessage
                }
                // Sending the beat message
                Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
                    print("The Response")
                    print(response.response?.statusCode)
                    print(response)
                    
                    // if response is 200 OK from server go on.
                    if response.response?.statusCode == 200 {
                        print("The text was send")
                        self.currentBeat?.messageUploaded = true
                        
                        // Save the messageId to the currentBeat
                        let rawMessageJson = JSON(response.result.value!)
                        let messageJson = rawMessageJson["data"][0]
                        self.currentBeat?.messageId = messageJson["_id"].stringValue
                        
                        // If the is an image in the currentBeat, send the image.
                        if self.currentBeat?.mediaData != nil {
                            print("There is an image or video")
                            // Send Image
                            
                            let filePath = self.getPathToFileFromName((self.currentBeat?.mediaData)!)
                            if filePath != nil {
                                let urlMedia = IPAddress + "journeys/" + (self.activeJourney?.journeyId)! + "/media"
                                print(urlMedia)
                                
                                var customHeader = Headers
                                
                                customHeader["x-hikebeat-timecapture"] = self.currentBeat?.timestamp
                                customHeader["x-hikebeat-type"] = self.currentBeat?.mediaType!
                                
                                Alamofire.upload(.POST, urlMedia,headers: customHeader, file: filePath!).responseJSON { mediaResponse in
                                    print("This is the media response: ", mediaResponse)
                                    
                                    // If everything is 200 OK from server save the imageId in currentBeat variable mediaDataId.
                                    if mediaResponse.response?.statusCode == 200 {
                                        let rawImageJson = JSON(mediaResponse.result.value!)
                                        let mediaJson = rawImageJson["data"][0]
                                        print(mediaResponse)
                                        print("The image has been posted")
                                        
                                        // Set the imageId in currentBeat
                                        print("messageId: ", mediaJson["_id"].stringValue)
                                        self.currentBeat?.mediaDataId = mediaJson["_id"].stringValue
                                        
                                        // Set the uploaded variable to true as the image has been uplaoded.
                                        self.currentBeat?.mediaUploaded = true
                                        saveContext(self.stack.mainContext)
                                    } else {
                                        print("Error posting the image")
                                        self.currentBeat?.mediaUploaded = false
                                        saveContext(self.stack.mainContext)
                                    }
                                    
                                    self.setInitial(true)
                                    self.swipeView.setBack(true)
                                    
                                }
                            }
                        } else {
                            print("There's no image")
                            self.currentBeat?.mediaUploaded = true
                            saveContext(self.stack.mainContext)
                            self.setInitial(true)
                            self.swipeView.setBack(true)
                        }
                        
                        //Likely not usefull call to saveContext -> Test it!!
                        saveContext(self.stack.mainContext)
                    } else {
                        // Error occured
                        print("Error posting the message")
                        alert("Problem sending", alertMessage: "Some error has occured when trying to send, it will be saved and syncronized later", vc: self, actions:
                            (title: "Ok",
                                style: UIAlertActionStyle.Cancel,
                                function: {}))
                        
                        
                        // Is set to true now but should be changed to false
                        self.currentBeat?.mediaUploaded = false
                        self.currentBeat?.messageUploaded = false
                        saveContext(self.stack.mainContext)
                    }
                    
                    // print(response)
                    // if the response is okay run:
                    // TODO: save the Beat
                    saveContext(self.stack.mainContext)
                    //                    self.saveCurrentBeat(uploaded)
                    //self.setInitial(true)
                }
                //                self.setInitial(true)
                //                self.swipeView.setBack(true)
            } else {
                
                // This will send it via SMS.
                print("Not reachable, should send sms")
                let messageText = self.genSMSMessageString(titleTextField.text!, message: messageTextView.text, journeyId: self.activeJourney!.journeyId)
                self.sendSMS(messageText)
                // The save and setInitial is done in the message methods as it knows whether it fails.
            }
            
            // TODO: save
            
        } else {
            //TODO: Set alert to tell user that there's no text.
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
}
