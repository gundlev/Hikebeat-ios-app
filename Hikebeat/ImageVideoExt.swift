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
        let optionsMenu = UIAlertController(title: "Choose resource", message: nil, preferredStyle: .actionSheet)
        let cameraRoll = UIAlertAction(title: "Photo library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Photo Library")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
                print("Library is available")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .photoLibrary;
                self.imagePicker.mediaTypes = [kUTTypeImage as String]
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        let takePhoto = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                print("Button capture")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.photo
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
        })
        
        optionsMenu.addAction(cameraRoll)
        optionsMenu.addAction(takePhoto)
        optionsMenu.addAction(cancel)
        
        self.present(optionsMenu, animated: true, completion: nil)
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
        let optionsMenu = UIAlertController(title: "Choose resource for video", message: nil, preferredStyle: .actionSheet)
        let cameraRoll = UIAlertAction(title: "Video library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Camera Roll")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
                print("Button library")
                
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .photoLibrary;
                self.imagePicker.mediaTypes = [kUTTypeMovie as String]
                self.imagePicker.allowsEditing = true
                self.imagePicker.videoMaximumDuration = 10
                self.imagePicker.videoQuality = UIImagePickerControllerQualityType.typeIFrame960x540
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        })
        let takePhoto = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                
                print("captureVideoPressed and camera available.")
                
                let imagePicker = UIImagePickerController()
                
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.video
                imagePicker.allowsEditing = true
                imagePicker.videoMaximumDuration = 10
                imagePicker.showsCameraControls = true
                imagePicker.videoQuality = UIImagePickerControllerQualityType.typeIFrame960x540
                //self.imagePicker
                
                
                self.present(imagePicker, animated: true, completion: nil)
                
            }
                
            else {
                print("Camera not available.")
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Take Photo")
        })
        
        optionsMenu.addAction(cameraRoll)
        optionsMenu.addAction(takePhoto)
        optionsMenu.addAction(cancel)
        
        self.present(optionsMenu, animated: true, completion: nil)
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
    
    func getPathToFileFromName(_ name: String) -> URL? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = paths[0]
        let pathToFile = URL(fileURLWithPath: documentDirectory).appendingPathComponent("media/"+name)
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
    
    enum AppError : Error {
        case invalidResource(String, String)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let type = info[UIImagePickerControllerMediaType]
        print((type! as AnyObject).description)

        if (type as AnyObject).description! == "public.movie"{
            
            // user chose video
            let currentVideoURL = info[UIImagePickerControllerMediaURL] as! URL
            self.currentMediaURL = currentVideoURL
            if picker.sourceType == .camera {
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(currentVideoURL.path) {
                    UISaveVideoAtPathToSavedPhotosAlbum(currentVideoURL.path, self, nil, nil)
                }
            }
            self.mediaChosen("video")
        } else {
            
            // User chose image
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            
            if picker.sourceType == .camera {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
            self.currentImage = image.correctlyOrientedImage()
            self.mediaChosen("image")

        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveMediaToDocs(_ mediaData: Data, journeyId: String, timestamp: String, fileType: String) -> String? {
       
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)

        let documentsDirectory: AnyObject = paths[0] as AnyObject
        let fileName = "hikebeat_"+journeyId+"_"+timestamp+fileType
        let dataPath = documentsDirectory.appending("/media/" + fileName)
        let success = (try? mediaData.write(to: URL(fileURLWithPath: dataPath), options: [])) != nil
        if success {
            print("Saved to Docs with name: ", fileName)
            return fileName
        } else {
            return nil
        }
    }
    
    func removeMediaWithURL(_ mediaURL: URL) {
        let fm = FileManager()
        do {
            try fm.removeItem(at: mediaURL)
        } catch {
            print("problem removing media ")
        }
    }
    
}
