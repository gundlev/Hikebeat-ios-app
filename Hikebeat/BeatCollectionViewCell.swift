//
//  BeatCollectionViewCell.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/30/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit
import RealmSwift

class BeatCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var beatContainer: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var beatMessage: UITextView!
    @IBOutlet weak var beatTitle: UILabel!
    @IBOutlet weak var journeyTitle: UILabel!
    @IBOutlet weak var beatImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var beatTime: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var mediaType: UILabel!
    @IBOutlet weak var mediaLength: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var deleteBoxView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var beat: Beat!
    var save = true
    var fromVC: BeatsVC!
    
    @IBAction func deleteBeat(_ sender: Any) {
        print("Delete beat")
        fromVC.deleteBeatCell(cell: self, beat: beat)
    }
    
    override func awakeFromNib() {
        self.scrollView.isScrollEnabled = false
        spinner.hidesWhenStopped = true
        self.deleteBoxView.layer.cornerRadius = self.deleteBoxView.bounds.height/2
//        self.deleteButton.imageView?.image = self.deleteButton.imageView?.image!.withRenderingMode(.alwaysTemplate)
//        self.deleteButton.imageView?.tintColor = lightGreen
        self.deleteBoxView.backgroundColor = darkGreen
    }
    
    func clear() {
        self.mediaType.text = " "
        self.beatImage.isHidden = true
        self.beatImage.image = nil
        self.mediaType.text = ""
        self.playButton.isHidden = true
    }
    
    func setForBeat(beat: Beat) {

        //        cell.beatTitle.text = beat.title
        self.beatMessage.text = beat.message
        
        if beat.emotion != nil {
            if beat.emotion != "" {
                let emotionName = beat.emotion!.lowercased()
                self.profilePicture.image = UIImage(named: emotionName+"_selected")
            } else {
                self.profilePicture.image = UIImage(named: "missingMoodIcon")
            }
        } else {
            self.profilePicture.image = UIImage(named: "missingMoodIcon")
        }
        
        // setting date
        let formatter = DateFormatter()
        let date = Date(timeIntervalSince1970: TimeInterval(Int(beat.timestamp)!))
        formatter.dateFormat = "d MMMM YYYY H:mm"
        let timeString = formatter.string(from: date)
        self.beatTime.text = timeString
        
        guard let mediaType = beat.mediaType else {
            self.mediaType.text = " "
            self.beatImage.isHidden = true
            self.beatImage.image = nil
            self.mediaType.text = ""
            self.playButton.isHidden = true
            return
        }
        
        switch mediaType {
        case MediaType.image:
            print("image")
            self.beatImage.image = UIImage(named: "picture-btn")
            self.beatImage.contentMode = .scaleAspectFill
            self.mediaType.text = "Image"
            self.setImage()
        case MediaType.video:
            print("video")
            self.beatImage.image = UIImage(named: "video-btn")
            self.mediaType.text = "Video"
            self.setMedia(fileType: "mp4")
        case MediaType.audio:
            print("audio")
            self.beatImage.image = UIImage(named: "memo-btn-passive")
            self.mediaType.text = "Memo"
            self.setMedia(fileType: "m4a")
        default:
            print("default")
            self.mediaType.text = " "
            self.beatImage.isHidden = true
            self.beatImage.image = nil
            self.mediaType.text = ""
            self.playButton.isHidden = true
        }

    }
    
    func setImage() {
        var filename = "/media/hikebeat_\(self.beat.journeyId)_\(self.beat.timestamp).jpg"
        if !self.save {
            filename = "/temp/hikebeat_\(self.beat.journeyId)_\(self.beat.timestamp).jpg"
        }
        print("fileExists: ", fileExist(path: filename))
        if beat.mediaData != nil {
            // media has been downloaded
            beatImage.isHidden = false
            playButton.isHidden = false
            beatImage.image = UIImage(contentsOfFile: getImagePath(beat.mediaData!))
        } else {
            guard !fileExist(path: filename) else {
                beatImage.isHidden = false
                playButton.isHidden = false
                beatImage.image = UIImage(contentsOfFile: getImagePath(filename))
                return
            }
            // Media has to be downloaded first
            spinner.startAnimating()
            beatImage.isHidden = true
            playButton.isHidden = true

            downloadAndStoreImage(mediaUrl: beat.mediaUrl!, fileName: filename)
            .onSuccess(callback: { (image) in
                self.spinner.stopAnimating()
                if image != nil {
                    let realm = try! Realm()
                    self.beatImage.image = image
                    self.beatImage.isHidden = false
                    self.playButton.isHidden = false
                    try! realm.write {
                        self.beat.mediaData = filename
                        print("HERE: ",self.beat.mediaData)
                    }
                } else {
                    print("problems getting the image for beat in setImage")
                }
            }).onFailure(callback: { (error) in
                print("problems getting the image for beat in setImage")
            })
        }
    }
    
    
    func setMedia(fileType: String) {
        if beat.mediaData != nil {
            // media has been downloaded
            beatImage.isHidden = false
            playButton.isHidden = false
        } else {
            // Media has to be downloaded first
            spinner.startAnimating()
            beatImage.isHidden = true
            playButton.isHidden = true
            var filename = "/media/hikebeat_\(self.beat.journeyId)_\(self.beat.timestamp).\(fileType)"
            if !self.save {
                filename = "/temp/hikebeat_\(self.beat.journeyId)_\(self.beat.timestamp).\(fileType)"
            }
            
            guard !fileExist(path: filename) else {
                beatImage.isHidden = false
                playButton.isHidden = false
                return
            }
            
            let downloadFuture = downloadAndStoreMedia(url: beat.mediaUrl!, fileName: filename)
            downloadFuture.onSuccess(callback: { (success) in
                self.spinner.stopAnimating()
                if success {
                    let realm = try! Realm()
                    self.beatImage.isHidden = false
                    self.playButton.isHidden = false
                    try! realm.write {
                        self.beat.mediaData = filename
                    }
                } else {
                    print("problems getting the image for beat in setMedia")
                }
            })
        }

    }
    
}
