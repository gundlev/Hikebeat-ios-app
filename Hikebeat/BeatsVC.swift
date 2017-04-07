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
import SwiftyDrop

class BeatsVC: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var beatsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var pageCtrlLabel: UILabel!
    @IBOutlet weak var altPageControl: UIView!
    @IBOutlet weak var deleteBeatButton: UIButton!
    
    var startingIndex: Int!
    var journey: Journey!
    var beats: [Beat]!
    var player:AVAudioPlayer!
    var playingCell: BeatCollectionViewCell?
    var chosenImage: UIImage?
    var save = true

    
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
        print("View did load beatsVC")
        print(self.journey.beats)
        self.beats = self.journey.beats.sorted()//  .sorted(byKeyPath: "timestamp")
        print("here not")
        // Do any additional setup after loading the view.
        self.pageControl.numberOfPages = beatsCollectionView.numberOfItems(inSection: 0)
        self.pageControl.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
        
        beatsCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let indexpath = IndexPath(item: startingIndex, section: 0)
        self.beatsCollectionView.scrollToItem(at: indexpath, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        pageControl.currentPage = startingIndex
        pageCtrlLabel.text = String(pageControl.currentPage+1)+"/"+String(pageControl.numberOfPages)
        
        if pageControl.numberOfPages>10 {
            pageControl.isHidden = true
            altPageControl.isHidden = false
        }else{
            pageControl.isHidden = false
            altPageControl.isHidden = true
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Close the modal before you leave
        self.dismiss(animated: false, completion: nil)
    }
}

