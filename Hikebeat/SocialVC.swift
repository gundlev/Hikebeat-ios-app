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
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditTitleVC.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditTitleVC.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);

        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        popularJourneysButton.layer.cornerRadius = popularJourneysButton.bounds.height/2
        popularJourneysButton.layer.masksToBounds = true
        
        searchField.layer.cornerRadius = searchField.bounds.height/2
        searchField.layer.masksToBounds = true
        
        searchButton.layer.cornerRadius = searchButton.bounds.height/2
        searchButton.layer.masksToBounds = true

        
        let paddingView = UIView(frame: CGRectMake(0, 0, 15, self.searchField.frame.height))
        searchField.leftView = paddingView
        searchField.leftViewMode = UITextFieldViewMode.Always
        
        searchField.rightView = paddingView
        searchField.rightViewMode = UITextFieldViewMode.Always
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -130
    }
    
    func keyboardWillHide(sender: NSNotification) {
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
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jTitles.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ActiveJourneyCell", forIndexPath: indexPath) as! ActiveJourneyCollectionViewCell
        
        cell.journeyTitleLabel.text = jTitles[indexPath.row]
        let profileBadge = UIImage(named: "DimiInTheHouse")
        cell.badgeImage.image = profileBadge
        
        cell.badgeImage.layer.cornerRadius = cell.badgeImage.bounds.height/2
        cell.badgeImage.layer.masksToBounds = true

        cell.badgeImage.layer.borderWidth = 3
        cell.badgeImage.layer.borderColor = UIColor(hexString: "15676C")!.CGColor
        
        cell.backgroundColor = UIColor.clearColor()
        
        return cell
    }
}
