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
    var meterTimer:Timer!
    var soundFileURL:URL!
    var audioHasBeenRecordedForThisBeat = false
    
    override func viewDidLoad() {
        
        if(UIDevice.isIphone4 || UIDevice.isIpad){
            saveButton.transform = saveButton.transform.translatedBy(x: 0.0, y: -25.0)
        }
        
        saveButton.layer.cornerRadius = saveButton.bounds.height/2
        saveButton.layer.masksToBounds = true
        
        setInitialAudio()
        saveButton.isHidden = true
        playButton.isHidden = true
        deleteButton.isHidden = true
    }
    
    @IBAction func recordAudio(_ sender: AnyObject) {
        startRecordingAudio()
        self.recordCircle.image = UIImage(named: "record-btn-active")
    }

    @IBAction func insideStop(_ sender: AnyObject) {
        stopRecordingAudio()
    }
    
    @IBAction func outsideStop(_ sender: AnyObject) {
        stopRecordingAudio()
    }
    
    @IBAction func playbackAudio(_ sender: AnyObject) {
        playAudio()
    }
    
    @IBAction func stopPlayback(_ sender: AnyObject) {
        stopPlayingAudio()
    }
    
    @IBAction func deleteCurrentRecording(_ sender: AnyObject) {
        deleteRecording()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToCompose" {
            let vc = segue.destination as! ComposeVC
            vc.mediaChosen(MediaType.audio)
            vc.audioHasBeenRecordedForThisBeat = self.audioHasBeenRecordedForThisBeat
        }
    }
    
}
