//
//  EditTitleVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/25/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class EditEmotionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var emotion: String?
    var selectedIndexpath: IndexPath?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        print("The emotion already chosen is: ", emotion)
        super.viewDidLoad()
        saveButton.layer.cornerRadius = saveButton.bounds.height/2
        saveButton.layer.masksToBounds = true
        collectionView.isHidden = false
        
        if (UIDevice.isIphone4 || UIDevice.isIpad) {
            collectionView.transform = CGAffineTransform.identity.scaledBy(x: 0.85, y: 0.85)
        }
//        self.view.addSubview(self.collectionView)
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "saveAndBack", sender: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            performSegue(withIdentifier: "backToCompose", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard (indexPath as NSIndexPath).item != 4 else {return}
        
        let cell = collectionView.cellForItem(at: indexPath) as! EmotionCell
        let result = cell.changeStatus()
        emotion = result
        if result == nil {
            selectedIndexpath = nil
            print("deselected item")
        } else {
            if selectedIndexpath != nil {
                print("already one chosen")
                let oldCell = collectionView.cellForItem(at: selectedIndexpath!) as! EmotionCell
                oldCell.changeStatus()
                selectedIndexpath = indexPath
            } else {
                print("no previously selected emotion")
                selectedIndexpath = indexPath
            }
            
            performSegue(withIdentifier: "saveAndBack", sender: self)
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard (indexPath as NSIndexPath).item != 4 else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "middleCell", for: indexPath)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emotionCell", for: indexPath) as! EmotionCell
        
        switch (indexPath as NSIndexPath).item {
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
    
    func setCell(_ emotion: String, number: String, indexPath: IndexPath) -> EmotionCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emotionCell", for: indexPath) as! EmotionCell
        cell.selectedImage = UIImage(named: emotion+"_selected")!
        cell.deselectedImage = UIImage(named: emotion)!
        cell.imageView.image = UIImage(named: emotion)!
        cell.emotion = emotion
        cell.label.text = emotion.capitalized
        if selectedEmotion(cell.emotion) {
            print("emotion chosen found: ", cell.emotion)
            cell.changeStatus()
            self.selectedIndexpath = indexPath
            print(selectedIndexpath)
        }
        return cell
    }
    
    func selectedEmotion(_ currentEmotion: String) -> Bool {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ComposeVC
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
                vc.editEmotionButton.image = UIImage(named: "EmotionIcon")
            }
//        }
    }
}
