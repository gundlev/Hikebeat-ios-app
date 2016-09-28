//
//  SocialVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/28/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class SocialVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var popularJourneysButton: UIButton!
    @IBOutlet weak var popularJourneysCollectionView: UICollectionView!
    
    @IBOutlet weak var searchFieldLabelView: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    
    @IBOutlet weak var placeholder: UIView!
    
    var jStatuses = ["Active journey","Finished journey","Finished journey","Finished journey","Finished journey","Finished journey","Finished journey"]
    var jTitles = ["A Weekend in London","Adventures in Milano","Hike Madness in Sweden","Meeting in Prague","Wonderful Copenhagen","To Paris and Back","Camino De Santiago"]
    var jDates = ["22/4/16","17/3/16","26/2/16","12/2/16","11/1/16","10/10/15","3/7/15"]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var insets = self.popularJourneysCollectionView.contentInset
        let value = (self.view.frame.size.width - (self.popularJourneysCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.5
        insets.left = value
        insets.right = value
        self.popularJourneysCollectionView.contentInset = insets
        self.popularJourneysCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Scaling the view for the screensize.
        if (UIDevice.isIphone5){
            searchFieldLabelView.transform = searchFieldLabelView.transform.translatedBy(x: 0.0, y: -40.0  )
            searchField.transform = searchFieldLabelView.transform.translatedBy(x: 0.0, y: 0.0  )
            searchButton.transform = searchFieldLabelView.transform.translatedBy(x: 0.0, y: 0.0  )
             placeholder.transform = placeholder.transform.translatedBy(x: 0.0, y: -80.0  )
        }else if(UIDevice.isIphone6SPlus||UIDevice.isIphone6Plus){
            self.popularJourneysButton.transform = popularJourneysButton.transform.translatedBy(x: 0.0, y: 10.0  )
        } else if(UIDevice.isIphone4 || UIDevice.isIpad){
            searchFieldLabelView.isHidden = true
            searchField.transform = searchField.transform.translatedBy(x: 0.0, y: -107.0  )
            searchButton.transform = searchButton.transform.translatedBy(x: 0.0, y: -120.0  )
            
            placeholder.transform = placeholder.transform.translatedBy(x: 0.0, y: -120.0  )
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(SocialVC.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(SocialVC.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);

        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        popularJourneysButton.layer.cornerRadius = popularJourneysButton.bounds.height/2
        popularJourneysButton.layer.masksToBounds = true
        
        searchField.layer.cornerRadius = searchField.bounds.height/2
        searchField.layer.masksToBounds = true
        
        searchButton.layer.cornerRadius = searchButton.bounds.height/2
        searchButton.layer.masksToBounds = true

        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.searchField.frame.height))
        searchField.leftView = paddingView
        searchField.leftViewMode = UITextFieldViewMode.always
        
        searchField.rightView = paddingView
        searchField.rightViewMode = UITextFieldViewMode.always
        
        
         self.searchField.delegate = self;
        
        
        
    }
    
    @IBAction func unwindToSocial(_ unwindSegue: UIStoryboardSegue) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -130
    }
    
    func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SocialVC : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jTitles.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActiveJourneyCell", for: indexPath) as! ActiveJourneyCollectionViewCell
        
        cell.journeyTitleLabel.text = jTitles[(indexPath as NSIndexPath).row]
        let profileBadge = UIImage(named: "DimiInTheHouse")
        cell.badgeImage.image = profileBadge
        
        cell.badgeImage.layer.cornerRadius = cell.badgeImage.bounds.height/2
        cell.badgeImage.layer.masksToBounds = true

        cell.badgeImage.layer.borderWidth = 3
        cell.badgeImage.layer.borderColor = UIColor(hexString: "15676C")!.cgColor
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
}
