//
//  SearchVC.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class SearchVC: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var serachBar: UISearchBar!
    @IBOutlet weak var searchTextField: UITextField!
    
    var journeysButton: UIButton!
    var usersButton: UIButton!
    var currentPage:CGFloat = 0
    var firstLoad = true
    var journeysTableView: UITableView!
    var usersTableView: UITableView!
    var scrollViewWidth: CGFloat!
    var scrollViewHeight: CGFloat!
    
    var featuredJourneys = [Journey]()
    var featuredUsers = [User]()
    
    var currentJourneys = [Journey]()
    var currentUsers = [User]()

    override func viewDidLoad() {
        if firstLoad {
            
            self.serachBar.backgroundColor = standardGreen
            self.serachBar.barTintColor = standardGreen
            searchTextField.leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "SearchIconiOS")
            searchTextField.leftView = imageView
            searchTextField.layer.cornerRadius = searchTextField.bounds.height/2
            searchTextField.layer.masksToBounds = true
            searchTextField.returnKeyType = .search
            searchTextField.delegate = self
            
            scrollView.delegate = self
            scrollViewWidth = UIScreen.main.bounds.width
            scrollViewHeight = self.scrollView.frame.height
            scrollView.isDirectionalLockEnabled = true
            self.scrollView.contentSize = CGSize(width: scrollViewWidth * 2, height: scrollViewHeight)
            
            journeysButton = UIButton(frame: CGRect(x: 0, y: 140, width: scrollViewWidth/2, height: 30))
            usersButton = UIButton(frame: CGRect(x: 0, y: 140, width: scrollViewWidth/2, height: 30))
            journeysButton.center = CGPoint(x: self.view.frame.width/4, y: 85)
            usersButton.center = CGPoint(x: (self.view.frame.width/4)*3, y: 85)
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
            journeysTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("search was tapped")
        self.view.endEditing(true)
        return true
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        let featuredJourneysFuture = getFeaturedJourneys(nextPage: "")
        featuredJourneysFuture.onSuccess { (featuredJourneys) in
            print("returned for hell")
            self.featuredJourneys = featuredJourneys
            if self.currentJourneys.isEmpty {
                self.currentJourneys = self.featuredJourneys
            }
            self.journeysTableView.reloadData()
        }
        
        let featuredUsersFuture = getFeaturedUsers(nextPage: "")
        featuredUsersFuture.onSuccess { (featuredUsers) in
            print("returned for hell")
            self.featuredUsers = featuredUsers
            if self.currentUsers.isEmpty {
                self.currentUsers = self.featuredUsers
            }
            self.usersTableView.reloadData()
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
        switch tableView.tag {
        case 1:
            return self.currentJourneys.count
        case 2:
            return self.currentUsers.count
        default: return 0
        }
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
            print("JourneyCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "journeyCell") as! SearchJourneyCell
            let journey = self.currentJourneys[indexPath.row]
            cell.awakeFromNib()
            cell.headline.text = journey.headline
            cell.followersBeats.text = "\(journey.numberOfFollowers) followers | \(journey.numberOfBeats) beats"
            return cell
        default:
            print("UserCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! SearchUserCell
            cell.awakeFromNib()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    
}
