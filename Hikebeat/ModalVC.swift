//
//  ModalVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/25/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class ModalVC: UIViewController {

    @IBOutlet weak var infoContainer: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        infoContainer.layer.cornerRadius = infoContainer.bounds.height/4
        infoContainer.layer.masksToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
