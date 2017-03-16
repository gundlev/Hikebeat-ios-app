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
    var journeys: Results<Journey>?
    var activeIndexpath: IndexPath!
    var realm = try! Realm()
    var messageText: String?
    var emotion: String?
    var audioHasBeenRecordedForThisBeat = false
    var imagePicker = UIImagePickerController()
    var currentMediaURL:URL?
    var currentImage:UIImage?
    var currentBeat: Beat?
    var currentBeatDate: Date?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefaults = UserDefaults.standard
    let greenColor = UIColor(red:189/255.0, green:244/255.0, blue:0, alpha:1.00)
    var memoButtonCenterX: CGFloat = 0.0
    var imageButtonCenterX: CGFloat = 0.0
    
    func r(data: String) {
        
    }
    
    var beatPromise: Promise<String, NoError>!
    var showingJourneySelect = false
    var firstLoad = true
    var currentModal: ModalVC?
    
    // Audio variables
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    var meterTimer:Timer!
    var soundFileURL:URL!
    var filledin: Int = 0
    
    @IBOutlet weak var activeJourneyButton: UIButton!
    @IBOutlet weak var tableViewSelectJourney: UITableView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var editMessageButton: UIImageView!
    @IBOutlet weak var editEmotionButton: UIImageView!
    @IBOutlet weak var editImageButton: UIImageView!
    @IBOutlet weak var sendBeatButton: UIButton!
    @IBOutlet weak var editMemoButton: UIImageView!
    @IBOutlet weak var editVideoButton: UIImageView!
    @IBOutlet weak var hikebeatTopLogo: UIImageView!
    
    @IBOutlet weak var editVideoText: UILabel!
    @IBOutlet weak var editMemoText: UILabel!
    @IBOutlet weak var editImageText: UILabel!
    
    @IBOutlet weak var mediaAdded: UILabel!
    
    @IBOutlet weak var rightTree: UIImageView!
    @IBOutlet weak var leftTree: UIImageView!
    @IBOutlet weak var middleHouse: UIImageView!
    
    @IBOutlet weak var composeContainer: aCustomView!
    @IBOutlet weak var imageBG: UIImageView!
    
    @IBOutlet weak var NoActiveContainer: aCustomView!
    
    @IBOutlet weak var journeysButton: UIButton!
    
    @IBOutlet weak var noactiveTop: NSLayoutConstraint!
    
    @IBOutlet weak var noActiveJourneyHouses: UIImageView!
    @IBOutlet weak var noActiveJourneyButton: UIButton!
    @IBOutlet weak var noActiveJourneyTitle: UILabel!
    @IBOutlet weak var noActiveJourneyText: UILabel!
    @IBOutlet weak var noActiveJourneyImage: UIImageView!
    @IBAction func chooseActiveJourney(_ sender: Any) {
        if showingJourneySelect {
            animateSelectJourneyUp(animated: true)
        } else {
            animateSelectJourneyDown(animated: true)
        }
        showingJourneySelect = !showingJourneySelect
    }
    
    @IBAction func sendBeat(_ sender: AnyObject) {
        print("up")
        rightTree.stopAnimating()
        stopSendAnimation()
        self.beatPromise = Promise<String, NoError>()
        checkForCorrectInput()
    }
    
    @IBAction func startHoldingToSend(_ sender: AnyObject) {
        print("down")
        startSendAnimation()
    }
    
    @IBAction func letGoOfHoldingOutside(_ sender: AnyObject) {
        print("up")
        rightTree.stopAnimating()
//        stopSendAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.activeJourneyButton.imageView?.image = UIImage(named: "SearchIconiOS")
        self.tableViewSelectJourney.translatesAutoresizingMaskIntoConstraints = true
        memoButtonCenterX = editMemoButton.center.x
        imageButtonCenterX = editImageButton.center.x
        mediaAdded.isHidden = true
        // Scaling the view for the screensize.
        if (UIDevice.isIphone5){
            composeContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.80, y: 0.80);
            composeContainer.transform = composeContainer.transform.translatedBy(x: 0.0, y: -50.0  )
            
            NoActiveContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.80, y: 0.80);
            NoActiveContainer.transform = NoActiveContainer.transform.translatedBy(x: 0.0, y: -50.0  )
            
            NoActiveContainer.button = journeysButton
            composeContainer.button = sendBeatButton
            
            imageBG.transform = CGAffineTransform.identity.scaledBy(x: 1.15, y: 1.15);
            imageBG.transform = imageBG.transform.translatedBy(x: 0.0, y: +40.0  )
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            composeContainer.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1);
            composeContainer.transform = composeContainer.transform.translatedBy(x: 0.0, y: 40.0  )
            
            
            NoActiveContainer.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1);
            NoActiveContainer.transform = NoActiveContainer.transform.translatedBy(x: 0.0, y: 40.0  )
            
            NoActiveContainer.button = journeysButton
            composeContainer.button = sendBeatButton
            
            imageBG.transform = CGAffineTransform.identity.scaledBy(x: 0.85, y: 0.85);
            imageBG.transform = imageBG.transform.translatedBy(x: 0.0, y: -45.0  )
        }else if (UIDevice.isIphone4 || UIDevice.isIpad){
            composeContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.65, y: 0.65);
            composeContainer.transform = composeContainer.transform.translatedBy(x: 0.0, y: -110.0  )
            
            NoActiveContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.75, y: 0.75);
            NoActiveContainer.transform = NoActiveContainer.transform.translatedBy(x: 0.0, y: -100.0  )
            
            NoActiveContainer.button = journeysButton
            composeContainer.button = sendBeatButton
            
            imageBG.transform = CGAffineTransform.identity.scaledBy(x: 1.15, y: 1.15);
            imageBG.transform = imageBG.transform.translatedBy(x: 0.0, y: +80.0  )
        }
        
        sendBeatButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(startSendAnimation)))
        

        NoActiveContainer.button = journeysButton
        composeContainer.button = sendBeatButton
        
        filledin = 0
        clearButton.isHidden = true
        
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
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        activeJourneyButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        
        editMessageButton.isUserInteractionEnabled = true
        editMemoButton.isUserInteractionEnabled = true
        editImageButton.isUserInteractionEnabled = true
        editVideoButton.isUserInteractionEnabled = true
        editEmotionButton.isUserInteractionEnabled = true
        
        editMessageButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(textButtonTapped)))
        editMemoButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(memoButtonTapped)))
        editImageButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(imageButtonTapped)))
        editVideoButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(videoButtonTapped)))
        editEmotionButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(emotionsButtonTapped)))
        
        findActiveJourney()
    }
    
