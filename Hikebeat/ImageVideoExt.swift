//
//  ImageVideoExt.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 30/04/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import MobileCoreServices
import Photos

extension ComposeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
/*
     Camera Functions
*/
    
    func chooseImage() {
        let optionsMenu = UIAlertController(title: "Choose resource", message: nil, preferredStyle: .ActionSheet)
        let cameraRoll = UIAlertAction(title: "Photo library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Photo Library")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                print("Library is available")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .PhotoLibrary;
                self.imagePicker.mediaTypes = [kUTTypeImage as String]
                self.imagePicker.allowsEditing = false
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        let takePhoto = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                print("Button capture")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .Camera
                self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
                self.imagePicker.allowsEditing = false
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
        })
        
        optionsMenu.addAction(cameraRoll)
        optionsMenu.addAction(takePhoto)
        optionsMenu.addAction(cancel)
        
        self.presentViewController(optionsMenu, animated: true, completion: nil)
    }



/*
    Requirements of ViewController to which this extension belong:
    
    IBActions:
        @IBAction func record(sender: AnyObject) {
        startRecordingVideo()
        }
        
        @IBAction func play(sender: AnyObject) {
        playVideo()
        }
*/
    
    func chooseVideo() {
        let optionsMenu = UIAlertController(title: "Choose resource for video", message: nil, preferredStyle: .ActionSheet)
        let cameraRoll = UIAlertAction(title: "Video library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Camera Roll")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                print("Button library")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .PhotoLibrary;
                self.imagePicker.mediaTypes = [kUTTypeMovie as String]
                self.imagePicker.allowsEditing = true
                self.imagePicker.videoMaximumDuration = 10
                self.imagePicker.videoQuality = UIImagePickerControllerQualityType.TypeIFrame960x540
                
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        })
        let takePhoto = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                
                print("captureVideoPressed and camera available.")
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType = .Camera;
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Video
                imagePicker.allowsEditing = true
                imagePicker.videoMaximumDuration = 10
                imagePicker.showsCameraControls = true
                imagePicker.videoQuality = UIImagePickerControllerQualityType.TypeIFrame960x540
                //self.imagePicker
                
                
                self.presentViewController(imagePicker, animated: true, completion: nil)
                
            }
                
            else {
                print("Camera not available.")
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
        })
        
        optionsMenu.addAction(cameraRoll)
        optionsMenu.addAction(takePhoto)
        optionsMenu.addAction(cancel)
        
        self.presentViewController(optionsMenu, animated: true, completion: nil)
    }
    
//    func playVideo() {
//        do {
//            try playCurrentVideo()
//        } catch AppError.InvalidResource(let name, let type) {
//            debugPrint("Could not find resource \(name).\(type)")
//        } catch {
//            debugPrint("Generic error")
//        }
//    }
    
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
    
    func getPathToFileFromName(name: String) -> NSURL? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory = paths[0]
        let pathToFile = NSURL(fileURLWithPath: documentDirectory).URLByAppendingPathComponent("media/"+name)
        return pathToFile
    }
    
//    private func playCurrentVideo() throws {
//        let player = AVPlayer(URL: self.currentVideo!)
//        let playerController = AVPlayerViewController()
//        playerController.player = player
//        self.presentViewController(playerController, animated: true) {
//            print("Playing video")
//            player.play()
//        }
//    }
    
    enum AppError : ErrorType {
        case InvalidResource(String, String)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let type = info[UIImagePickerControllerMediaType]
        print(type!.description)

        if type?.description! == "public.movie"{
            
            // user chose video
            let currentVideoURL = info[UIImagePickerControllerMediaURL] as! NSURL
            self.currentMediaURL = currentVideoURL
            if picker.sourceType == .Camera {
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(currentVideoURL.path!) {
                    UISaveVideoAtPathToSavedPhotosAlbum(currentVideoURL.path!, self, nil, nil)
                }
            }
            self.mediaChosen("video")
        } else {
            
            // User chose image
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            if picker.sourceType == .Camera {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
            self.currentImage = image.correctlyOrientedImage()
            self.mediaChosen("image")

        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveMediaToDocs(mediaData: NSData, journeyId: String, timestamp: String, fileType: String) -> String? {
       
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)

        let documentsDirectory: AnyObject = paths[0]
        let fileName = "hikebeat_"+journeyId+"_"+timestamp+fileType
        let dataPath = documentsDirectory.stringByAppendingPathComponent("media/" + fileName)
        let success = mediaData.writeToFile(dataPath, atomically: false)
        if success {
            print("Saved to Docs with name: ", fileName)
            return fileName
        } else {
            return nil
        }
    }
    
    func removeMediaWithURL(mediaURL: NSURL) {
        let fm = NSFileManager()
        do {
            try fm.removeItemAtURL(mediaURL)
        } catch {
            print("problem removing media ")
        }
    }
    
}
