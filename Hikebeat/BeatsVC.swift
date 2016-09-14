//
//  BeatsVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/30/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import RealmSwift


class BeatsVC: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var beatsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var pageCtrlLabel: UILabel!
    @IBOutlet weak var altPageControl: UIView!
    
    var startingIndex: Int!
    var journey: Journey!
    var beats: Results<Beat>!
    var player:AVAudioPlayer!
    var playingCell: BeatCollectionViewCell?
    var chosenImage: UIImage?

    
    
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
        
        self.beats = self.journey.beats.sorted("timestamp")
        // Do any additional setup after loading the view.
        self.pageControl.numberOfPages = beatsCollectionView.numberOfItemsInSection(0)
        self.pageControl.transform = CGAffineTransformMakeScale(1.7, 1.7)
        
        beatsCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override func viewDidAppear(animated: Bool) {
        let indexpath = NSIndexPath(forItem: startingIndex, inSection: 0)
        self.beatsCollectionView.scrollToItemAtIndexPath(indexpath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        pageControl.currentPage = startingIndex
        pageCtrlLabel.text = String(pageControl.currentPage+1)+"/"+String(pageControl.numberOfPages)
        
        if pageControl.numberOfPages>10 {
            pageControl.hidden = true
            altPageControl.hidden = false
        }else{
            pageControl.hidden = false
            altPageControl.hidden = true
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        // Close the modal before you leave
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImage" {
            let vc = segue.destinationViewController as! ShowImageModalVC
            vc.image = self.chosenImage!
        }
    }
}

extension BeatsVC : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.beats.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BeatCell", forIndexPath: indexPath) as! BeatCollectionViewCell
        
        let beat = self.beats[indexPath.item]
        print("Beat Emotion: ", beat.emotion)
       
        if(UIDevice.isIphone4 || UIDevice.isIpad){
            cell.beatContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
            cell.beatContainer.transform = CGAffineTransformTranslate( cell.beatContainer.transform, 0.0, -20.0  )
        }else if(UIDevice.isIphone5){
            cell.beatContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.85, 0.85);
            cell.beatContainer.transform = CGAffineTransformTranslate( cell.beatContainer.transform, 0.0, -20.0  )
        }
        
        cell.beatContainer.layer.cornerRadius = 30
        cell.beatContainer.layer.masksToBounds = true
        
        cell.beatImage.layer.cornerRadius = 25
        cell.beatImage.layer.masksToBounds = true

        if beat.emotion != nil {
            if beat.emotion != "" {
                let emotionName = beat.emotion!.lowercaseString
                cell.profilePicture.image = UIImage(named: emotionName+"_selected")
            } else {
                cell.profilePicture.image = UIImage(named: "ContactImage")
            }
        } else {
            cell.profilePicture.image = UIImage(named: "ContactImage")
        }
//        let dataPath = getImagePath("profile_image.jpg")
//        let image = UIImage(contentsOfFile: dataPath)
//        if image != nil {
//            cell.profilePicture.image = image
//        } else {
//            cell.profilePicture.image = UIImage(named: "ContactImage")
//        }
        
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
        
        cell.scrollView.userInteractionEnabled = true
        cell.scrollView.scrollEnabled = false
        
        cell.journeyTitle.text = journey.headline
