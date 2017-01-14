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
    
    var beat: Beat!
    
    override func awakeFromNib() {
        self.scrollView.isScrollEnabled = false
        spinner.hidesWhenStopped = true
    }
    
    func setImage() {
        if beat.mediaData != nil {
            // media has been downloaded
            beatImage.isHidden = false
            playButton.isHidden = false
        } else {
            // Media has to be downloaded first
            spinner.startAnimating()
            beatImage.isHidden = true
            playButton.isHidden = true
            let downloadFuture = downloadAndStoreImage(mediaUrl: beat.mediaUrl!, fileName: "/media/hikebeat_\(beat.journeyId)_\(beat.timestamp).jpg")
            downloadFuture.onSuccess(callback: { (image) in
                self.spinner.stopAnimating()
                if image != nil {
                    let realm = try! Realm()
                    self.beatImage.isHidden = false
                    self.playButton.isHidden = false
                    try! realm.write {
                        self.beat.mediaData = "hikebeat_\(self.beat.journeyId)_\(self.beat.timestamp).jpg"
                        print("HERE: ",self.beat.mediaData)
                    }
                } else {
                    print("problems getting the image for beat in setImage")
                }
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
            let downloadFuture = downloadAndStoreMedia(url: beat.mediaUrl!, fileName: "/media/hikebeat_\(beat.journeyId)_\(beat.timestamp).\(fileType)")
            downloadFuture.onSuccess(callback: { (success) in
                self.spinner.stopAnimating()
                if success {
                    let realm = try! Realm()
                    self.beatImage.isHidden = false
                    self.playButton.isHidden = false
                    try! realm.write {
                        self.beat.mediaData = "hikebeat_\(self.beat.journeyId)_\(self.beat.timestamp).jpg"
                    }
                } else {
                    print("problems getting the image for beat in setImage")
                }
            })
        }

    }
    
}
