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
    @IBOutlet var tableView: UITableView!
    
    var notifications:[JSON]?
    enum notifcationType:String {
        case TYPE_UNKNOWN
        case TYPE_NEW_SESSION
        case TYPE_NEW_FOLLOWER
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

		Service.shared.getNotifications(withSuccess: { (notifications) in
			if let notifications = notifications {
				self.notifications = notifications
				//                self.updateCurrentSession(with: session)
			}

			DispatchQueue.main.async() {
				self.tableView.reloadData()
			}
		})
        
        // Setup table view
        tableView.rowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
        
        // Setup empty table view
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetView { (view) in
            view.titleLabelString(NSAttributedString(string: "No notifications to show."))
                .image(UIImage(named: "notification_icon"))
                .shouldDisplay(true)
                .shouldFadeIn(true)
                .isTouchAllowed(true)
                .isScrollAllowed(true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let notificationsCount = notifications?.count {
            return notificationsCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userNotificationCell:UserNotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "UserNotificationCell", for: indexPath as IndexPath) as! UserNotificationCell
        let notificationCell:NotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath as IndexPath) as! NotificationCell
        
        if let time = notifications?[indexPath.row]["time_string"].stringValue, time != "" {
            userNotificationCell.notificationDate.text = time
            notificationCell.notificationDate.text = time
        } else {
            userNotificationCell.notificationDate.text = ""
            notificationCell.notificationDate.text = ""
        }
        
        if let description = notifications?[indexPath.row]["string"].stringValue, description != "" {
            userNotificationCell.notificationTextLable.text = description
            notificationCell.notificationTextLable.text = description
        } else {
            userNotificationCell.notificationTextLable.text = ""
            notificationCell.notificationTextLable.text = ""
        }
        
        if let notificationType = notifications?[indexPath.row]["type"].stringValue, notificationType != "" {
            let type: notifcationType = notifcationType(rawValue: notificationType)!
            
            switch type {
            case .TYPE_NEW_SESSION:
                notificationCell.notificationType.text = "NEW SESSION"
                notificationCell.notificationIcon.image = UIImage(named: "session_icon")
                
                return notificationCell
            case .TYPE_NEW_FOLLOWER:
                userNotificationCell.notificationType.text = "NEW MESSAGE"
                userNotificationCell.notificationIcon.image = UIImage(named: "message_icon")
                if let title = notifications?[indexPath.row]["data"]["follower_name"].stringValue, title != "" {
                    userNotificationCell.notificationTitleLabel.text = title
                } else {
                    userNotificationCell.notificationTitleLabel.text = ""
                    
                }
                
                if let avatar = notifications?[indexPath.row]["data"]["follower_avatar"].stringValue, avatar != "" {
                    let avatarUrl = URL(string: avatar)
                    let resource = ImageResource(downloadURL: avatarUrl!)
                    userNotificationCell.notificationProfileImage.kf.setImage(with: resource, placeholder: UIImage(named: ""), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
                } else {
                    userNotificationCell.notificationProfileImage.image = UIImage(named: "")
                }
            default:
                break
            }
        }
        
        return userNotificationCell
    }
}