//        cell.beatTitle.text = beat.title
        cell.beatMessage.text = beat.message
        
        
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.bounds.height/2
        cell.profilePicture.layer.masksToBounds = true
        
        cell.scrollView.contentSize = CGSizeMake(230, 1000)
        
        // setting date
        let formatter = NSDateFormatter()
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(Int(beat.timestamp)!))
        formatter.dateFormat = "d MMMM YYYY H:mm"
        let timeString = formatter.stringFromDate(date)
        cell.beatTime.text = timeString
        
        
        // setting beat media
        if beat.mediaData != nil {
            print("Item :", indexPath.item)
//            print("Beat Headline: ", beat.title)
            print("Mediadata: ", beat.mediaData!)
            switch beat.mediaType! {
            case MediaType.image:
                print("image")
                cell.playButton.tag = indexPath.item
                cell.beatImage.image = UIImage(named: "picture-btn")
                cell.beatImage.hidden = false
                cell.playButton.hidden = false
                cell.mediaType.text = "Image"
            case MediaType.video:
                print("video")
                let image = videoSnapshot(getImagePath(beat.mediaData!))
                cell.beatImage.image = UIImage(named: "video-btn")
                cell.beatImage.hidden = false
                cell.playButton.hidden = false
//                cell.playButton.imageView?.image = UIImage(named: "play-btn")
                cell.playButton.tag = indexPath.item
                cell.mediaType.text = "Video"
            case MediaType.audio:
                print("audio")
                cell.beatImage.image = UIImage(named: "memo-btn-passive")
                cell.beatImage.hidden = false
                cell.playButton.hidden = false
//                cell.playButton.setImage(UIImage(), forState: UIControlState.Normal)
                //cell.playButton.imageView?.image = UIImage()
                cell.playButton.tag = indexPath.item
                cell.mediaType.text = "Memo"
            default:
                print("default")
                cell.mediaType.text = " "
                cell.beatImage.hidden = true
                cell.playButton.hidden = true
            }
        } else {
            print("MediaData is nil")
            cell.mediaType.text = " "
            cell.beatImage.hidden = true
            cell.playButton.hidden = true
        }
        return cell
    }
    
    func playAudio(beat: Beat) {
        setSessionPlayback()
        let url = NSURL(fileURLWithPath: getImagePath(beat.mediaData!))

        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOfURL: url)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        }
        
    }
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func playVideoWithName(name: String) throws {
        let pathToFile = getPathToFileFromName(name)
        if pathToFile != nil {
            let player = AVPlayer(URL: pathToFile!)
            let playerController = AVPlayerViewController()
            playerController.player = player
            self.presentViewController(playerController, animated: true) {
                print("Playing video")
                player.play()
            }
        }
        
    }
    
    @IBAction func playBeatVideoOrAudio(sender: AnyObject) {
        print("button pressed")
        let beat = self.beats[sender.tag]
        let cell = beatsCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: sender.tag, inSection: 0)) as! BeatCollectionViewCell
        switch beat.mediaType! {
        case MediaType.video:
            print("video")
            do {
                try playVideoWithName(beat.mediaData!)
            } catch {
                print("error in playing video")
            }
        case MediaType.audio:
            print("audio")
            if self.playingCell == nil {
                self.playAudio(beat)
                cell.beatImage.image = UIImage(named: "memo-btn-active")
                self.playingCell = cell
            } else {
                if self.player != nil {
                    self.player.stop()
                    if playingCell != nil {
                        self.playingCell?.beatImage.image = UIImage(named: "memo-btn-passive")
                        self.playingCell = nil
                    }
                }
            }
        case MediaType.image:
            print("image")
            print()
            self.chosenImage = UIImage(contentsOfFile: getImagePath(beat.mediaData!))//UIImage(contentsOfFile: self.getImagePath(beat.mediaData!))
            performSegueWithIdentifier("showImage", sender: self)
        default:
            print("default")
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
        self.playingCell?.beatImage.image = UIImage(named: "memo-btn-passive")
    }
    
    func videoSnapshot(filePathLocal: NSString) -> UIImage? {
        let vidURL = NSURL(fileURLWithPath:filePathLocal as String)
        let asset = AVURLAsset(URL: vidURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        do {
            let imageRef = try generator.copyCGImageAtTime(timestamp, actualTime: nil)
            return UIImage(CGImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    func getImagePath(name: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory: AnyObject = paths[0]
        let dataPath = documentsDirectory.stringByAppendingPathComponent("media/"+name)
        return dataPath
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
    
        // 292 is the width of the cell in the collection
        let currentPage = beatsCollectionView.contentOffset.x / 292
        if Int(ceil(currentPage)) != self.pageControl.currentPage {
            if self.player != nil {
                self.player.stop()
                if playingCell != nil {
                    self.playingCell?.beatImage.image = UIImage(named: "memo-btn-passive")
                    self.playingCell = nil
                }
            }
        }
        self.pageControl.currentPage = Int(ceil(currentPage))
        self.pageCtrlLabel.text = String(pageControl.currentPage+1)+"/"+String(pageControl.numberOfPages)
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        // 292 is the width of the cell in the collection
        let currentPage = beatsCollectionView.contentOffset.x / 292
        if Int(ceil(currentPage)) != self.pageControl.currentPage {
            if self.player != nil {
                self.player.stop()
                if playingCell != nil {
                    self.playingCell?.beatImage.image = UIImage(named: "memo-btn-passive")
                    self.playingCell = nil
                }
            }
        }
        self.pageControl.currentPage = Int(ceil(currentPage))
        self.pageCtrlLabel.text = String(pageControl.currentPage+1)+"/"+String(pageControl.numberOfPages)
    }
    
    @IBAction func unwindToBeats(unwindSegue: UIStoryboardSegue) {
        
    }

}