//    func checkForActiveJourney() {
//        handleScreenPresentation()
//    }
    
    override func viewDidAppear(_ animated: Bool) {
//        animateSelectJourneyUp(animated: false)
        if firstLoad {
            let center = self.tableViewSelectJourney.center
            self.tableViewSelectJourney.center = CGPoint(x: center.x, y:center.y-self.tableViewSelectJourney.frame.height)
            self.tableViewSelectJourney.isHidden = false
            firstLoad = false
        }
        handleViewPresentation()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        handleViewPresentation()
        self.tableViewSelectJourney.reloadData()
    }
    
    func handleViewPresentation() {
        guard !journeys!.isEmpty else {
            setViewTo(state: .noJourneys)
            print("STATE: ", ComposeState.noJourneys)
            return
        }
        
        guard findActiveJourney() else {
            setViewTo(state: .noActiveJourney)
            print("STATE: ", ComposeState.noActiveJourney)
            return
        }
        
        guard CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse else {
            setViewTo(state: .noGPS)
            print("STATE: ", ComposeState.noGPS)
            return
        }
        print("STATE: ", ComposeState.composeBeat)
        setViewTo(state: .composeBeat)
    }
    
    func setViewTo(state: ComposeState) {
        switch state {
        case .noJourneys:
            hikebeatTopLogo.isHidden = false
            activeJourneyButton.isHidden = true
            setPlaceholderScreen(title: "Welcome to Hikebeat!",
                                 text: "To get started, please create your first journey.",
                                 image: "welcome_logo",
                                 selector: #selector(gotoJourneys),
                                 buttonTitle: "Create a journey",
                                 showHouses: true)
        case .noActiveJourney:
            hikebeatTopLogo.isHidden = true
            activeJourneyButton.isHidden = false
            setPlaceholderScreen(title: "Select a journey!",
                                 text: "Please select a journey from the drop-down above.",
                                 image: "NoActiveJourney",
                                 selector: nil,
                                 buttonTitle: nil,
                                 showHouses: false)
        case .noGPS:
            print("no gps")
            composeContainer.isHidden = false
            NoActiveContainer.isHidden = true
//            setPlaceholderScreen(title: "Almost there!",
//                                 text: "In order to show the people at home where you are, you have to allow the GPS to be on.",
//                                 image: "GPSIcon",
//                                 selector: #selector(askForGPSPermission),
//                                 buttonTitle: "Allow GPS",
//                                 showHouses: false)
        case .composeBeat:
            composeContainer.isHidden = false
            NoActiveContainer.isHidden = true
        }
    }
    
    func askForGPSPermission() {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
            UIApplication.openAppSettings()
        }
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
            let success = self.appDelegate.startLocationManager()
        }
    }
    
    func setPlaceholderScreen(title: String, text: String, image: String, selector: Selector?, buttonTitle: String?, showHouses: Bool) {
        composeContainer.isHidden = true
        NoActiveContainer.isHidden = false
        noActiveJourneyText.text = text
        noActiveJourneyTitle.text = title
        noActiveJourneyImage.image = UIImage(named: image)
        noActiveJourneyButton.isHidden = selector == nil
        noActiveJourneyHouses.isHidden = !showHouses
        if selector != nil {
            noActiveJourneyButton.removeTarget(self, action: nil, for: .touchUpInside)
            noActiveJourneyButton.addTarget(self, action: selector!, for: .touchUpInside)
            noActiveJourneyButton.setTitle(buttonTitle, for: .normal)
            journeysButton.setTitle(buttonTitle, for: .normal)
            journeysButton.setTitle(buttonTitle, for: .highlighted)
            journeysButton.setTitle(buttonTitle, for: .selected)
            journeysButton.setTitle(buttonTitle, for: .focused)

            journeysButton.addTarget(self, action: selector!, for: .touchUpInside)
        }
    }
    
