//
//  MemoExt.swift
//  VideoTestHB
//
//  Created by Niklas Gundlev on 16/01/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension RecordAudioVC:  AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
/*
    Requirements of ViewController to which this extension belong:
    
    IBOutlets:
        @IBOutlet weak var recordButton: UIButton!
        @IBOutlet weak var stopButton: UIButton!
        @IBOutlet weak var playButton: UIButton!
        @IBOutlet weak var statusLabel: UILabel!
    
    IBActions:
        @IBAction func recordAudio(sender: AnyObject) {
        startRecordingAudio()
        }
        
        @IBAction func stopAudio(sender: AnyObject) {
        stopRecordingAudio()
        }
        
        @IBAction func playAudio(sender: AnyObject) {
        playAudio()
        }
    
    Variables:
        var recorder: AVAudioRecorder!
        var player:AVAudioPlayer!
        var meterTimer:NSTimer!
        var soundFileURL:NSURL!
    
    Insert into viewDidLoad:
        setInitialAudio()
*/
    
    
    func setInitialAudio() {
        stopButton.isHidden = true
        playButton.isHidden = true
        setSessionPlayback()
        askForNotifications()
        checkHeadphones()
        print("Audio init complete")
    }
    
    func startRecordingAudio() {
        timeLabel.text = "00:00"
        if player != nil && player.isPlaying {
            player.stop()
        }
        
        if recorder == nil {
            print("recording. recorder nil")
            playButton.isHidden = true
            stopButton.isHidden = true
            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.isRecording {
            print("pausing")
            recorder.pause()
            recordButton.setTitle("Continue", for:UIControlState())
            
        } else {
            print("recording")
            playButton.isHidden = true
            stopButton.isHidden = true
            //            recorder.record()
            recordWithPermission(false)
        }
    }
    
    func deleteRecording() {
        if player != nil {
            self.player.stop()
        }
        self.audioHasBeenRecordedForThisBeat = false
        self.timeLabel.text = "00:00"
        self.recordCircle.image = UIImage(named: "record-btn")
        self.recordButton.isEnabled = true
        self.saveButton.isHidden = true
        self.playButton.isHidden = true
        self.stopButton.isHidden = true
        self.deleteButton.isHidden = true
    }
    
    func stopRecordingAudio() {
        print("stop")
        self.saveButton.isHidden = false
        
        recorder?.stop()
        player?.stop()
        
        meterTimer.invalidate()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
            deleteButton.isHidden = false
            playButton.isHidden = false
            stopButton.isHidden = true
            recordButton.isEnabled = false
        } catch let error as NSError {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
    }
    
    func updateAudioMeter(_ timer:Timer) {
        
        if recorder.isRecording {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
            let s = String(format: "%02d:%02d", min, sec)
            timeLabel.text = s
            recorder.updateMeters()
            // if you want to draw some graphics...
            //var apc0 = recorder.averagePowerForChannel(0)
            //var peak0 = recorder.peakPowerForChannel(0)
        }
    }
    
    func playAudio() {
        setSessionPlayback()
        var url:URL?
        if self.recorder != nil {
            url = self.recorder.url
        } else {
            url = self.soundFileURL! as URL
        }
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url!)
            stopButton.isHidden = false
            playButton.isHidden = true
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        }
        
    }
    
    func stopPlayingAudio() {
        self.player.stop()
        self.playButton.isHidden = false
        self.stopButton.isHidden = true
    }
    
    
    func setupRecorder() {
        let currentFileName = "/media/audio-temp.m4a"
        print(currentFileName)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC as UInt32),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue as AnyObject,
            AVEncoderBitRateKey : 320000 as AnyObject,
            AVNumberOfChannelsKey: 2 as AnyObject,
            AVSampleRateKey : 44100.0 as AnyObject
        ]
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL as URL, settings: recordSettings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    func checkForMicPermission() {
        let microPhoneStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        
        switch microPhoneStatus {
        case .authorized:
            // Has access
            print("Authorized")
        case .denied:
            // No access granted
            print("Denied")
        case .restricted:
            // Microphone disabled in settings
            print("Restricted")
        case .notDetermined:
            // Didn't request access yet
            print("Undetermined")
        }
    }
    
    func recordWithPermission(_ setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            checkForMicPermission()
            
            session.requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                        target:self,
                        selector:#selector(RecordAudioVC.updateAudioMeter(_:)),
                        userInfo:nil,
                        repeats:true)
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
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
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
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
    
    func deleteAllRecordings() {
        let docsDir =
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: docsDir)
            var recordings = files.filter( { (name: String) -> Bool in
                return name.hasSuffix("m4a")
            })
            for i in 0 ..< recordings.count {
                let path = docsDir + "/" + recordings[i]
                
                print("removing \(path)")
                do {
                    try fileManager.removeItem(atPath: path)
                } catch let error as NSError {
                    NSLog("could not remove \(path)")
                    print(error.localizedDescription)
                }
            }
            
        } catch let error as NSError {
            print("could not get contents of directory at \(docsDir)")
            print(error.localizedDescription)
        }
        
    }
    
    func askForNotifications() {
        
        NotificationCenter.default.addObserver(self,
            selector:#selector(RecordAudioVC.background(_:)),
            name:NSNotification.Name.UIApplicationWillResignActive,
            object:nil)
        
        NotificationCenter.default.addObserver(self,
            selector:#selector(RecordAudioVC.foreground(_:)),
            name:NSNotification.Name.UIApplicationWillEnterForeground,
            object:nil)
        
        NotificationCenter.default.addObserver(self,
            selector:#selector(RecordAudioVC.routeChange(_:)),
            name:NSNotification.Name.AVAudioSessionRouteChange,
            object:nil)
    }
    
    func background(_ notification:Notification) {
        print("background")
    }
    
    func foreground(_ notification:Notification) {
        print("foreground")
    }
    
    
    func routeChange(_ notification:Notification) {
        print("routeChange \((notification as NSNotification).userInfo)")
        
        if let userInfo = (notification as NSNotification).userInfo {
            //print("userInfo \(userInfo)")
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                //print("reason \(reason)")
                switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
                case AVAudioSessionRouteChangeReason.newDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.oldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.categoryChange:
                    print("CategoryChange")
                case AVAudioSessionRouteChangeReason.override:
                    print("Override")
                case AVAudioSessionRouteChangeReason.wakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSessionRouteChangeReason.unknown:
                    print("Unknown")
                case AVAudioSessionRouteChangeReason.noSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSessionRouteChangeReason.routeConfigurationChange:
                    print("RouteConfigurationChange")
                    
                }
            }
        }
    }
    
    func checkHeadphones() {
        // check NewDeviceAvailable and OldDeviceUnavailable for them being plugged in/unplugged
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        if currentRoute.outputs.count > 0 {
            for description in currentRoute.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    print("headphones are plugged in")
                    break
                } else {
                    print("headphones are unplugged")
                }
            }
        } else {
            print("checking headphones requires a connection to a device")
        }
    }
    
    
    
/*
    AVAudioRecorderDelegate functions
*/
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
        successfully flag: Bool) {
            print("finished recording \(flag)")
            stopButton.isHidden = true
            playButton.isHidden = false
            self.audioHasBeenRecordedForThisBeat = true
            
            // iOS8 and later
//            let alert = UIAlertController(title: "Recorder",
//                message: "Finished Recording",
//                preferredStyle: .Alert)
//            alert.addAction(UIAlertAction(title: "Keep", style: .Default, handler: {action in
//                print("keep was tapped")
//            }))
//            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: {action in
//                print("delete was tapped")
//                self.recorder.deleteRecording()
//            }))
//            self.presentViewController(alert, animated:true, completion:nil)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder,
        error: Error?) {
            
            if let e = error {
                print("\(e.localizedDescription)")
            }
    }
    
    
/*
    AVAudioPlayerDelegate functions
*/
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
        stopButton.isHidden = true
        playButton.isHidden = false
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let e = error {
            print("\(e.localizedDescription)")
        }
        
    }
    
}
