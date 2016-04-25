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
        
        infoContainer.layer.cornerRadius = infoContainer.bounds.height/6
        infoContainer.layer.masksToBounds = true
        
        _ = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(self.backToCompose), userInfo: nil, repeats: false)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backToCompose(){
        performSegueWithIdentifier("goBackToCompose", sender: self)
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
