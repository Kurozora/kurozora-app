//
//  NotificationViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import UIKit
import KCommonKit
import KDatabaseKit

protocol NotificationsViewControllerDelegate: class {
    func notificationsViewControllerHasUnreadNotifications(count: Int)
    func notificationsViewControllerClearedAllNotifications()
}

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Other sessions"
//    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.init(red: 55/255.0, green: 61/255.0, blue: 85/255.0, alpha: 1.0)
//
//        let headerLabel = UILabel(frame: CGRect(x: 8, y: 0, width:
//            tableView.bounds.size.width, height: tableView.bounds.size.height))
//        headerLabel.font = UIFont(name: "System", size: 17)
//        headerLabel.textColor = UIColor.white
//        headerLabel.text = self.tableView(self.tableView, titleForHeaderInSection: section)
//        headerLabel.sizeToFit()
//        headerView.addSubview(headerLabel)
//
//        return headerView
//    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationCell:NotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath as IndexPath) as! NotificationCell
    
        notificationCell.notificationType.text = "MESSAGE"
        notificationCell.notificationDate.text = "18m ago"
        notificationCell.notificationIcon.image = UIImage(named: "chat.png")
        notificationCell.profileImage.image = UIImage(named: "user_male.png")
        notificationCell.username.text = "Usopp"
        notificationCell.notificationTextLable.text = "This is a pretty long text which shouldn't completly fit inside this text field but if it does then fk it I'm studpid and don't know how long a long text should be. Fudge!"
        
        NSLog("------------------DATA START-------------------")
        NSLog("Response String: \(String(describing: indexPath.row))")
        NSLog("------------------DATA END-------------------")
        
        return notificationCell
    }
    
//    var fetchController = FetchController()
//    var animator: ZFModalTransitionAnimator!
//
//    weak var delegate: NotificationsViewControllerDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Notifications"
//        tableView.estimatedRowHeight = 112.0
//        tableView.rowHeight = UITableViewAutomaticDimension
//
//        let clearAll = UIBarButtonItem(title: "Read all", style: UIBarButtonItemStyle.plain, target: self, action: #selector(clearAllPressed))
//        navigationItem.leftBarButtonItem = clearAll
//
//        NotificationCenter.default.addObserver(self, selector: #selector(fetchNotifications), name: NSNotification.Name(rawValue: "newNotification"), object: nil)
//    }
//
//    deinit {
//        fetchController.tableView = nil
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        tableView.isUserInteractionEnabled = true
//    }
//
//    @objc func fetchNotifications() {
//        guard let currentUser = User.currentUser() else {
//            return
//        }
//
//        let query = Notification.query()!
//        query.includeKey("lastTriggeredBy")
//        query.includeKey("triggeredBy")
//        query.includeKey("subscribers")
//        query.includeKey("owner")
//        query.includeKey("readBy")
//        query.whereKey("subscribers", containedIn: [currentUser])
//        query.orderByDescending("lastUpdatedAt")
//        fetchController.configureWith(self, query: query, queryDelegate:self, tableView: tableView, limit: 50)
//    }
//
//    @objc func clearAllPressed(sender: AnyObject) {
//        let unreadNotifications = fetchController.dataSource.filter { (notification: PFObject) -> Bool in
//
//            let notification = notification as! Notification
//            guard !notification.readBy.contains(User.currentUser()!) else {
//                return false
//            }
//
//            notification.addUniqueObject(User.currentUser()!, forKey: "readBy")
//            return true
//        }
//
//        if unreadNotifications.count != 0 {
//            PFObject.saveAllInBackground(unreadNotifications)
//            tableView.reloadData()
//        }
//
//        delegate?.notificationsViewControllerClearedAllNotifications()
//    }
//
//    func updateUnreadNotifications() {
//        guard let currentUser = User.currentUser() else {
//            return
//        }
//
//        var unreadNotifications = 0
//        for index in 0..<fetchController.dataCount() {
//            guard let notification = fetchController.objectAtIndex(index) as? Notification else {
//                continue
//            }
//            if !notification.readBy.contains(currentUser) {
//                unreadNotifications += 1
//            }
//        }
//
//        delegate?.notificationsViewControllerHasUnreadNotifications(count: unreadNotifications)
//    }
//
//
//    @IBAction func searchPressed(sender: AnyObject) {
//        if let tabBar = tabBarController {
//            tabBar.present(SearchViewController(coder: .AllAnime), animated: true)
//        }
//    }
//}
//
//extension NotificationsViewController: UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return fetchController.dataCount()
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let notification = fetchController.objectAtIndex(indexPath.row) as! Notification
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as! BasicTableCell
//
//        if notification.lastTriggeredBy.isTheCurrentUser() {
//            var selectedUser = notification.lastTriggeredBy
//            for user in notification.triggeredBy where !user.isTheCurrentUser() {
//                selectedUser = user
//                break
//            }
//            if let avatarThumb = selectedUser.avatarThumb {
//                cell.titleimageView.setImageWithPFFile(avatarThumb)
//            }
//
//        } else {
//            if let avatarThumb = notification.lastTriggeredBy.avatarThumb {
//                cell.titleimageView.setImageWithPFFile(avatarThumb)
//            }
//        }
//
//        if notification.owner.isTheCurrentUser() {
//            cell.titleLabel.text = notification.messageOwner
//        } else if notification.lastTriggeredBy.isTheCurrentUser() {
//            cell.titleLabel.text = notification.previousMessage ?? notification.message
//        } else {
//            cell.titleLabel.text = notification.message
//        }
//
//        if notification.readBy.contains(User.currentUser()!) {
//            cell.contentView.backgroundColor = UIColor.backgroundWhite()
//        } else {
//            cell.contentView.backgroundColor = UIColor.backgroundDarker()
//        }
//
//        cell.subtitleLabel.text = (notification.lastUpdatedAt ?? notification.updatedAt!).timeAgo()
//        cell.layoutIfNeeded()
//        return cell
//    }
//}
//
//extension NotificationsViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Open
//        let notification = fetchController.objectAtIndex(indexPath.row) as! Notification
//
//        if !notification.readBy.contains(User.currentUser()!) {
//            // The actual save of this change happens on `handleNotification`
//            notification.addUniqueObject(User.currentUser()!, forKey: "readBy")
//            tableView.reloadData()
//        }
//
//        // Prevents opening the notification twice
//        tableView.isUserInteractionEnabled = false
//        NotificationsController
//            .handleNotification(notification.objectId!, objectClass: notification.targetClass, objectId: notification.targetID, returnAnimator: true)
//            .continueWithBlock { (task: BFTask!) -> AnyObject? in
//
//                if let animator = task.result as? ZFModalTransitionAnimator {
//                    self.animator = animator
//                }
//                return nil
//        }
//
//        updateUnreadNotifications()
//    }
//}
//
//extension NotificationsViewController: FetchControllerQueryDelegate {
//    func queriesForSkip(skip: Int) -> [PFQuery]? {
//        return nil
//    }
//    func processResult(result: [PFObject], dataSource: [PFObject]) -> [PFObject] {
//        let filtered = result.filter({ (object: PFObject) -> Bool in
//            let notification = object as! Notification
//            return notification.triggeredBy.count > 1 || (notification.triggeredBy.count == 1 && !notification.triggeredBy.last!.isTheCurrentUser())
//        })
//        return filtered
//    }
//}
//
//extension NotificationsViewController: FetchControllerDelegate {
//    func didFetchFor(skip: Int) {
//        updateUnreadNotifications()
//        tableView?.reloadData()
//    }
}
