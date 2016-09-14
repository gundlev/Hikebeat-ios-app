//
//  EditTitleVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/25/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class EditTitleVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var emotion: String?
    var selectedIndexpath: NSIndexPath?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        print("The emotion already chosen is: ", emotion)
        super.viewDidLoad()
        saveButton.layer.cornerRadius = saveButton.bounds.height/2
        saveButton.layer.masksToBounds = true
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("saveAndBack", sender: self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            performSegueWithIdentifier("backToCompose", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        guard indexPath.item != 4 else {return}
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! EmotionCell
        let result = cell.changeStatus()
        emotion = result
        if result == nil {
            selectedIndexpath = nil
            print("deselected item")
        } else {
            if selectedIndexpath != nil {
                print("already one chosen")
                let oldCell = collectionView.cellForItemAtIndexPath(selectedIndexpath!) as! EmotionCell
                oldCell.changeStatus()
                selectedIndexpath = indexPath
            } else {
                print("no previously selected emotion")
                selectedIndexpath = indexPath
            }
            
            performSegueWithIdentifier("saveAndBack", sender: self)
        }
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard indexPath.item != 4 else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("middleCell", forIndexPath: indexPath)
            return cell
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("emotionCell", forIndexPath: indexPath) as! EmotionCell
        
        switch indexPath.item {
        case 0:
            return setCell("happy", number: "8", indexPath: indexPath)
        case 1:
            return setCell("tired", number: "1", indexPath: indexPath)
        case 2:
            return setCell("sad", number: "2", indexPath: indexPath)
        case 3:
            return setCell("love", number: "7", indexPath: indexPath)
        case 4:
            print("middle one")
        case 5:
            return setCell("anxious", number: "3", indexPath: indexPath)
        case 6:
            return setCell("excited", number: "6", indexPath: indexPath)
        case 7:
            return setCell("relaxed", number: "5", indexPath: indexPath)
        case 8:
            return setCell("angry", number: "4", indexPath: indexPath)
        default:
            print("something is wrong in the switch")
        }
        
        cell.selectedEmotion = false
        return cell
    }
    
    func setCell(emotion: String, number: String, indexPath: NSIndexPath) -> EmotionCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("emotionCell", forIndexPath: indexPath) as! EmotionCell
        cell.selectedImage = UIImage(named: emotion+"_selected")!
        cell.deselectedImage = UIImage(named: emotion)!
        cell.imageView.image = UIImage(named: emotion)!
        cell.emotion = emotion
        cell.label.text = emotion.capitalizedString
        if selectedEmotion(cell.emotion) {
            print("emotion chosen found: ", cell.emotion)
            cell.changeStatus()
            self.selectedIndexpath = indexPath
            print(selectedIndexpath)
        }
        return cell
    }
    
    func selectedEmotion(currentEmotion: String) -> Bool {
        if emotion != nil {
            if currentEmotion == emotion! {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! ComposeVC
//        let titleString = self.titleField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
//        if segue.identifier == "saveAndBack" {
            print("saveButtonModal")
            vc.emotion = emotion
            if emotion != nil {
                vc.applyGreenBorder(vc.editEmotionButton)
                let emotionString = emotion!
                vc.editEmotionButton.image = UIImage(named: emotionString)
            } else {
                vc.removeGreenBorder(vc.editEmotionButton)
                vc.editEmotionButton.image = UIImage(named: "ComposeMessage")
            }
//        }
    }
}