//    func handleScreenPresentation(){
//        if !findActiveJourney() {
//            composeContainer.isHidden = true
//            NoActiveContainer.isHidden = false
//            noActiveJourneyText.text = journeys!.isEmpty ? "To get started, please create your first journey." : "Please select a journey from the drop-down above."
//            noActiveJourneyTitle.text = journeys!.isEmpty ? "Welcome to Hikebeat!" : "Select a journey!"
//            noActiveJourneyImage.image = UIImage(named: journeys!.isEmpty ? "welcome_logo" : "NoActiveJourney")
//            noActiveJourneyButton.isHidden = !journeys!.isEmpty
//            noActiveJourneyHouses.isHidden = !journeys!.isEmpty
//        }else{
//            composeContainer.isHidden = false
//            NoActiveContainer.isHidden = true
//        }
//    }
    
    @IBAction func unwindToCompose(_ sender: UIStoryboardSegue) {
//        let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
        filledin==0 ? hideClearButton() : showClearButton()
    }
    
    func changeLocationStatus(data: CLAuthorizationStatus) {
        
    }
    
    func longTap(_ sender : UIGestureRecognizer){
        print("Long tap")
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
        }
        else if sender.state == .began {
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
        UIView.animate(withDuration: Foundation.TimeInterval(2), animations: {
            self.leftTree.transform = self.leftTree.transform.translatedBy(x: 0, y: 0)
            self.rightTree.transform = self.rightTree.transform.translatedBy(x: 0, y: 0)
            self.middleHouse.transform = self.middleHouse.transform.translatedBy(x: 0, y: 0)
        }) 

    }


    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func textButtonTapped() {
        print("text")
        performSegue(withIdentifier: "editMessageModal", sender: self)
    }

    func memoButtonTapped() {
        print("memo")
        performSegue(withIdentifier: "recordAudio", sender: self)
    }
    
    
    @IBAction func clearButtonTapped(_ sender: AnyObject) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        
        _ = alertView.addYellowButton("Clear it!") {
            self.clearAllForNewBeat(beatSend: false)
        }
        _ = alertView.addCancelButton()
        
        _ = alertView.showWarning("Clear Beat?", subTitle: "\nAre you sure you want to clear what progress you have made on this beat?")
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
        performSegue(withIdentifier: "editEmotionsModal", sender: self)
    }
    
    func applyGreenBorder(_ view :UIImageView) {
        filledin += 1
        view.layer.borderWidth = 4
        view.layer.borderColor = self.greenColor.cgColor
    }
    
    func removeGreenBorder(_ view: UIImageView) {
        view.layer.borderWidth = 0
    }
    
    func moveViewToCenter(_ view: UIImageView) {
        UIView.animate(withDuration: 0.5, animations: {
            view.center.x = self.editVideoButton.center.x
        })
    }
    
    func showClearButton(){
        clearButton.isHidden = false
    }
    
    func hideClearButton(){
        clearButton.isHidden = true
    }
    
    func clearAllForNewBeat(beatSend: Bool) {
        if beatSend {
            try! realm.write {
                self.activeJourney?.latestBeat = self.currentBeatDate
            }
        }
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
        self.currentBeatDate = nil
        self.audioHasBeenRecordedForThisBeat = false
        filledin = 0
        hideClearButton()
        enableMediaView(self.editMemoButton, type: "memo")
        enableMediaView(self.editImageButton, type: "image")
        enableMediaView(self.editVideoButton, type: "video")
        editEmotionButton.image = UIImage(named: "ComposeMessage")
        editImageText.isHidden = false
        editVideoText.isHidden = false
        editMemoText.isHidden = false
        mediaAdded.isHidden = true
    }
    
    func disableMediaView(_ view :UIImageView) {
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 0.0
            view.center.x = self.editVideoButton.center.x
        })
    }
    
    func enableMediaView(_ view :UIImageView, type: String) {
        view.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 1
            switch type {
                case "memo":
                    view.center.x = self.memoButtonCenterX
                case "image":
                    view.center.x = self.imageButtonCenterX
                case "video":
                    view.center.x = self.editVideoButton.center.x
                default:
                    break
            }
        })
    }
    
    @IBAction func gotoJourneys(_ sender: AnyObject) {
        self.tabBarController?.selectedIndex = 0
        let tabVC = self.tabBarController as! HikebeatTabBarVC
        tabVC.deselectCenterButton()
    }
    
    func mediaChosen(_ type: String) {
        switch type {
            case "video":
                moveViewToCenter(editVideoButton)
                applyGreenBorder(editVideoButton)
                disableMediaView(editMemoButton)
                disableMediaView(editImageButton)
                showClearButton()
            case "image":
                moveViewToCenter(editImageButton)
                applyGreenBorder(editImageButton)
                disableMediaView(editMemoButton)
                disableMediaView(editVideoButton)
                showClearButton()
            case "audio":
                moveViewToCenter(editMemoButton)
                applyGreenBorder(editMemoButton)
                disableMediaView(editVideoButton)
                disableMediaView(editImageButton)
                showClearButton()
        default: print("Type not matching: ", type)
        }
        
        editImageText.isHidden = true
        editVideoText.isHidden = true
        editMemoText.isHidden = true
        mediaAdded.isHidden = false
    }
    
    
