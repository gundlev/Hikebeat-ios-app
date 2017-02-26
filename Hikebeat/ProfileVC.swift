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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}



class ProfileVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let userDefaults = UserDefaults.standard
    let realm = try! Realm()
    var currentlyEdditing = false
    let yellowColor = UIColor(colorLiteralRed: 255/255, green: 238/255, blue: 0, alpha: 1)
    let greenColor = UIColor(colorLiteralRed: 188/255, green: 246/255, blue: 0, alpha: 1)
    var imagePicker = UIImagePickerController()
    var newImage: Bool = false
    var store = CNContactStore()
    
    open let Countries = [
        "Denmark",
        "Norway",
        "Finland"
    ]
    

    @IBOutlet weak var followsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
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
    @IBOutlet weak var numberOfBeats: UITextField!
    
    @IBOutlet weak var infoContainer: UIView!
    
    @IBOutlet weak var blurryBG: UIImageView!
    
    @IBAction func phoneNumberInfoPressed(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        _ = alertView.addOkayButton()
        _ = alertView.showNotice("Phone Number", subTitle: "Add your phone number to prevent other phones from sending SMS to Hikebeat pretending to be you. This is an extra security feature.")
    }
    
    @IBAction func editProfileImageTapped(_ sender: AnyObject) {
        chooseImage()
    }
    
    @IBAction func seeFollowingJourneys(_ sender: AnyObject) {
        performSegue(withIdentifier: "showFollowing", sender: self)
    }
    
    @IBAction func editButtonTapped(_ sender: AnyObject) {
        currentlyEdditing = !currentlyEdditing
        nameLabel.isEnabled = currentlyEdditing
        phoneNoLabel.isEnabled = currentlyEdditing
        nationalityLabel.isEnabled = currentlyEdditing
        if currentlyEdditing {
            editButton.setImage(UIImage(named: "ActivatedIcon"), for: UIControlState())
            //followersButton.titleLabel!.text = "Edit Profile"
            followersButton.isHighlighted = true
            followersButton.backgroundColor = yellowColor
            editProfileImageButton.isEnabled = true
            editProfileImageButton.isHidden = false
            followersButton.isUserInteractionEnabled = false
            nameLabel.textColor = UIColor(hexString: "F8E71C")
            phoneNoLabel.textColor = UIColor(hexString: "F8E71C")
            
        } else {
            editButton.setImage(UIImage(named: "EditTitle"), for: UIControlState())
            //followersButton.titleLabel!.text = "0 followers | 0 following "
            followersButton.isHighlighted = false
            followersButton.backgroundColor = greenColor
            editProfileImageButton.isEnabled = false
            editProfileImageButton.isHidden = true
            followersButton.isUserInteractionEnabled = true
            nameLabel.textColor = UIColor.white
            phoneNoLabel.textColor = UIColor.white
            
            checkForChanges()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting notification
        NotificationCenter.default.addObserver(self, selector: #selector(EditMessageVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(EditMessageVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        followersButton.isUserInteractionEnabled = false
        editProfileImageButton.isEnabled = false
        editProfileImageButton.isHidden = true
        
        self.setProfileImage()
        
        let pickerView = UIPickerView()
        pickerView.backgroundColor = greenColor
        pickerView.tintColor = UIColor.white
        pickerView.delegate = self
        self.nationalityLabel.inputView = pickerView

//        followersButton.setTitle("0 followers | 0 following ", forState: UIControlState.Normal)
//        followersButton.setTitle("Edit Profile", forState: UIControlState.Selected)
        
        nameLabel.isEnabled = currentlyEdditing
        emailLabel.isEnabled = currentlyEdditing
        phoneNoLabel.isEnabled = currentlyEdditing
        numberOfJourneys.isEnabled = currentlyEdditing
        nationalityLabel.isEnabled = currentlyEdditing
        
        phoneNoLabel.tag = 1
        
        // Scaling the view for the screensize.
        if (UIDevice.isIphone5){
//            searchFieldLabelView.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, -40.0  )
//            searchField.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, 0.0  )
//            searchButton.transform = CGAffineTransformTranslate( searchFieldLabelView.transform, 0.0, 0.0  )
            infoContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8);
            infoContainer.transform = infoContainer.transform.translatedBy(x: 0.0, y: -35.0  )
            
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            self.followersButton.transform = followersButton.transform.translatedBy(x: 0.0, y: 10.0  )
        }else if(UIDevice.isIphone4 || UIDevice.isIpad){
            profileContentView.transform = CGAffineTransform.identity.scaledBy(x: 0.75, y: 0.75);
            profileContentView.transform = profileContentView.transform.translatedBy(x: 0.0, y: -100.0  )
            
  
            profilePicture.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6);
            profilePicture.transform = profilePicture.transform.translatedBy(x: 0, y: 50.0  )

            editProfileImageButton.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6);
            editProfileImageButton.transform = editProfileImageButton.transform.translatedBy(x: 0, y: 50.0  )
            
            blurryBG.transform = CGAffineTransform.identity.scaledBy(x: 1.2, y: 0.8);
            blurryBG.transform = blurryBG.transform.translatedBy(x: 0, y: 25  )
        }
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        
        followersButton.layer.cornerRadius = followersButton.bounds.height/2
        followersButton.layer.masksToBounds = true
        
        profilePicture.layer.cornerRadius = profilePicture.bounds.height/2
        profilePicture.layer.masksToBounds = true
        
        // Setting labels to values
        self.usernameLabel.text = "@" + userDefaults.string(forKey: "username")!
        self.nameLabel.text = userDefaults.string(forKey: "name")!
        self.emailLabel.text = userDefaults.string(forKey: "email")!
        self.nationalityLabel.text = userDefaults.string(forKey: "nationality")!
        if let phoneNumber = userDefaults.string(forKey: "permittedPhoneNumbers") {
            self.phoneNoLabel.text = phoneNumber
        } else {
            self.phoneNoLabel.placeholder = "Phone no."
        }
        
        // Settings number of journeys
        setNumberOfBeatsAndJourneys()
        
        self.followsCountLabel.text = userDefaults.string(forKey: "followsCount")
        self.followersCountLabel.text = userDefaults.string(forKey: "followerCount")
        
        
        // Setting profileImage if there is one
        setProfileImage()
    }
    
    func setNumberOfBeatsAndJourneys() {
        let journeys = realm.objects(Journey.self)
        if journeys.count == 1 {
            self.numberOfJourneys.text = String(journeys.count) + " journey"
        } else {
            self.numberOfJourneys.text = String(journeys.count) + " journeys"
        }
        
        let beats = realm.objects(Beat.self)
        print("beats: ", beats)
        if beats.count == 1 {
            self.numberOfBeats.text = String(beats.count) + " beat sent"
        } else {
            self.numberOfBeats.text = String(beats.count) + " beats sent"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNumberOfBeatsAndJourneys()
        getStats().onSuccess { (dict) in
            self.followsCountLabel.text = dict["followsCount"]
            self.userDefaults.set(dict["followsCount"], forKey: "followsCount")
            self.followersCountLabel.text = dict["followerCount"]
            self.userDefaults.set(dict["followerCount"],forKey: "followerCount")
        }.onFailure { (error) in
            print(error)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Countries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.nationalityLabel.text = Countries[row]
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let rightImage = image.correctlyOrientedImage()
        let imageData = UIImageJPEGRepresentation(rightImage, 0.5)

        if picker.sourceType == .camera {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
        
        _ = saveProfileImageToDocs(imageData!)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveProfileImageToDocs(_ mediaData: Data) -> Bool {
        let dataPath = getProfileImagePath()
        let success = (try? mediaData.write(to: URL(fileURLWithPath: dataPath), options: [])) != nil
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
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let fileName = "/media/profile_image.jpg"
//        let dataPath = documentsDirectory.appendingPathComponent(fileName)
        let dataPath = documentsDirectory.appending(fileName)
        return dataPath
    }
    
    func chooseImage() {
        let optionsMenu = UIAlertController(title: "Choose resource", message: nil, preferredStyle: .actionSheet)
        let cameraRoll = UIAlertAction(title: "Photo library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Photo Library")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
                print("Library is available")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .photoLibrary;
                self.imagePicker.allowsEditing = true
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        let takePhoto = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                print("Button capture")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.photo
                self.imagePicker.allowsEditing = true
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
        })
        
        optionsMenu.addAction(cameraRoll)
        optionsMenu.addAction(takePhoto)
        optionsMenu.addAction(cancel)
        
        self.present(optionsMenu, animated: true, completion: nil)
    }
    
    
/*

     Commit changes
     
*/
    
    func checkForChanges() {
        var changesArr = [(property: String,value: String)]()
        
        if self.nameLabel.text != userDefaults.string(forKey: "name")! {
            changesArr.append((UserProperty.name, self.nameLabel.text!))
            userDefaults.set(self.nameLabel.text, forKey: "name")
        }
        //SimpleReachability.isConnectedToNetwork()
        if self.phoneNoLabel.text != userDefaults.string(forKey: "permittedPhoneNumbers")! {
            let reachability = Reachability()
            if reachability?.currentReachabilityStatus != Reachability.NetworkStatus.notReachable {
                if self.phoneNoLabel.text?.characters.count >= 2 {
                    if wrongCountryCode(self.phoneNoLabel.text!) {
                        SCLAlertView().showWarning("Missing country code!", subTitle: "Your phone number was not changed as you didn't add a country code.")
                        self.phoneNoLabel.text = self.userDefaults.string(forKey: "permittedPhoneNumbers")
                    } else {
                        changesArr.append((UserProperty.permittedPhoneNumbers, self.phoneNoLabel.text!))
                    }
                }
                
            } else {
                SCLAlertView().showWarning("Missing connection!", subTitle: "You need to have network connection to change or set your phone number")
                self.phoneNoLabel.text = self.userDefaults.string(forKey: "permittedPhoneNumbers")
            }
        }
        if self.nationalityLabel.text != userDefaults.string(forKey: "nationality")! {
            changesArr.append((UserProperty.nationality, self.nationalityLabel.text!))
            userDefaults.set(self.nationalityLabel.text, forKey: "nationality")
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
        uploadProfileImage(path: URL(fileURLWithPath: getProfileImagePath())) { (progress) in
            print("Upload progress: ", progress)
        }.onSuccess { (success) in
            self.newImage = false
        }.onFailure { (error) in
            print(error)
            let localRealm = try! Realm()
            try! localRealm.write() {
                let change = Change()
                change.fill(InstanceType.profileImage, timeCommitted: self.getTimeCommitted(), stringValue: "profile_image.jpg", boolValue: false, property: nil, instanceId: nil, changeAction: ChangeAction.update, timestamp: nil)
                localRealm.add(change)
            }
        }
    }
    
    func sendTextChanges(_ arr: [(property: String,value: String)]) {
        
        for tuple in arr {
            var parameters = [String:Any]()
            if tuple.property == UserProperty.permittedPhoneNumbers {
                parameters[tuple.property] = [tuple.value]
            } else {
                parameters[tuple.property] = tuple.value
            }

            let url = IPAddress + "users"
            print(url)
            print(parameters)
            Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: getHeader()).responseJSON { response in
                
                if response.response?.statusCode == 200 {
                    print("It has been changed in the db")
                    if tuple.property == UserProperty.permittedPhoneNumbers {
                        self.userDefaults.set(self.phoneNoLabel.text!, forKey: "permittedPhoneNumbers")
                        
                        switch CNContactStore.authorizationStatus(for: .contacts){
                        case .authorized:
                            print("should check for hikebeat contact")
                            self.checkIfHikbeatContactExist()
                            //TODO: check if hikebeat contact is created.
                        case .notDetermined:
                            let appearance = SCLAlertView.SCLAppearance(
                                showCloseButton: false
                            )
                            let alertView = SCLAlertView(appearance: appearance)
                            alertView.addButton("Yes") {
                                print("Yes")
                                self.store.requestAccess(for: .contacts){succeeded, err in
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
                        self.phoneNoLabel.text = self.userDefaults.string(forKey: "permittedPhoneNumbers")
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
        let predicate = CNContact.predicateForContacts(matchingName: "Hikebeat")
        let keys = [CNContactGivenNameKey]
        var contacts = [CNContact]()
        do {
            contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
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
        let phoneNumber = userDefaults.string(forKey: "hikebeat_phoneNumber")!
        contactData.imageData = UIImagePNGRepresentation(img!)
        contactData.phoneNumbers = [CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: phoneNumber))]
        contactData.emailAddresses = [CNLabeledValue(label: CNLabelWork,value: "contact@hikebeat.com")]
        let facebookProfile = CNLabeledValue(label: "FaceBook", value:
            CNSocialProfile(urlString: nil, username: "Hikebeat",
                userIdentifier: nil, service: CNSocialProfileServiceFacebook))
        contactData.socialProfiles = [facebookProfile]
        
        let request = CNSaveRequest()
        request.add(contactData, toContainerWithIdentifier: nil)
        do{
            try store.execute(request)
            print("Successfully added the contact")
        } catch let err{
            print("Failed to save the contact. \(err)")
        }
    }
    
    func getTimeCommitted() -> String {
        let t = String(Date().timeIntervalSince1970)
        let e = t.range(of: ".")
        let timestamp = t.substring(to: (e?.lowerBound)!)
        return timestamp
    }
    
    func wrongCountryCode(_ number: String) -> Bool {
        let plus = number.substring(with: (number.startIndex ..< number.characters.index(number.startIndex, offsetBy: 1)))
        let zerozero = number.substring(with: (number.startIndex ..< number.characters.index(number.startIndex, offsetBy: 2)))
        if plus == "+" || zerozero == "00" {
            return false
        } else {
            return true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 && textField.text?.characters.count >= 2 {
            if wrongCountryCode(textField.text!) {
                SCLAlertView().showWarning("Missing country code!", subTitle: "Please remember to add country code to your phone number.")
            }
        }
    }
    
    @IBAction func unwindToProfile(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    func keyboardWillShow(_ sender: Foundation.Notification) {
        self.view.frame.origin.y = -130
    }
    
    func keyboardWillHide(_ sender: Foundation.Notification) {
        self.view.frame.origin.y = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFollowing" {
            let vc = segue.destination as! UniversalListOfJourneysVC
            vc.fromVC = "profile"
        }
    }
}
