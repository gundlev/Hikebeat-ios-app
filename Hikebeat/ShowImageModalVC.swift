//
//  ShowImageModalVC.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 21/06/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class ShowImageModalVC: UIViewController {
    
    var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        self.imageView.image = image
    }
}
