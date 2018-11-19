//
//  NotificationViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import KDatabaseKit
import SwiftyJSON
import SCLAlertView
import Kingfisher
import EmptyDataSet_Swift

protocol NotificationsViewControllerDelegate: class {
    func notificationsViewControllerHasUnreadNotifications(count: Int)
    func notificationsViewControllerClearedAllNotifications()
}

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, EmptyDataSetDelegate, EmptyDataSetSource {
    @IBOutlet weak var tableView: UITableView!
    
    var notifications:[JSON]?
    enum notifcationType:String {
        case TYPE_UNKNOWN
        case TYPE_NEW_SESSION
        case TYPE_NEW_FOLLOWER
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Service.shared.getNotifications(withSuccess: { (notifications) in
            if let notifications = notifications {
                self.notifications = notifications
//                self.updateCurrentSession(with: session)
            }
            
            DispatchQueue.main.async() {
                self.tableView.reloadData()
            }
        }) { (errorMessage) in
            SCLAlertView().showError("Error getting notifiactions", subTitle: errorMessage)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup table view
        tableView.rowHeight = 94
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setup empty table view
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "No notifications to show."))
                .image(UIImage(named: "notification_icon"))
                .shouldDisplay(true)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(true)
        }
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let notificationsCount = notifications?.count {
            return notificationsCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationCell:NotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath as IndexPath) as! NotificationCell
        
        if let notificationType = notifications?[indexPath.row]["type"].stringValue, notificationType != "" {
            let type: notifcationType = notifcationType(rawValue: notificationType)!
            
            switch type {
            case .TYPE_NEW_SESSION:
                notificationCell.notificationType.text = "NEW SESSION"
                notificationCell.notificationIcon.image = UIImage(named: "session_icon")
                notificationCell.notificationTitleLabel.isHidden = true
                notificationCell.notificationProfileImage.isHidden = true
            case .TYPE_NEW_FOLLOWER:
                notificationCell.notificationType.text = "NEW MESSAGE"
                notificationCell.notificationIcon.image = UIImage(named: "message_icon")
                if let title = notifications?[indexPath.row]["data"]["follower_name"].stringValue, title != "" {
                    notificationCell.notificationTitleLabel.text = title
                } else {
                    notificationCell.notificationTitleLabel.text = ""
                    
                }
                
                if let avatar = notifications?[indexPath.row]["data"]["follower_avatar"].stringValue, avatar != "" {
                    let avatarUrl = URL(string: avatar)
                    let resource = ImageResource(downloadURL: avatarUrl!)
                    notificationCell.notificationProfileImage.kf.setImage(with: resource, placeholder: UIImage(named: ""), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                } else {
                    notificationCell.notificationProfileImage.image = UIImage(named: "")
                }
            default:
                break
            }
        }
        
        if let time = notifications?[indexPath.row]["time_string"].stringValue, time != "" {
            notificationCell.notificationDate.text = time
        } else {
           notificationCell.notificationDate.text = ""
        }
        
        if let description = notifications?[indexPath.row]["string"].stringValue, description != "" {
            notificationCell.notificationTextLable.text = description
        } else {
            notificationCell.notificationTextLable.text = ""
            
        }
        
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