extension BeatsVC : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("num items")
        return self.beats.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("Num sections")
        return 1
    }
    
    func deleteBeatCell(cell: BeatCollectionViewCell, beat: Beat) {
        guard beat.messageId != nil else {
            Drop.down("This beat was send as text message and can not be deleted at this time.", state: .error)
            return
        }
        print("delete from collection")
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        
        _ = alertView.addButton("Yes") {
            let indexPath = self.beatsCollectionView.indexPath(for: cell)!
            self.beats.remove(at: indexPath.item)
            self.beatsCollectionView.deleteItems(at: [indexPath])
            self.pageControl.numberOfPages = self.beatsCollectionView.numberOfItems(inSection: 0)
            self.pageControl.updateCurrentPageDisplay()
            let realm = try! Realm()
            deleteBeat(messageId: beat.messageId!)
            .onSuccess(callback: { (success) in
                try! realm.write {
                    realm.delete(beat)
                    print("Beat deleted")
                }
            }).onFailure(callback: { (error) in
                let change = createSimpleChange(type: .deleteBeat, key: beat.messageId!, value: nil, valueBool: nil)
                saveChange(change: change)
                try! realm.write {
                    realm.delete(beat)
                    print("Beat deleted")
                }
            })
        }
        _ = alertView.addButton("No") {}
        _ = alertView.showNotice("Are you sure?", subTitle: "\nAre you sure you want to delete this beat permanently?")
        

        // TODO delete beat
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BeatCell", for: indexPath) as! BeatCollectionViewCell
        
        let beat = self.beats[(indexPath as NSIndexPath).item]
        print("Beat Emotion: ", beat.emotion)
        cell.beat = beat
        if(UIDevice.isIphone4 || UIDevice.isIpad){
            cell.beatContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.7, y: 0.7);
            cell.beatContainer.transform = cell.beatContainer.transform.translatedBy(x: 0.0, y: -20.0  )
        }else if(UIDevice.isIphone5){
            cell.beatContainer.transform = CGAffineTransform.identity.scaledBy(x: 0.85, y: 0.85);
            cell.beatContainer.transform = cell.beatContainer.transform.translatedBy(x: 0.0, y: -20.0  )
        }
        cell.save = save
        cell.beatContainer.layer.cornerRadius = 30
        cell.beatContainer.layer.masksToBounds = true
        
        cell.beatImage.layer.cornerRadius = 25
        cell.beatImage.layer.masksToBounds = true

        cell.deleteBoxView.isHidden = !save
        cell.fromVC = self
        
        if beat.emotion != nil {
            if beat.emotion != "" {
                let emotionName = beat.emotion!.lowercased()
                cell.profilePicture.image = UIImage(named: emotionName+"_selected")
            } else {
                cell.profilePicture.image = UIImage(named: "missingMoodIcon")
            }
        } else {
            cell.profilePicture.image = UIImage(named: "missingMoodIcon")
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
        let path = UIBezierPath(arcCenter: CGPoint(x: cell.profilePicture.bounds.midX, y: cell.profilePicture.bounds.midY), radius: width / 2, startAngle: CGFloat(0.0), endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        
        // update mask and save for future reference
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        cell.profilePicture.layer.mask = mask
        
        // create border layer
        
        let frameLayer = CAShapeLayer()
        frameLayer.path = path.cgPath
        frameLayer.lineWidth = 4
        frameLayer.strokeColor = UIColor.white.cgColor
        frameLayer.fillColor = nil
        
        // if we had previous border remove it, add new one, and save reference to new one
        cell.profilePicture.layer.addSublayer(frameLayer)
        
        cell.scrollView.isUserInteractionEnabled = true
        cell.scrollView.isScrollEnabled = false
        
        cell.journeyTitle.text = journey.headline
//        cell.beatTitle.text = beat.title
        cell.beatMessage.text = beat.message
        
        
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.bounds.height/2
        cell.profilePicture.layer.masksToBounds = true
        
        cell.scrollView.contentSize = CGSize(width: 230, height: 1000)
        
        // setting date
        let formatter = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(Int(beat.timestamp)!))
        formatter.dateFormat = "d MMMM YYYY H:mm"
        let timeString = formatter.string(from: date)
        cell.beatTime.text = timeString
        
        
        // setting beat media
            print("Item :", (indexPath as NSIndexPath).item)
        
        guard let mediaType = beat.mediaType else {
            cell.mediaType.text = " "
            cell.beatImage.isHidden = true
            cell.beatImage.image = nil
            cell.mediaType.text = ""
            cell.playButton.isHidden = true
            return cell
        }
        
        switch mediaType {
            case MediaType.image:
                print("image")
                cell.playButton.tag = (indexPath as NSIndexPath).item
                cell.beatImage.image = UIImage(named: "picture-btn")
                cell.beatImage.contentMode = .scaleAspectFill
                cell.mediaType.text = "Image"
                cell.setImage()
            case MediaType.video:
                print("video")
                cell.beatImage.image = UIImage(named: "video-btn")
                cell.playButton.tag = (indexPath as NSIndexPath).item
                cell.mediaType.text = "Video"
                cell.setMedia(fileType: "mp4")
            case MediaType.audio:
                print("audio")
                cell.beatImage.image = UIImage(named: "memo-btn-passive")
                cell.playButton.tag = (indexPath as NSIndexPath).item
                cell.mediaType.text = "Memo"
                cell.setMedia(fileType: "m4a")
            default:
                print("default")
                cell.mediaType.text = " "
                cell.beatImage.isHidden = true
                cell.playButton.isHidden = true
        }
        return cell
    }
    
    func playAudio(_ beat: Beat) {
        setSessionPlayback()
        let url = URL(fileURLWithPath: getImagePath(beat.mediaData!))

        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
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
    
    func playVideoWithName(_ name: String) throws {
        let pathToFile = getPathToFileFromName(name)
        if pathToFile != nil {
            let player = AVPlayer(url: pathToFile!)
            let playerController = AVPlayerViewController()
            playerController.player = player
            self.present(playerController, animated: true) {
                print("Playing video")
                player.play()
            }
        }
        
    }
    
    @IBAction func playBeatVideoOrAudio(_ sender: AnyObject) {
        print("button pressed")
        let beat = self.beats[sender.tag]
        if let cell = beatsCollectionView.cellForItem(at: IndexPath(item: sender.tag, section: 0)) as? BeatCollectionViewCell {
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
               showImage(UIImage(contentsOfFile: getImagePath(beat.mediaData!)))
            default:
                print("default")
            }
        }
    }
    
    func showImage(_ image: UIImage?){
        guard let image = image else {
            return
        }
        
        let agrume = Agrume(image: image, backgroundColor: .black)
        agrume.hideStatusBar = true
        agrume.showFrom(self)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
        self.playingCell?.beatImage.image = UIImage(named: "memo-btn-passive")
    }
    
    func videoSnapshot(_ filePathLocal: NSString) -> UIImage? {
        let vidURL = URL(fileURLWithPath:filePathLocal as String)
        let asset = AVURLAsset(url: vidURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
    
    func getImagePath(_ path: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let dataPath = documentsDirectory.appending(path)
        return dataPath
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    
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
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
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
    
    @IBAction func unwindToBeats(_ unwindSegue: UIStoryboardSegue) {
        
    }

}