/*
     Realm calls
*/
    
    func findActiveJourney() -> Bool {
        self.journeys = realm.objects(Journey.self)
        if (self.journeys?.isEmpty)! {
            hikebeatTopLogo.isHidden = false
            activeJourneyButton.isHidden = true
        } else {
            hikebeatTopLogo.isHidden = true
            activeJourneyButton.isHidden = false
        }
        print("journeys: ", self.journeys)
        let journeys = realm.objects(Journey.self).filter("active = \(true)")
        if journeys.isEmpty {
            self.activeJourney = nil
            self.activeJourneyButton.setTitle("Select journey", for: .normal)
            return false
        } else {
            self.activeJourney = journeys[0]
            self.activeJourneyButton.setTitle(self.activeJourney!.headline, for: .normal)
            return true
        }
        self.tableViewSelectJourney.reloadData()

    }
    
    
/*
     Sending beat functions
*/
    
    func checkForCorrectInput() {
        print("Now checking")
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            print("has gps permission")
            let locationTupleFuture = self.getTimeAndLocation()
            locationTupleFuture.onSuccess { (locationTuple) in
                if locationTuple != nil {
                    if ((self.messageText == nil && self.emotion == nil && self.currentImage == nil && self.currentMediaURL == nil && self.audioHasBeenRecordedForThisBeat == false) || self.activeJourney == nil || locationTuple!.latitude == "" || locationTuple!.longitude == "" || locationTuple!.altitude == "") {
                        // Give a warning that there is not text or no active journey.
                        print("Something is missing")
                        print("Text: ", self.messageText == nil && self.emotion == nil && self.currentImage == nil && self.currentMediaURL == nil)
                        print("Journey: ", self.activeJourney != nil)
                        print("Lat: ", locationTuple!.latitude)
                        print("Lng: ", locationTuple!.longitude)
                        
                    } else {
                        self.currentBeatDate = locationTuple?.date
                        var mediaData: String? = nil
                        var mediaType: String? = nil
                        if self.currentImage != nil {
                            //print(1)
                            let imageData = UIImageJPEGRepresentation(self.currentImage!, 0.4)
                            mediaType = MediaType.image
                            //print(2)
                            mediaData = self.saveMediaToDocs(imageData!, journeyId: (self.activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp, fileType: ".jpg")
                            self.completedCheck(locationTuple: locationTuple!, mediaData: mediaData, mediaType: mediaType)
                            
                        } else if self.currentMediaURL != nil {
                            mediaType = MediaType.video
                            let newPath = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
                            covertToMedia(self.currentMediaURL!, pathToOuputFile: newPath, fileType: AVFileTypeMPEG4)
                            .onSuccess(callback: { (success) in
                                let videoData = try? Data(contentsOf: newPath)
                                mediaData = self.saveMediaToDocs(videoData!, journeyId: (self.activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp, fileType: ".mp4")
                                if mediaData != nil {
                                    self.removeMediaWithURL(self.currentMediaURL!)
                                }
                                self.completedCheck(locationTuple: locationTuple!, mediaData: mediaData, mediaType: mediaType)
                            }).onFailure(callback: { (error) in
                                print("Error: ", error)
                                return
                            })
                        } else if self.audioHasBeenRecordedForThisBeat {
                            mediaType = MediaType.audio
                            let pathToAudio = self.getPathToFileFromName("/media/audio-temp.m4a")
                            let newPath = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4a")
                            print("Now converting")
                            covertToMedia(pathToAudio!, pathToOuputFile: newPath, fileType: AVFileTypeMPEG4)
                            .onSuccess(callback: { (success) in
                                let audioData = try? Data(contentsOf: newPath)
                                mediaData = self.saveMediaToDocs(audioData!, journeyId: (self.activeJourney?.journeyId)!, timestamp: locationTuple!.timestamp, fileType: ".m4a")
                                self.completedCheck(locationTuple: locationTuple!, mediaData: mediaData, mediaType: mediaType)
                            })
                        } else {
                            self.completedCheck(locationTuple: locationTuple!, mediaData: mediaData, mediaType: mediaType)
                        }
                    }

                } else {
                    print("location tuple is nil")
                }
            }
        } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            
            _ = alertView.addGreenButton("Go to settings") {
                UIApplication.openAppSettings()
            }
            _ = alertView.addCancelButton()
            _ = alertView.showNotice("Allow GPS?", subTitle: "\nYou have previously said no to allowing the app access to your location. Would you like to go to settings and change this?")

        } else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            
            _ = alertView.addGreenButton("Allow access") {
                _ = self.appDelegate.startLocationManager()
            }
            _ = alertView.addCancelButton()
            
            _ = alertView.showNotice("Allow GPS?", subTitle: "\nTo be able to show people your awesome journey and place you on a map we need your location. Will you allow the app access to your location?")
        }
    }
    
    func completedCheck(locationTuple: (date: Date, timestamp: String, latitude: String, longitude: String, altitude: String), mediaData: String?, mediaType: String?) {
        self.currentBeat = Beat()
        self.currentBeat!.fill( self.emotion, journeyId: self.activeJourney!.journeyId, message: self.messageText, latitude: locationTuple.latitude, longitude: locationTuple.longitude, altitude: locationTuple.altitude, timestamp: locationTuple.timestamp, mediaType: mediaType, mediaData: mediaData, mediaDataId: nil, mediaUrl: nil, messageId: nil, mediaUploaded: false, messageUploaded: false, journey: self.activeJourney!)
        self.currentBeat!.journey = self.activeJourney
        self.sendBeat()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("change in location status to: ", status)
        if (status == CLAuthorizationStatus.denied) {
            // The user denied authorization
            // Discuss with the guys what to do here
        } else if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            // The user accepted authorization
            self.checkForCorrectInput()
        }
    }
    
    func sendBeat() {
        print("sending beat start")
        // Check if there is any network connection and send via the appropriate means.
        if hasNetworkConnection(show: false) {
            // Sending text beat
            performSegue(withIdentifier: "showGreenModal", sender: nil)
            sendTextBeat(beat: self.currentBeat!)
            .onSuccess(callback: { (json) in
                
                let messageJson = json["data"]
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
                        print("Upload starting")
                        _ = self.currentModal!.addProgressBar("Uploading " + (self.currentBeat?.mediaType!)!)
                        uploadMediaForBeat(type: (self.currentBeat?.mediaType)!, path: filePath!, journeyId: (self.currentBeat?.journeyId)!, timeCapture: (self.currentBeat?.timestamp)!, progressCallback: (self.currentModal?.setProgress)!).onSuccess(callback: { (id) in
                            print("Upload succeeded with id: ", id)
                            try! self.realm.write {
                                self.currentBeat?.mediaDataId = id
                                self.currentBeat?.mediaUploaded = true
                                self.activeJourney?.beats.append(self.currentBeat!)
                            }
                            self.clearAllForNewBeat(beatSend: true)
                            self.beatPromise.success("compose")
                        }).onFailure(callback: { (error) in
                            print("Error uploading media: ", error)
                            // TODO: handle error by saving correctly
                            try! self.realm.write {
                                self.currentBeat?.mediaUploaded = false
                                self.activeJourney?.beats.append(self.currentBeat!)
                            }
                            self.clearAllForNewBeat(beatSend: true)
                            self.beatPromise.success("compose")
                        })
                    } else {
                        print("Could not resolve filepath")
                    }
                } else {
                    print("There's no image")
                    
                    try! self.realm.write {
                        self.currentBeat?.mediaUploaded = true
                        self.activeJourney?.beats.append(self.currentBeat!)
                    }
                    self.clearAllForNewBeat(beatSend: true)
                    self.beatPromise.success("compose")
                }
            }).onFailure(callback: { (error) in
                self.beatPromise.success("compose")
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                _ = alertView.addOkayButton()
                _ = alertView.showNotice("Sorry!", subTitle: "\nThere seems to be a problem sending your beat, please try again later.")
            })
            
        } else {
            // check for permitted phoneNumber
            //                }
            if userDefaults.bool(forKey: "sms") {
                sendTextMessage()
            } else {
//                    self.performSegue(withIdentifier: "showGreenModal", sender: self)
                try! self.realm.write {
                    if self.currentBeat?.mediaData != nil {
                        print("There's media")
                        self.currentBeat?.mediaUploaded = false
                    } else {
                        self.currentBeat?.mediaUploaded = true
                    }
                    if self.currentBeat?.message != nil {
                        print("There's text!")
                        self.currentBeat?.messageUploaded = false
                    } else {
                        self.currentBeat?.messageUploaded = true
                    }
                    self.activeJourney?.beats.append(self.currentBeat!)
                }
                self.clearAllForNewBeat(beatSend: true)
//                    self.beatPromise.success(true)
            }
        }
    }
    
    func sendTextMessage() {
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
        _ = alertView.addYellowButton("Go to profile") {
            print("Second button tapped")
            self.tabBarController?.selectedIndex = 3
            let tabVC = self.tabBarController as! HikebeatTabBarVC
            tabVC.deselectCenterButton()
        }
        _ = alertView.showWarning("Missing Phone number", subTitle: "You have to add a phone number in your profile to be able to send text messages. We need to know the text is comming from you")
    }
    
