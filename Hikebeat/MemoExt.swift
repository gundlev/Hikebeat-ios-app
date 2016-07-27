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
        stopButton.hidden = true
        playButton.hidden = true
        setSessionPlayback()
        askForNotifications()
        checkHeadphones()
        print("Audio init complete")
    }
    
    func startRecordingAudio() {
        timeLabel.text = "00:00"
        if player != nil && player.playing {
            player.stop()
        }
        
        if recorder == nil {
            print("recording. recorder nil")
            playButton.hidden = true
            stopButton.hidden = true
            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.recording {
            print("pausing")
            recorder.pause()
            recordButton.setTitle("Continue", forState:.Normal)
            
        } else {
            print("recording")
            playButton.hidden = true
            stopButton.hidden = true
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
        self.recordButton.enabled = true
        self.saveButton.hidden = true
        self.playButton.hidden = true
        self.stopButton.hidden = true
        self.deleteButton.hidden = true
    }
    
    func stopRecordingAudio() {
        print("stop")
        self.saveButton.hidden = false
        
        recorder?.stop()
        player?.stop()
        
        meterTimer.invalidate()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
            deleteButton.hidden = false
            playButton.hidden = false
            stopButton.hidden = true
            recordButton.enabled = false
        } catch let error as NSError {
            print("could not make session inactive")
            print(error.localizedDescription)
        }
    }
    
    func updateAudioMeter(timer:NSTimer) {
        
        if recorder.recording {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime % 60)
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
        var url:NSURL?
        if self.recorder != nil {
            url = self.recorder.url
        } else {
            url = self.soundFileURL!
        }
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOfURL: url!)
            stopButton.hidden = false
            playButton.hidden = true
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
        self.playButton.hidden = false
        self.stopButton.hidden = true
    }
    
    
    func setupRecorder() {
        let currentFileName = "audio-temp.m4a"
        print(currentFileName)
        
        let documentsDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        self.soundFileURL = documentsDirectory.URLByAppendingPathComponent(currentFileName)
        
        if NSFileManager.defaultManager().fileExistsAtPath(soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(unsignedInt:kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        
        do {
            recorder = try AVAudioRecorder(URL: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    func recordWithPermission(setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector(#selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
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
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        let fileManager = NSFileManager.defaultManager()
        
        do {
            let files = try fileManager.contentsOfDirectoryAtPath(docsDir)
            var recordings = files.filter( { (name: String) -> Bool in
                return name.hasSuffix("m4a")
            })
            for i in 0 ..< recordings.count {
                let path = docsDir + "/" + recordings[i]
                
                print("removing \(path)")
                do {
                    try fileManager.removeItemAtPath(path)
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
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:#selector(RecordAudioVC.background(_:)),
            name:UIApplicationWillResignActiveNotification,
            object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:#selector(RecordAudioVC.foreground(_:)),
            name:UIApplicationWillEnterForegroundNotification,
            object:nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector:#selector(RecordAudioVC.routeChange(_:)),
            name:AVAudioSessionRouteChangeNotification,
            object:nil)
    }
    
    func background(notification:NSNotification) {
        print("background")
    }
    
    func foreground(notification:NSNotification) {
        print("foreground")
    }
    
    
    func routeChange(notification:NSNotification) {
        print("routeChange \(notification.userInfo)")
        
        if let userInfo = notification.userInfo {
            //print("userInfo \(userInfo)")
            if let reason = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt {
                //print("reason \(reason)")
                switch AVAudioSessionRouteChangeReason(rawValue: reason)! {
                case AVAudioSessionRouteChangeReason.NewDeviceAvailable:
                    print("NewDeviceAvailable")
                    print("did you plug in headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.OldDeviceUnavailable:
                    print("OldDeviceUnavailable")
                    print("did you unplug headphones?")
                    checkHeadphones()
                case AVAudioSessionRouteChangeReason.CategoryChange:
                    print("CategoryChange")
                case AVAudioSessionRouteChangeReason.Override:
                    print("Override")
                case AVAudioSessionRouteChangeReason.WakeFromSleep:
                    print("WakeFromSleep")
                case AVAudioSessionRouteChangeReason.Unknown:
                    print("Unknown")
                case AVAudioSessionRouteChangeReason.NoSuitableRouteForCategory:
                    print("NoSuitableRouteForCategory")
                case AVAudioSessionRouteChangeReason.RouteConfigurationChange:
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
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder,
        successfully flag: Bool) {
            print("finished recording \(flag)")
            stopButton.hidden = true
            playButton.hidden = false
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
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder,
        error: NSError?) {
            
            if let e = error {
                print("\(e.localizedDescription)")
            }
    }
    
    
/*
    AVAudioPlayerDelegate functions
*/
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing \(flag)")
        stopButton.hidden = true
        playButton.hidden = false
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        if let e = error {
            print("\(e.localizedDescription)")
        }
        
    }
    
}
