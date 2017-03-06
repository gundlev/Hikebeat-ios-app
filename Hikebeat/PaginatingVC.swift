//
//  PaginatingVC.swift
//  Hikebeat
//
//  Created by Niklas Gundlev on 05/02/2017.
//  Copyright © 2017 Niklas Gundlev. All rights reserved.
//

import Foundation
import UIKit

class PaginatingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var list: PaginatingList?
    var chosenJourney: Journey?
    var fromVC = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func back(_ sender: Any) {
        switch fromVC {
        case "search":
            self.performSegue(withIdentifier: "backToSearch", sender: self)
        case "profile":
            self.performSegue(withIdentifier: "backToProfile", sender: self)
        case "journey":
            self.performSegue(withIdentifier: "backToJourney", sender: self)
        default: print("What")
        }
    }
    
    @IBAction func backToShowAll(_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        
        let bgGradient = CAGradientLayer()
        bgGradient.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
        bgGradient.colors = [UIColor(red: (47/255.0), green: (160/255.0), blue: (165/255.0), alpha: 1).cgColor, UIColor(red: (79/255.0), green: (150/255.0), blue: (68/255.0), alpha: 1).cgColor]
        bgGradient.zPosition = -1
        view.layer.addSublayer(bgGradient)
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(SearchJourneyCell.self, forCellReuseIdentifier: "journeyCell")
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: "userCell")
        tableView.register(TableViewPaginationFooter.self, forCellReuseIdentifier: "footer")

        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(red:189/255.0, green:244/255.0, blue:0, alpha:1.00)
        
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 40.0, right: 0.0)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row != list?.results.count else {
            let footer = tableView.dequeueReusableCell(withIdentifier: "footer") as! TableViewPaginationFooter
            footer.awakeFromNib()
            footer.footerTitle.text = "Load more"
            if list != nil {
                if list!.hasNextpage() {
                    footer.startActivity()
                    list!.nextPage()
                    .onSuccess(callback: { (newLoad) in
                        footer.stopActivity()
                        self.tableView.reloadData()
                    }).onFailure(callback: { (error) in
                        footer.stopActivity()
                        print("Error: ", error)
                    })
                } else {
                    footer.footerTitle.text = "No more results"
                    footer.selectionStyle = .none
                }
            }
            return footer
        }
        
        if list != nil {
            switch list!.type {
            case .user:
                print("User")
                let user = list?.results[indexPath.row] as! User
                return getUserCell(user: user, tableView: tableView)
            case .journey:
                print("Journey")
                let journey = self.list?.results[indexPath.row] as! Journey
                return getJourneyCell(journey: journey, tableView: tableView)
            case .follower:
                print("follower")
                let user = list?.results[indexPath.row] as! User
                return getUserCell(user: user, tableView: tableView)
            case .following:
                print("following")
                let journey = self.list?.results[indexPath.row] as! Journey
                return getJourneyCell(journey: journey, tableView: tableView)
            }
        } else { return UITableViewCell() }
    }
    
    func getUserCell(user: User, tableView: UITableView) -> SearchUserCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! SearchUserCell
        cell.awakeFromNib()
        cell.selectionStyle = .none
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
    }
    
    func getJourneyCell(journey: Journey, tableView: UITableView) -> SearchJourneyCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journeyCell") as! SearchJourneyCell
        //                print("Creating cell for journey: ", journey.headline)
        cell.awakeFromNib()
        cell.selectionStyle = .none
        cell.headline.text = journey.headline
        cell.followButton.isHighlighted = journey.isFollowed
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if list != nil {
            guard indexPath.row != list?.results.count else {
                let footer = tableView.cellForRow(at: indexPath) as! TableViewPaginationFooter
                footer.startActivity()
                list!.nextPage()
                .onSuccess(callback: { (newLoad) in
                    footer.stopActivity()
                    self.tableView.reloadData()
                }).onFailure(callback: { (error) in
                    footer.stopActivity()
                    print("Error: ", error)
                })
                return
            }
            
            switch list!.type{
            case .user:
                print("tapped user")
            case .journey:
                self.chosenJourney = list?.results[indexPath.row] as! Journey?
                performSegue(withIdentifier: "showJourney", sender: self)
            default:
                print("unknown type")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row != list?.results.count else {return 44}
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if list != nil {
            return (list?.results.count)! + 1
        } else { return 0 }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
            case "showJourney":
            let vc = segue.destination as! JourneyContainerVC
            vc.journey = chosenJourney
            vc.fromVC = "showAll"
            vc.save = false
        default: print("default segue")
        }
    }
    
}