/*
     SMS functions
*/
    
    func genSMSMessageString(_ emotion: String, message: String, seqNumber: String) -> String {
        
//        print("timestamp deci: ", self.currentBeat?.timestamp)
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
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message Cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message Failed")
            
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
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
            self.clearAllForNewBeat(beatSend: true)
            self.dismiss(animated: true, completion: nil)
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
    func sendSMS(_ smsBody: String) {
        let usrDef = UserDefaults.standard
        print("NumberUserDef: ", usrDef.string(forKey: "hikebeat_phoneNumber")!)
        let phoneNumber = userDefaults.string(forKey: "hikebeat_phoneNumber")!
        print("phoneNumber: ", phoneNumber)
        print("In sms function")
        let messageVC = MFMessageComposeViewController()
        if MFMessageComposeViewController.canSendText() {
            messageVC.body = smsBody
            messageVC.recipients = [phoneNumber]
            messageVC.messageComposeDelegate = self;
            
            self.present(messageVC, animated: false, completion: nil)
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
    func getTimeAndLocation() -> Future<(date: Date, timestamp: String, latitude: String, longitude: String, altitude: String)?, NoError> {
        let date = Date()
        let t = String(date.timeIntervalSince1970)
        let e = t.range(of: ".")
        let timestamp = t.substring(to: (e?.lowerBound)!)
        let promise = Promise<(date: Date, timestamp: String, latitude: String, longitude: String, altitude: String)?, NoError>()
        
        var longitude = ""
        var latitude = ""
        var altitude = ""
        if let location = appDelegate.getLocation() {
            print("location 2. lat: ", location.coordinate.latitude, "lng: ", location.coordinate.longitude)
            let gpsCheck = userDefaults.bool(forKey: "GPS-check")
            if gpsCheck {
                // Now performing gps check
                if location.horizontalAccuracy > 200 {
                    // TODO: modal to tell the user that the gps signal is too poor.
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)

                    _ = alertView.addYellowButton("Yes") {
                        longitude = String(location.coordinate.longitude)
                        latitude = String(location.coordinate.latitude)
                        altitude = String(round(location.altitude))
                        print("location 3. lat: ", location.coordinate.latitude, "lng: ", location.coordinate.longitude)
                        promise.success((date, timestamp: timestamp, latitude: latitude, longitude: longitude, altitude: altitude))
                    }
                    _ = alertView.addGreyButton("No") {
                        promise.success(nil)
                    }
                    
                    _ = alertView.showWarning("Poor GPS precision", subTitle: "\nYour GPS precision is poor, would you like to send a beat anyway?")
                } else {
                    longitude = String(location.coordinate.longitude)
                    latitude = String(location.coordinate.latitude)
                    altitude = String(round(location.altitude))
                    print("location 3. lat: ", location.coordinate.latitude, "lng: ", location.coordinate.longitude)
                    promise.success((date, timestamp: timestamp, latitude: latitude, longitude: longitude, altitude: altitude))
                }
            } else {
                longitude = String(location.coordinate.longitude)
                latitude = String(location.coordinate.latitude)
                altitude = String(round(location.altitude))
                print("location 4. lat: ", location.coordinate.latitude, "lng: ", location.coordinate.longitude)
                promise.success((date, timestamp: timestamp, latitude: latitude, longitude: longitude, altitude: altitude))
            }
        } else {
            print("why here")
//            return nil
        }
        return promise.future
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "editEmotionsModal":
            if self.emotion != nil {
                print(1)
                let vc = segue.destination as! EditEmotionVC
                vc.emotion = self.emotion!
                print(1.1)
            }
        case "editMessageModal":
            if self.messageText != nil {
                let vc = segue.destination as! EditMessageVC
                vc.text = self.messageText!
            }
        case "showGreenModal":
            let vc = segue.destination as! ModalVC
            vc.future = self.beatPromise.future
            currentModal = vc
        case "smsWalk":
            return
        default:
            break
        }
    }
}

