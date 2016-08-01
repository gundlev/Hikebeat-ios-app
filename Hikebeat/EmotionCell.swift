//
//  emotionCell.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 01/08/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class EmotionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var emotion: String!
    var selectedImage: UIImage!
    var deselectedImage: UIImage!
    var selectedEmotion = false
    var greenColor = UIColor(colorLiteralRed: 189/255, green: 244/255, blue: 0, alpha: 1)
    
    override func awakeFromNib() {
        
    }
    
    func changeStatus() -> String? {
        print("Emotion cell set to: ", selectedEmotion)
        selectedEmotion = !selectedEmotion
        print("Setting cell with emotion: ", emotion, " to ", selectedEmotion)
        if selectedEmotion {
            imageView.image = selectedImage
            label.textColor = greenColor
            return emotion
        } else {
            imageView.image = deselectedImage
            label.textColor = UIColor.whiteColor()
            return nil
        }
    }
}
