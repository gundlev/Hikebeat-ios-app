//
//  ProfileVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/28/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import SwiftyJSON
import ContactsUI


class ProfileVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let realm = try! Realm()
    var currentlyEdditing = false
    let yellowColor = UIColor(colorLiteralRed: 255/255, green: 238/255, blue: 0, alpha: 1)
    let greenColor = UIColor(colorLiteralRed: 188/255, green: 246/255, blue: 0, alpha: 1)
    var imagePicker = UIImagePickerController()
    var newImage: Bool = false
    var store = CNContactStore()
    
    public let Countries = [
        "Denmark",
        "Norway",
        "Finland"
    ]
    

    @IBOutlet weak var editProfileImageButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var emailLabel: UILabel!
//    @IBOutlet weak var phoneNoLabel: UILabel!
//    @IBOutlet weak var numberOfJourneys: UILabel!
//    @IBOutlet weak var nationalityLabel: UILabel!
//    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var phoneNoLabel: UITextField!
    @IBOutlet weak var numberOfJourneys: UITextField!
    @IBOutlet weak var nationalityLabel: UITextField!
    @IBOutlet weak var profileContentView: UIView!
    
    @IBOutlet weak var infoContainer: UIView!
    
    
    
    @IBOutlet weak var blurryBG: UIImageView!
    
    @IBAction func editProfileImageTapped(sender: AnyObject) {
        chooseImage()
    }
    
    @IBAction func seeFollowingJourneys(sender: AnyObject) {
        performSegueWithIdentifier("showFollowing", sender: self)
    }
    
    @IBAction func editButtonTapped(sender: AnyObject) {
        currentlyEdditing = !currentlyEdditing
        nameLabel.enabled = currentlyEdditing
        phoneNoLabel.enabled = currentlyEdditing
        nationalityLabel.enabled = currentlyEdditing
        if currentlyEdditing {
            editButton.setImage(UIImage(named: "ActivatedIcon"), forState: UIControlState.Normal)
            //followersButton.titleLabel!.text = "Edit Profile"
            followersButton.highlighted = true
            followersButton.backgroundColor = yellowColor
            editProfileImageButton.enabled = true
            editProfileImageButton.hidden = false
            followersButton.userInteractionEnabled = false
            nameLabel.textColor = UIColor(hexString: "F8E71C")
            phoneNoLabel.textColor = UIColor(hexString: "F8E71C")
            
        } else {
            editButton.setImage(UIImage(named: "EditTitle"), forState: UIControlState.Normal)
            //followersButton.titleLabel!.text = "0 followers | 0 following "
            followersButton.highlighted = false
            followersButton.backgroundColor = greenColor
            editProfileImageButton.enabled = false
            editProfileImageButton.hidden = true
            followersButton.userInteractionEnabled = true
            nameLabel.textColor = UIColor.whiteColor()
            phoneNoLabel.textColor = UIColor.whiteColor()
            
            checkForChanges()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditMessageVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditMessageVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        followersButton.userInteractionEnabled = false
        editProfileImageButton.enabled = false
        editProfileImageButton.hidden = true
        
        self.setProfileImage()
        
        let pickerView = UIPickerView()
        pickerView.backgroundColor = greenColor
        pickerView.tintColor = UIColor.whiteColor()
        pickerView.delegate = self
        self.nationalityLabel.inputView = pickerView

//        followersButton.setTitle("0 followers | 0 following ", forState: UIControlState.Normal)
//        followersButton.setTitle("Edit Profile", forState: UIControlState.Selected)
        
        nameLabel.enabled = currentlyEdditing
        emailLabel.enabled = currentlyEdditing
        phoneNoLabel.enabled = currentlyEdditing
        numberOfJourneys.enabled = currentlyEdditing
        nationalityLabel.enabled = currentlyEdditing
        
        phoneNoLabel.tag = 1
        
        // Scaling the view for the screensize.
        if (UIDevice.isIphone5){
//            searchFieldLabelView.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, -40.0  )
//            searchField.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, 0.0  )
//            searchButton.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, 0.0  )
            infoContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
            infoContainer.transform = CGAffineTransformTranslate( infoContainer.transform, 0.0, -35.0  )
            
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            self.followersButton.transform = CGAffineTransformTranslate( followersButton.transform, 0.0, 10.0  )
        }else if(UIDevice.isIphone4 || UIDevice.isIpad){
            profileContentView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.75, 0.75);
            profileContentView.transform = CGAffineTransformTranslate( profileContentView.transform, 0.0, -100.0  )
            
  
            profilePicture.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
            profilePicture.transform = CGAffineTransformTranslate( profilePicture.transform, 0, 50.0  )

            editProfileImageButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
            editProfileImageButton.transform = CGAffineTransformTranslate( editProfileImageButton.transform, 0, 50.0  )
            
            blurryBG.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 0.8);
            blurryBG.transform = CGAffineTransformTranslate( blurryBG.transform, 0, 25  )
        }
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        
        followersButton.layer.cornerRadius = followersButton.bounds.height/2
        followersButton.layer.masksToBounds = true
        
        profilePicture.layer.cornerRadius = profilePicture.bounds.height/2
        profilePicture.layer.masksToBounds = true
        
        // Setting labels to values
        self.usernameLabel.text = "@" + userDefaults.stringForKey("username")!
        self.nameLabel.text = userDefaults.stringForKey("name")!
        self.emailLabel.text = userDefaults.stringForKey("email")!
        self.nationalityLabel.text = userDefaults.stringForKey("nationality")!
        if let phoneNumber = userDefaults.stringForKey("permittedPhoneNumbers") {
            self.phoneNoLabel.text = phoneNumber
        } else {
            self.phoneNoLabel.placeholder = "Phone no."
        }
        
        // Settings number of journeys
        let journeys = realm.objects(Journey)
        if journeys.count == 1 {
            self.numberOfJourneys.text = String(journeys.count) + " journey created"
        } else {
            self.numberOfJourneys.text = String(journeys.count) + " journeys created"
        }
        
        
        // Setting profileImage if there is one
        setProfileImage()
