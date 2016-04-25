//
//  ComposeVC.swift
//  Hikebeat
//
//  Created by Dimitar Gyurov on 4/23/16.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import UIKit

class ComposeVC: UIViewController {

    @IBOutlet weak var editTitleButton: UIImageView!
    @IBOutlet weak var editMessageButton: UIImageView!
    @IBOutlet weak var editImageButton: UIImageView!
    @IBOutlet weak var sendBeatButton: UIButton!
    @IBOutlet weak var editMemoButton: UIImageView!
    @IBOutlet weak var editVideoButton: UIImageView!
    
    @IBAction func sendBeat(sender: AnyObject) {
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        editTitleButton.layer.cornerRadius = editTitleButton.bounds.width/2
        editMessageButton.layer.cornerRadius = editMessageButton.bounds.width/2
        editVideoButton.layer.cornerRadius = editVideoButton.bounds.width/2
        editMemoButton.layer.cornerRadius = editMemoButton.bounds.width/2
        editImageButton.layer.cornerRadius = editImageButton.bounds.width/2
        sendBeatButton.layer.cornerRadius = sendBeatButton.bounds.height/2
        
        editTitleButton.layer.masksToBounds = true
        editMessageButton.layer.masksToBounds = true
        editImageButton.layer.masksToBounds = true
        editVideoButton.layer.masksToBounds = true
        editMemoButton.layer.masksToBounds = true
        sendBeatButton.layer.masksToBounds = true
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.mainScreen().bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).CGColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).CGColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        
        editTitleButton.userInteractionEnabled = true
        editMemoButton.userInteractionEnabled = true
        editImageButton.userInteractionEnabled = true
        editVideoButton.userInteractionEnabled = true
        editMessageButton.userInteractionEnabled = true
        
        editTitleButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(titleButtonTapped)))
        editMemoButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(memoButtonTapped)))
        editImageButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(imageButtonTapped)))
        editVideoButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(videoButtonTapped)))
        editMessageButton.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(messageButtonTapped)))
        
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func titleButtonTapped() {
        
    }

    func memoButtonTapped() {
        
    }
    
    func imageButtonTapped() {
        
    }
    
    func videoButtonTapped() {
        
    }
    
    func messageButtonTapped() {
        
    }
}
