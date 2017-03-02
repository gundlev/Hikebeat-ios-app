//
//  SearchVC.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 10/12/2016.
//  Copyright © 2016 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit
import BrightFutures

class SearchVC: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var serachBar: UISearchBar!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTableView: UITableView!
    
    @IBOutlet weak var placeholderNoConnection: UIView!
    @IBOutlet weak var placeholderInitial: UIView!
    @IBOutlet weak var placeholderNoResults: UIView!
    
    var journeysButton: UIButton!
    var usersButton: UIButton!
    var activityIndicator: UIActivityIndicatorView!
    var currentPage:CGFloat = 0
    var firstLoad = true
//    var journeyTableView: UITableView!
//    var usersTableView: UITableView!
    var scrollViewWidth: CGFloat!
    var scrollViewHeight: CGFloat!
    
    var userSearch: Search? = Search(type: .user)
    var journeySearch: Search? = Search(type: .journey)
    var chosenUser: User!
    var chosenJourney: Journey!
    var chosenType: ListType!
    
    @IBAction func backToSearch(_ unwindSegue: UIStoryboardSegue) {
        
    }
    override func viewDidLoad() {
        if firstLoad {
            
            let bgGradient = CAGradientLayer()
            bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
            bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
            bgGradient.zPosition = -1
            view.layer.addSublayer(bgGradient)
            
            
            let width = UIScreen.main.bounds.width
            let height = UIScreen.main.bounds.height
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
            
            // Used for scrollView
//            scrollView.delegate = self
//            scrollViewWidth = UIScreen.main.bounds.width
//            scrollViewHeight = self.scrollView.frame.height
//            scrollView.isDirectionalLockEnabled = true
//            self.scrollView.contentSize = CGSize(width: scrollViewWidth * 2, height: scrollViewHeight)
//            
//            journeysButton = UIButton(frame: CGRect(x: 0, y: 140, width: scrollViewWidth/2, height: 30))
//            usersButton = UIButton(frame: CGRect(x: 0, y: 140, width: scrollViewWidth/2, height: 30))
//            journeysButton.center = CGPoint(x: self.view.frame.width/4, y: 85)
//            usersButton.center = CGPoint(x: (self.view.frame.width/4)*3, y: 85)
//            journeysButton.setTitleColor(lightGreen, for: .normal)
//            usersButton.setTitleColor(lightGreen, for: .normal)
//            journeysButton.setTitle("Journeys", for: .normal)
//            journeysButton.addTarget(self, action: #selector(journeysButtonTapped), for: .touchUpInside)
//            usersButton.setTitle("Users", for: .normal)
//            usersButton.addTarget(self, action: #selector(usersButtonTapped), for: .touchUpInside)
//            usersButton.alpha = 0.5
// 
//            self.view.addSubview(journeysButton)
//            self.view.addSubview(usersButton)

//            searchTableView = UITableView(frame: CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight))
            searchTableView.delegate = self
            searchTableView.dataSource = self
            searchTableView.register(SearchJourneyCell.self, forCellReuseIdentifier: "journeyCell")
            searchTableView.register(SearchUserCell.self, forCellReuseIdentifier: "userCell")
            searchTableView.register(TableViewSectionHeader.self, forCellReuseIdentifier: "customHeader")
            searchTableView.register(TableViewSectionFooter.self, forCellReuseIdentifier: "customFooter")
            searchTableView.backgroundColor = .clear
            searchTableView.rowHeight = 90
            searchTableView.tag = 1
            searchTableView.delaysContentTouches = false
            searchTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            searchTableView.separatorStyle = .singleLine
            searchTableView.separatorColor = UIColor(red:189/255.0, green:244/255.0, blue:0, alpha:1.00)
            
            searchTableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 30.0, right: 0.0)
//            usersTableView = UITableView(frame: CGRect(x: scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight))
//            usersTableView.delegate = self
//            usersTableView.dataSource = self
//            usersTableView.register(SearchUserCell.self, forCellReuseIdentifier: "userCell")
//            usersTableView.backgroundColor = standardGreen
//            usersTableView.rowHeight = 90
//            usersTableView.tag = 2
            
//            self.addRefreshControl()

//            scrollView.addSubview(searchTableView)
//            scrollView.addSubview(usersTableView)
            
            activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: height/2-25, width: width, height: 50))
            activityIndicator.hidesWhenStopped = true
            self.view.addSubview(activityIndicator)
            
            firstLoad = false
            
            setControlerState(to: .initial)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        activityIndicator.startAnimating()
        showActivity()
        print("search was tapped")
        self.view.endEditing(true)
        guard searchTextField.text != nil else {return true}
        userSearch = Search(type: .user)
        journeySearch = Search(type: .journey)
        guard textField.text! != "" else {
//            activityIndicator.stopAnimating()
            hideActivity()
            setControlerState(to: .initial)
            return true
        }
        let searchText = (searchTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!
        
        search(for: searchText)
        .onSuccess { (state) in
            hideActivity()
            self.setControlerState(to: state)
        }
        return true
    }
    
    func search(for searchText: String) -> Future<controllerState, HikebeatError> {
        return Future { complete in
            var state: controllerState = .noResults
            var returnedCount = 0
            
            func returnCall() {
                if returnedCount == 2 {
                    complete(.success(state))
                }
            }
            
            userSearch?.startSearch(searchText: searchText)
            .onSuccess(callback: { (users) in
                if !users.isEmpty {
                    state = .resultsFound
                }
                returnedCount += 1
                self.searchTableView.reloadData()
                returnCall()
            }).onFailure(callback: { (error) in
                print("ERROR: ", error)
                returnedCount += 1
                returnCall()
            })
            
            
            journeySearch?.startSearch(searchText: searchText)
            .onSuccess(callback: { (journeys) in
                if !journeys.isEmpty {
                    state = .resultsFound
                }
                self.searchTableView.reloadData()
                returnedCount += 1
                returnCall()
            }).onFailure(callback: { (error) in
                print("ERROR: ", error)
                returnedCount += 1
                returnCall()
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let reachability = Reachability()
        
        if reachability?.currentReachabilityStatus == Reachability.NetworkStatus.notReachable {
            setControlerState(to: .noConnection)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        let featuredJourneysFuture = getFeaturedJourneys(nextPage: "")
//        featuredJourneysFuture.onSuccess { (featuredJourneys) in
//            print("returned journeys")
//            self.featuredJourneys = featuredJourneys
//            if self.currentJourneys.isEmpty {
//                self.currentJourneys = self.featuredJourneys
//            }
//            self.journeysTableView.reloadData()
//        }
//        
//        let featuredUsersFuture = getFeaturedUsers(nextPage: "")
//        featuredUsersFuture.onSuccess { (featuredUsers) in
//            print("returned users")
//            print(featuredUsers)
//            self.featuredUsers = featuredUsers
//            if self.currentUsers.isEmpty {
//                self.currentUsers = self.featuredUsers
//            }
//            self.usersTableView.reloadData()
//        }
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
        switch section {
        case 0:
            guard self.userSearch != nil else {return 0}
            guard self.userSearch?.results.count != 0 else {print("usersearch 0"); return 0}
            guard (self.userSearch?.results.count)! < 4 else {return 5}
            return (self.userSearch?.results.count)! + 2
        case 1:
            guard self.journeySearch != nil else {return 0}
            guard self.journeySearch?.results.count != 0 else {print("journeysearch 0");return 0}
            guard (self.journeySearch?.results.count)! < 4 else {return 5}
            return (self.journeySearch?.results.count)! + 2
        default:
            return 0
        }
//        switch tableView.tag {
//        case 1:
//            return self.currentJourneys.count
//        case 2:
//            return self.currentUsers.count
//        default: return 0
//        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        var count = 0
//        if self.userSearch?.results != nil {
//            if (self.userSearch?.results.count)! > 0 {
//                count += 1
//            }
//        }
//        if self.journeySearch?.results != nil {
//            if (self.journeySearch?.results.count)! > 0 {
//                count += 1
//            }
//        }
//        print("Number of sections: ", count)
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
//        let view = tableView.dequeueReusableCell(withIdentifier: "customHeader") as! TableViewSectionHeader
//        view.awakeFromNib()
//        switch section {
//        case 0:
//            view.headerTitle.text = "Users"
//            view.icon.image = UIImage(named: "SexProfileIcon")
//        case 1:
//            view.headerTitle.text = "Journeys"
//            view.icon.image = UIImage(named: "tiny_backpack")
//        default: print("wrong section number")
//        }
//        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 || indexPath.row == 4 || (self.userSearch?.results.count)! + 1 == indexPath.row {
                return 44
            } else {
                return 70
            }
        case 1:
            if indexPath.row == 0 || indexPath.row == 4 || (self.journeySearch?.results.count)! + 1 == indexPath.row {
                return 44
            } else {
                return 70
            }
        default:
            return 0
        }
        if indexPath.row == 0 || indexPath.row == 4 || (self.userSearch?.results.count)! + 1 == indexPath.row {
            return 44
        } else {
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print(indexPath)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                self.chosenType = .user
                self.showAll()
            case 1, 2, 3:
                guard (self.userSearch?.results.count)! >= indexPath.row else {self.chosenType = .user; showAll(); return}
                self.chosenUser = self.userSearch?.results[indexPath.row - 1] as! User!
                self.performSegue(withIdentifier: "showUser", sender: self)
            default:
                self.chosenType = .user
                self.showAll()
            }
        case 1:
            print("row: ", indexPath.row)
            switch indexPath.row {
            case 0:
                self.chosenType = .journey
                self.showAll()
            case 1, 2, 3:
                guard (self.journeySearch?.results.count)! >= indexPath.row else {self.chosenType = .journey; showAll(); return}
                self.chosenJourney = self.journeySearch?.results[indexPath.row - 1] as! Journey!
                self.performSegue(withIdentifier: "showJourney", sender: self)
            default:
                self.chosenType = .journey
                showAll()
            }
        default: print("Dammit")
        }
        
    }
    
    func showAll() {
        self.performSegue(withIdentifier: "showAll", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "customHeader") as! TableViewSectionHeader
                cell.awakeFromNib()
                cell.headerTitle.text = "Users"
                cell.icon.image = UIImage(named: "SexProfileIcon")
                cell.isUserInteractionEnabled = false
                return cell
            }
            if indexPath.row == 4 || (self.userSearch?.results.count)! + 1 == indexPath.row {
                let cell = tableView.dequeueReusableCell(withIdentifier: "customFooter") as! TableViewSectionFooter
                cell.awakeFromNib()
                cell.selectionStyle = .none
                cell.headerTitle.text = "See all"
                return cell
            }
            print("UserCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! SearchUserCell
            cell.awakeFromNib()
            cell.selectionStyle = .none
            let user = self.userSearch?.results[indexPath.row-1] as! User
            print("Creating cell for user: ", user.username)
            if user.profilePhoto != nil {
                cell.profileImage.image = user.profilePhoto!
            } else {
                cell.downloadProfileImage(imageUrl: user.profilePhotoUrl).onSuccess(callback: { (image) in
                    user.profilePhoto = image
                }).onFailure(callback: { (error) in
                    print(error)
                })
            }
            var journeyString = "journeys"
            if Int(user.numberOfJourneys) == 1 {
                journeyString = "journey"
            }
            cell.numberOfJourneys.text = "\(user.numberOfJourneys) \(journeyString)"
            cell.username.text = user.username
            if user.latestBeat != nil {
                cell.followersBeats.text = "Last beat \(getTimeSince(date: user.latestBeat!)) ago"
            } else {
                cell.followersBeats.text = "No beats yet"
            }
            return cell
        default:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "customHeader") as! TableViewSectionHeader
                cell.awakeFromNib()
                cell.headerTitle.text = "Journeys"
                cell.icon.image = UIImage(named: "backpack")
                cell.isUserInteractionEnabled = false
                return cell
            }
            if indexPath.row == 4 || (self.journeySearch?.results.count)! + 1 == indexPath.row {
                let cell = tableView.dequeueReusableCell(withIdentifier: "customFooter") as! TableViewSectionFooter
                cell.awakeFromNib()
                cell.headerTitle.text = "See all"
                cell.selectionStyle = .none
                return cell
            }
            print("JourneyCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "journeyCell") as! SearchJourneyCell
            let journey = self.journeySearch?.results[indexPath.row-1] as! Journey
            print("Creating cell for journey: ", journey.headline)
            cell.awakeFromNib()
            cell.selectionStyle = .none
            cell.headline.text = journey.headline
            cell.followersBeats.text = "\(journey.numberOfFollowers) followers | \(journey.numberOfBeats) beats"
            if journey.ownerProfilePhoto != nil {
                cell.profileImage.image = UIImage(data: journey.ownerProfilePhoto!)
            } else {
                cell.downloadProfileImage(imageUrl: journey.ownerProfilePhotoUrl!).onSuccess(callback: { (image) in
                    journey.ownerProfilePhoto = UIImageJPEGRepresentation(image, 1)
                }).onFailure(callback: { (error) in
                    print(error)
                })
            }
            return cell
        }
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
            case "showJourney":
                let vc = segue.destination as! JourneyContainerVC
                vc.journey = chosenJourney
                vc.save = false
                vc.fromVC = "search"
            case "showAll":
                let vc = segue.destination as! PaginatingVC
                switch self.chosenType! {
                case .user:
                    vc.list = userSearch
                case .journey:
                    vc.list = journeySearch
                default:
                    print("Unknown search type")
                }
        default: print("what")
        }
    }

    enum controllerState {
        case noConnection
        case resultsFound
        case noResults
        case initial
    }
    
    func setControlerState(to: controllerState) {
        switch to {
        case .noConnection:
            placeholderNoResults.isHidden = true
            placeholderNoConnection.isHidden = false
            placeholderInitial.isHidden = true
            searchTableView.isHidden = true
        case .resultsFound:
            placeholderNoResults.isHidden = true
            placeholderNoConnection.isHidden = true
            placeholderInitial.isHidden = true
            searchTableView.isHidden = false
        case .noResults:
            placeholderNoResults.isHidden = false
            placeholderNoConnection.isHidden = true
            placeholderInitial.isHidden = true
            searchTableView.isHidden = true
        case.initial:
            placeholderNoResults.isHidden = true
            placeholderNoConnection.isHidden = true
            placeholderInitial.isHidden = false
            searchTableView.isHidden = true
        }
    }
    
}