enum ComposeState {
    case noJourneys
    case noActiveJourney
    case noGPS
    case composeBeat
}


// DO NOT DELETE YET!

//
//
//// TODO: send via alamofire
//let url = IPAddress + "journeys/" + (activeJourney?.journeyId)! + "/messages"
//print("url: ", url)
//
//// "headline": localTitle, "text": localMessage,
//var parameters: [String: Any] = ["lat": currentBeat!.latitude, "lng": currentBeat!.longitude, "alt": currentBeat!.altitude, "timeCapture": currentBeat!.timestamp]
//if currentBeat!.emotion != nil {
//    parameters["emotion"] = emotionToNumber((currentBeat?.emotion)!)
//}
//if currentBeat!.message != nil {
//    parameters["text"] = currentBeat?.message
//}
//
//// Sending beat message
//performSegue(withIdentifier: "showGreenModal", sender: nil)
//getSessionManager().request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
//    print("The Response")
//    //                    print(response.response?.statusCode)
//    print(response)
//    
//    // if response is 200 OK from server go on.
//    if response.response?.statusCode == 200 {
//        print("The text was send")
//        
//        
//        // Save the messageId to the currentBeat
//        let rawMessageJson = JSON(response.result.value!)
//        let messageJson = rawMessageJson["data"][0]
//        //try! self.realm.write() {
//        self.currentBeat?.messageUploaded = true
//        self.currentBeat?.messageId = messageJson["_id"].stringValue
//        //}
//        
//        
//        // If the is an image in the currentBeat, send the image.
//        if self.currentBeat?.mediaData != nil {
//            print("There is an image or video")
//            // Send Image
//            
//            let filePath = self.getPathToFileFromName((self.currentBeat?.mediaData)!)
//            if filePath != nil {
//                print("Upload starting")
//                _ = self.currentModal!.addProgressBar("Uploading " + (self.currentBeat?.mediaType!)!)
//                uploadMediaForBeat(type: (self.currentBeat?.mediaType)!, path: filePath!, journeyId: (self.currentBeat?.journeyId)!, timeCapture: (self.currentBeat?.timestamp)!, progressCallback: (self.currentModal?.setProgress)!).onSuccess(callback: { (id) in
//                    print("Upload succeeded with id: ", id)
//                    try! self.realm.write {
//                        self.currentBeat?.mediaDataId = id
//                        self.currentBeat?.mediaUploaded = true
//                        self.activeJourney?.beats.append(self.currentBeat!)
//                    }
//                    self.clearAllForNewBeat(beatSend: true)
//                    self.beatPromise.success("compose")
//                }).onFailure(callback: { (error) in
//                    print("Error uploading media: ", error)
//                    // TODO: handle error by saving correctly
//                    try! self.realm.write {
//                        self.currentBeat?.mediaUploaded = false
//                        self.activeJourney?.beats.append(self.currentBeat!)
//                    }
//                    self.clearAllForNewBeat(beatSend: true)
//                    self.beatPromise.success("compose")
//                })
//            } else {
//                print("Could not resolve filepath")
//            }
//        } else {
//            print("There's no image")
//            
//            try! self.realm.write {
//                self.currentBeat?.mediaUploaded = true
//                self.activeJourney?.beats.append(self.currentBeat!)
//            }
//            self.clearAllForNewBeat(beatSend: true)
//            self.beatPromise.success("compose")
//        }
//        
//    } else {
//        // Response is not 200
//        print("Error posting the message")
//        let appearance = SCLAlertView.SCLAppearance(
//            showCloseButton: false
//        )
//        let alertView = SCLAlertView(appearance: appearance)
//        
//        _ = alertView.addGreenButton("Yes") {
//            self.sendTextMessage()
//        }
//        _ = alertView.addGreyButton("No thanks") {
//            try! self.realm.write {
//                if self.currentBeat?.mediaData != nil {
//                    self.currentBeat?.mediaUploaded = false
//                } else {
//                    self.currentBeat?.mediaUploaded = true
//                }
//                if self.currentBeat?.message != nil {
//                    self.currentBeat?.messageUploaded = false
//                } else {
//                    self.currentBeat?.messageUploaded = true
//                }
//                self.activeJourney?.beats.append(self.currentBeat!)
//            }
//        }
//        
//        _ = alertView.showNotice("Problem sending", subTitle: "\nSome error has occured when contacting the server, would you like to send a text message instead?")
//        //                        SCLAlertView().showError("Problem sending", subTitle: "Some error has occured when contacting the server, would you like to send a text message instead?")
//        
//        // Is set to true now but should be changed to false
//        // TODO: This should be uncommented when
//        
//    }
//    
//}


