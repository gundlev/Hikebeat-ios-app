//
//  SearchVC.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class SearchVC: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var journeysButton: UIButton!
    var usersButton: UIButton!
    var currentPage:CGFloat = 0
    var firstLoad = true
    var journeysTableView: UITableView!
    var usersTableView: UITableView!
    var scrollViewWidth: CGFloat!
    var scrollViewHeight: CGFloat!
    
    override func viewDidLoad() {
        if firstLoad {
            
            scrollView.delegate = self
            scrollViewWidth = UIScreen.main.bounds.width
            scrollViewHeight = self.scrollView.frame.height
            scrollView.isDirectionalLockEnabled = true
            self.scrollView.contentSize = CGSize(width: scrollViewWidth * 2, height: scrollViewHeight)

            
            journeysButton = UIButton(frame: CGRect(x: 0, y: 40, width: scrollViewWidth/2, height: 30))
            usersButton = UIButton(frame: CGRect(x: 0, y: 40, width: scrollViewWidth/2, height: 30))
            journeysButton.center = CGPoint(x: self.view.frame.width/4, y: 50)
            usersButton.center = CGPoint(x: (self.view.frame.width/4)*3, y: 50)
            journeysButton.setTitleColor(lightGreen, for: .normal)
            usersButton.setTitleColor(lightGreen, for: .normal)
            journeysButton.setTitle("Journeys", for: .normal)
            journeysButton.addTarget(self, action: #selector(journeysButtonTapped), for: .touchUpInside)
            usersButton.setTitle("Users", for: .normal)
            usersButton.addTarget(self, action: #selector(usersButtonTapped), for: .touchUpInside)
            usersButton.alpha = 0.5
 
            self.view.addSubview(journeysButton)
            self.view.addSubview(usersButton)

            journeysTableView = UITableView(frame: CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight))
            journeysTableView.delegate = self
            journeysTableView.dataSource = self
            journeysTableView.register(SearchJourneyCell.self, forCellReuseIdentifier: "journeyCell")
            journeysTableView.backgroundColor = standardGreen
            journeysTableView.rowHeight = 90
            journeysTableView.tag = 1
            journeysTableView.delaysContentTouches = false
            
            usersTableView = UITableView(frame: CGRect(x: scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight))
            usersTableView.delegate = self
            usersTableView.dataSource = self
            usersTableView.register(SearchUserCell.self, forCellReuseIdentifier: "userCell")
            usersTableView.backgroundColor = standardGreen
            usersTableView.rowHeight = 90
            usersTableView.tag = 2
            
//            self.addRefreshControl()

            scrollView.addSubview(journeysTableView)
            scrollView.addSubview(usersTableView)
            
            firstLoad = false
        }

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let fractionalPage = self.scrollView.contentOffset.x/scrollViewWidth
        if round(fractionalPage) != currentPage {
            print("Page change")
            self.currentPage = round(fractionalPage)
            changePage(round(fractionalPage))
        }
    }
    
    func changePage(_ index: CGFloat) {
        self.currentPage = index
        switch index {
        case 0:
            journeysButton.alpha = 1
            usersButton.alpha = 0.5
        //            soldButton.alpha = 0.5
        case 1:
            journeysButton.alpha = 0.5
            usersButton.alpha = 1
        //            soldButton.alpha = 0.5
        default:
            journeysButton.alpha = 0.5
            usersButton.alpha = 0.5
            //            soldButton.alpha = 1
        }
    }
    
    func journeysButtonTapped() {
        print("shops called")
        UIView.animate(withDuration: TimeInterval(0.3), animations: {
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        })
    }
    
    func usersButtonTapped() {
        print("giftcards called")
        UIView.animate(withDuration: TimeInterval(0.3), animations: {
            self.scrollView.contentOffset = CGPoint(x: self.scrollViewWidth, y: 0)
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView.tag {
        case 1:
            print("show journey")
        case 2:
            print("show user")
        default: print("Dammit")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag {
        case 1:
            print("One")
            let cell = tableView.dequeueReusableCell(withIdentifier: "journeyCell") as! SearchJourneyCell
            cell.awakeFromNib()
            return cell
        default:
            print("Two")
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! SearchUserCell
            cell.awakeFromNib()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    
}
