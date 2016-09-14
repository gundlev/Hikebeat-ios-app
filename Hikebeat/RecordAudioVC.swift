//
//  RecordAudioVC.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 21/06/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class RecordAudioVC: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordCircle: UIImageView!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    var meterTimer:NSTimer!
    var soundFileURL:NSURL!
    var audioHasBeenRecordedForThisBeat = false
    
    override func viewDidLoad() {
        
        if(UIDevice.isIphone4 || UIDevice.isIpad){
            saveButton.transform = CGAffineTransformTranslate( saveButton.transform, 0.0, -25.0)
        }
        
        saveButton.layer.cornerRadius = saveButton.bounds.height/2
        saveButton.layer.masksToBounds = true
        
        setInitialAudio()
        saveButton.hidden = true
        playButton.hidden = true
        deleteButton.hidden = true
    }
    
    @IBAction func recordAudio(sender: AnyObject) {
        startRecordingAudio()
        self.recordCircle.image = UIImage(named: "record-btn-active")
    }

    @IBAction func insideStop(sender: AnyObject) {
        stopRecordingAudio()
    }
    
    @IBAction func outsideStop(sender: AnyObject) {
        stopRecordingAudio()
    }
    
    @IBAction func playbackAudio(sender: AnyObject) {
        playAudio()
    }
    
    @IBAction func stopPlayback(sender: AnyObject) {
        stopPlayingAudio()
    }
    
    @IBAction func deleteCurrentRecording(sender: AnyObject) {
        deleteRecording()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "backToCompose" {
            let vc = segue.destinationViewController as! ComposeVC
            vc.mediaChosen(MediaType.audio)
            vc.audioHasBeenRecordedForThisBeat = self.audioHasBeenRecordedForThisBeat
        }
    }
    
}