//        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//        let documentsDirectory: AnyObject = paths[0]
//        let fileName = "profilemage.png"
//        let imagePath = documentsDirectory.stringByAppendingPathComponent(fileName)
//        let image = UIImage(contentsOfFile: imagePath)
//        if image != nil {
//            profilePicture.image = image
//        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Countries.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Countries[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.nationalityLabel.text = Countries[row]
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let rightImage = image.correctlyOrientedImage()
        let imageData = UIImageJPEGRepresentation(rightImage, 0.5)

        if picker.sourceType == .Camera {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
        
        saveProfileImageToDocs(imageData!)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveProfileImageToDocs(mediaData: NSData) -> Bool {
        let dataPath = getProfileImagePath()
        let success = mediaData.writeToFile(dataPath, atomically: false)
        if success {
            print("Saved profile_image to Docs")
            setProfileImage()
            self.newImage = true
            return true
        } else {
            return false
        }
    }
    
    func setProfileImage() {
        let dataPath = getProfileImagePath()
        let image = UIImage(contentsOfFile: dataPath)
        if image != nil {
            self.profilePicture.image = image
            print("setting profile image")
        } else {
            self.profilePicture.image = UIImage(named: "DefaultProfile")
        }
    }
    
    func getProfileImagePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let fileName = "media/profile_image.jpg"
        let dataPath = documentsDirectory.stringByAppendingPathComponent(fileName)
        return dataPath
    }
    
    func chooseImage() {
        let optionsMenu = UIAlertController(title: "Choose resource", message: nil, preferredStyle: .ActionSheet)
        let cameraRoll = UIAlertAction(title: "Photo library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Photo Library")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                print("Library is available")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .PhotoLibrary;
                self.imagePicker.allowsEditing = true
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        let takePhoto = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                print("Button capture")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .Camera
                self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
                self.imagePicker.allowsEditing = true
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
        })
        
        optionsMenu.addAction(cameraRoll)
        optionsMenu.addAction(takePhoto)
        optionsMenu.addAction(cancel)
        
        self.presentViewController(optionsMenu, animated: true, completion: nil)
    }
    
    
