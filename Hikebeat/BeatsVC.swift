//
//  BeatsVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/30/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class BeatsVC: UIViewController {

    @IBOutlet weak var beatsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
        
    var jStatuses = ["Active journey","Finished journey","Finished journey","Finished journey","Finished journey","Finished journey","Finished journey"]
    var jTitles = ["A Weekend in London","Adventures in Milano","Hike Madness in Sweden","Meeting in Prague","Wonderful Copenhagen","To Paris and Back","Camino De Santiago"]
    var jDates = ["22/4/16","17/3/16","26/2/16","12/2/16","11/1/16","10/10/15","3/7/15"]

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var insets = self.beatsCollectionView.contentInset
        let value = (self.view.frame.size.width - (self.beatsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) * 0.5
        insets.left = value
        insets.right = value
        self.beatsCollectionView.contentInset = insets
        self.beatsCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.pageControl.numberOfPages = beatsCollectionView.numberOfItemsInSection(0)
        self.pageControl.transform = CGAffineTransformMakeScale(1.7, 1.7)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Close the modal before you leave
        self.dismissViewControllerAnimated(false, completion: nil)
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

extension BeatsVC : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BeatCell", forIndexPath: indexPath) as! BeatCollectionViewCell
        
       
        cell.beatContainer.layer.cornerRadius = 30
        cell.beatContainer.layer.masksToBounds = true
        
        cell.beatImage.layer.cornerRadius = 25
        cell.beatImage.layer.masksToBounds = true

        // create path
        
        let width = min(cell.profilePicture.bounds.width, cell.profilePicture.bounds.height)
        let path = UIBezierPath(arcCenter: CGPointMake(cell.profilePicture.bounds.midX, cell.profilePicture.bounds.midY), radius: width / 2, startAngle: CGFloat(0.0), endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        
        // update mask and save for future reference
        
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        cell.profilePicture.layer.mask = mask
        
        // create border layer
        
        let frameLayer = CAShapeLayer()
        frameLayer.path = path.CGPath
        frameLayer.lineWidth = 4
        frameLayer.strokeColor = UIColor.whiteColor().CGColor
        frameLayer.fillColor = nil
        
        // if we had previous border remove it, add new one, and save reference to new one
        cell.profilePicture.layer.addSublayer(frameLayer)
        
        
        
        cell.journeyTitle.text = "A Weekend in London"
        cell.beatTitle.text = "A Sunset From London Eye"
        cell.beatMessage.text = "We were extremely lucky to experience this wonderful sunset from the London Eye. The most beautiful afternoon ever!!! 😍"
        
        //TODO ScrollView not working
        
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.bounds.height/2
        cell.profilePicture.layer.masksToBounds = true
        
        cell.scrollView.scrollEnabled = true
        cell.scrollView.contentSize = CGSizeMake(230, 2300)
        
        return cell
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        // 292 is the width of the cell in the collection
        let currentPage = beatsCollectionView.contentOffset.x / 292
        self.pageControl.currentPage = Int(ceil(currentPage))

    }
}