/*

     Commit changes
     
*/
    
    func checkForChanges() {
        var changesArr = [(property: String,value: String)]()
        
        if self.nameLabel.text != userDefaults.stringForKey("name")! {
            changesArr.append((UserProperty.name, self.nameLabel.text!))
            userDefaults.setObject(self.nameLabel.text, forKey: "name")
        }
        if self.phoneNoLabel.text != userDefaults.stringForKey("permittedPhoneNumbers")! {
            if SimpleReachability.isConnectedToNetwork() {
                if self.phoneNoLabel.text?.characters.count >= 2 {
                    if wrongCountryCode(self.phoneNoLabel.text!) {
                        SCLAlertView().showWarning("Missing country code!", subTitle: "Your phone number was not changed as you didn't add a country code.")
                        self.phoneNoLabel.text = self.userDefaults.stringForKey("permittedPhoneNumbers")
                    } else {
                        changesArr.append((UserProperty.permittedPhoneNumbers, self.phoneNoLabel.text!))
                    }
                }
                
            } else {
                SCLAlertView().showWarning("Missing connection!", subTitle: "You need to have network connection to change or set your phone number")
                self.phoneNoLabel.text = self.userDefaults.stringForKey("permittedPhoneNumbers")
            }
        }
        if self.nationalityLabel.text != userDefaults.stringForKey("nationality")! {
            changesArr.append((UserProperty.nationality, self.nationalityLabel.text!))
            userDefaults.setObject(self.nationalityLabel.text, forKey: "nationality")
        }
        
        if !changesArr.isEmpty {
            print("There are changes")
            print(changesArr)
            sendTextChanges(changesArr)
        }
        
        if self.newImage {
            print("New image to send")
            sendProfileImage()
        }
    }
    
    func sendProfileImage() {
        var customHeader = Headers
        
        customHeader["x-hikebeat-format"] = "jpg"
        
        let url = IPAddress + "users/" + userDefaults.stringForKey("_id")! + "/profilePhoto"
        print("imageURL: ", url)
        print("path: ", self.getProfileImagePath())
        Alamofire.upload(.POST, url,headers: customHeader, file: NSURL(fileURLWithPath: getProfileImagePath())).responseJSON { mediaResponse in
            if mediaResponse.response?.statusCode == 200 {
                let rawImageJson = JSON(mediaResponse.result.value!)
                let mediaJson = rawImageJson["data"][0]
                print(mediaResponse)
                self.newImage = false
                print("The image has been posted")
            } else {
                print("Error posting the image, saving in changes")
                print(mediaResponse)
                let localRealm = try! Realm()
                try! localRealm.write() {
                    let change = Change()
                    change.fill(InstanceType.profileImage, timeCommitted: self.getTimeCommitted(), stringValue: "profile_image.jpg", boolValue: false, property: nil, instanceId: nil, changeAction: ChangeAction.update, timestamp: nil)
                    localRealm.add(change)
                }
            }

        }

    }
    
    func sendTextChanges(arr: [(property: String,value: String)]) {
        
        for tuple in arr {
            var parameters = [String:AnyObject]()
            if tuple.property == UserProperty.permittedPhoneNumbers {
                parameters["options"] = [tuple.property : [tuple.value]]
            } else {
                parameters["options"] = [tuple.property : tuple.value]
            }

            let url = IPAddress + "users/" + userDefaults.stringForKey("_id")!
            print(url)
            print(parameters)
            Alamofire.request(.PUT, url, parameters: parameters, encoding: .JSON, headers: Headers).responseJSON { response in
                
                if response.response?.statusCode == 200 {
                    print("It has been changed in the db")
                    if tuple.property == UserProperty.permittedPhoneNumbers {
                        self.userDefaults.setObject(self.phoneNoLabel.text!, forKey: "permittedPhoneNumbers")
                        
                        switch CNContactStore.authorizationStatusForEntityType(.Contacts){
                        case .Authorized:
                            print("should check for hikebeat contact")
                            self.checkIfHikbeatContactExist()
                            //TODO: check if hikebeat contact is created.
                        case .NotDetermined:
                            let appearance = SCLAlertView.SCLAppearance(
                                showCloseButton: false
                            )
                            let alertView = SCLAlertView(appearance: appearance)
                            alertView.addButton("Yes") {
                                print("Yes")
                                self.store.requestAccessForEntityType(.Contacts){succeeded, err in
                                    guard err == nil && succeeded else{
                                        return
                                    }
                                    self.addHikebeatContact()
                                }
                            }
                            alertView.addButton("No") {
                                print("No")
                            }
                            alertView.showWarning("Add hikebeat contact?", subTitle: "In order to create a Hikebeat contact on you phone and make it easier for you to know what you have send to Hikebeat, we need permission to access your contacts, would you like to grant permission?")
                        default:
                            print("Haven't got permission to access contacts")
                        }
                    }
                } else {
                    if tuple.property == UserProperty.permittedPhoneNumbers {
                        self.phoneNoLabel.text = self.userDefaults.stringForKey("permittedPhoneNumbers")
                    }
                    print("No connection or fail, saving change")
                    print(response)
                    let localRealm = try! Realm()
                    try! localRealm.write() {
                        let change = Change()
                        change.fill(InstanceType.user, timeCommitted: self.getTimeCommitted(), stringValue: tuple.value, boolValue: false, property: tuple.property, instanceId: nil, changeAction: ChangeAction.update, timestamp: nil)
                        localRealm.add(change)
                    }
                }
            }
        }
    }
    
    func checkIfHikbeatContactExist() {
        let predicate = CNContact.predicateForContactsMatchingName("Hikebeat")
        let keys = [CNContactGivenNameKey]
        var contacts = [CNContact]()
        do {
            contacts = try store.unifiedContactsMatchingPredicate(predicate, keysToFetch: keys)
            if contacts.count == 0 {
                print("contacts: ", contacts.count)

                addHikebeatContact()
            } else {
                print("contacts: ", contacts.count)
            }
        }
        catch {
            
        }
    }
    
    func addHikebeatContact() {
        let contactData = CNMutableContact()
        contactData.givenName = "Hikebeat"
        contactData.organizationName = "Hikebeat"
        let img = UIImage(named: "ContactImage")
        contactData.imageData = UIImagePNGRepresentation(img!)
        contactData.phoneNumbers = [CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: phoneNumber))]
        contactData.emailAddresses = [CNLabeledValue(label: CNLabelWork,value: "contact@hikebeat.com")]
        let facebookProfile = CNLabeledValue(label: "FaceBook", value:
            CNSocialProfile(urlString: nil, username: "Hikebeat",
                userIdentifier: nil, service: CNSocialProfileServiceFacebook))
        contactData.socialProfiles = [facebookProfile]
        
        let request = CNSaveRequest()
        request.addContact(contactData, toContainerWithIdentifier: nil)
        do{
            try store.executeSaveRequest(request)
            print("Successfully added the contact")
        } catch let err{
            print("Failed to save the contact. \(err)")
        }
    }
    
    func getTimeCommitted() -> String {
        let t = String(NSDate().timeIntervalSince1970)
        let e = t.rangeOfString(".")
        let timestamp = t.substringToIndex((e?.startIndex)!)
        return timestamp
    }
    
    func wrongCountryCode(number: String) -> Bool {
        let plus = number.substringWithRange(Range<String.Index>(start: number.startIndex, end: number.startIndex.advancedBy(1)))
        let zerozero = number.substringWithRange(Range<String.Index>(start: number.startIndex, end: number.startIndex.advancedBy(2)))
        if plus == "+" || zerozero == "00" {
            return false
        } else {
            return true
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 1 && textField.text?.characters.count >= 2 {
            if wrongCountryCode(textField.text!) {
                SCLAlertView().showWarning("Missing country code!", subTitle: "Please remember to add country code to your phone number.")
            }
        }
    }
    
    @IBAction func unwindToProfile(unwindSegue: UIStoryboardSegue) {
        
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -130
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFollowing" {
            let vc = segue.destinationViewController as! UniversalListOfJourneysVC
            vc.fromVC = "profile"
        }
    }
}
