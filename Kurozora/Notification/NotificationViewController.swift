//
//  NotificationViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import SwiftyJSON
import SCLAlertView
import Kingfisher
import EmptyDataSet_Swift

protocol NotificationsViewControllerDelegate: class {
    func notificationsViewControllerHasUnreadNotifications(count: Int)
    func notificationsViewControllerClearedAllNotifications()
}

class NotificationsViewController: UIViewController, EmptyDataSetDelegate, EmptyDataSetSource {
    @IBOutlet var tableView: UITableView!

	var grouping: GroupingType!

	var userNotificationsElement: [UserNotificationsElement]? // Grouping type: Off
	var typedNotifications = [GroupedNotifications]() // Grouping type: By Type
	var groupedNotifications = [GroupedNotifications]() // Grouping type: Automatic

	// Notification types
	enum NotifcationType: String {
        case unknown = "TYPE_UNKNOWN"
        case session = "TYPE_NEW_SESSION"
        case follower  = "TYPE_NEW_FOLLOWER"
    }

	enum GroupingType: Int {
		case automatic = 0
		case byType
		case off
	}

	// Notification grouping
	struct GroupedNotifications {
		var sectionTitle: String!
		var sectionNotifications: [UserNotificationsElement]!
	}

	func groupNotifications(_ userNotificationsElement: [UserNotificationsElement]?) {
		// Group notifications by date and assign a group title as key (Recent, Last Week, Yesterday etc.)
		let groupedNotifications = userNotificationsElement?.reduce(into: [String: [UserNotificationsElement]](), { (result, userNotificationsElement) in
			guard let time = userNotificationsElement.creationDate else { return }
			let timeKey = Date.groupTime(by: time)

			result[timeKey, default: []].append(userNotificationsElement)
		})

		// Append the grouped elements to the grouped notifications array
		guard let groupedNotificationsArray = groupedNotifications else { return }
		for (key, value) in groupedNotificationsArray {
			self.groupedNotifications.append(GroupedNotifications(sectionTitle: key, sectionNotifications: value))
		}

		// Reorder grouped notifiactions so the recent one is at the top (Recent, Earlier Today, Yesterday, etc.)
		self.groupedNotifications.sort(by: {Date.stringToDateTime(string: $0.sectionNotifications[0].creationDate) > Date.stringToDateTime(string: $1.sectionNotifications[0].creationDate)})
	}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		let notificationsGrouping = UserDefaults.standard.integer(forKey: "notificationsGrouping")
		grouping = GroupingType(rawValue: notificationsGrouping)
		fetchNotifications(withGrouping: grouping)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		// Fetch the notifications
//		fetchNotifications()

        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 100
        
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

	// MARK: - Functions
	func fetchNotifications(withGrouping grouping: GroupingType) {
		Service.shared.getNotifications(withSuccess: { (notifications) in
			DispatchQueue.main.async() {
				self.userNotificationsElement = notifications

				switch grouping {
				case .automatic:
					self.groupNotifications(notifications)
				case .byType: break
				case .off: break
				}

				self.tableView.reloadData()
			}
		})
	}
}

// MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
}

// MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		switch grouping {
		case .automatic?:
			return groupedNotifications.count
		case .byType?:
			return groupedNotifications.count
		case .off?:
			return userNotificationsElement?.count ?? 0
		case .none:
			return 0
		}
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch grouping {
		case .automatic?:
			return groupedNotifications[section].sectionTitle
		case .byType?:
			return groupedNotifications[section].sectionTitle
		case .off?: break
		case .none: break
		}

		return ""
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let titleNotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "TitleNotificationCell") as! TitleNotificationCell

		switch grouping {
		case .automatic?:
			titleNotificationCell.notificationTitleLable.text = groupedNotifications[section].sectionTitle
		case .byType?:
			titleNotificationCell.notificationTitleLable.text = groupedNotifications[section].sectionTitle
		case .off?: break
		case .none: break
		}

		return titleNotificationCell.contentView
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch grouping {
		case .automatic?:
			return groupedNotifications[section].sectionNotifications.count
		case .byType?:
			return groupedNotifications[section].sectionNotifications.count
		case .off?:
			return userNotificationsElement?.count ?? 0
		case .none:
			return 0
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let messageNotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "MessageNotificationCell", for: indexPath) as! MessageNotificationCell
		let sessionNotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "SessionNotificationCell", for: indexPath) as! SessionNotificationCell


		switch grouping {
		case .automatic?:
			let notifications = groupedNotifications[indexPath.section].sectionNotifications[indexPath.row]

			if let creationDate = notifications.creationDate {
				messageNotificationCell.notificationDate.text = Date.timeAgo(creationDate)
				sessionNotificationCell.notificationDate.text = Date.timeAgo(creationDate)
			}

			if let description = notifications.message {
				messageNotificationCell.notificationTextLable.text = description
				sessionNotificationCell.notificationTextLable.text = description
			}

			if let notificationType = notifications.type, notificationType != "" {
				let type: NotifcationType = NotifcationType(rawValue: notificationType)!

				switch type {
				case .session:
					sessionNotificationCell.notificationType.text = "NEW SESSION"
					sessionNotificationCell.notificationIcon.image = #imageLiteral(resourceName: "session_icon")

					return sessionNotificationCell
				case .follower:
					messageNotificationCell.notificationType.text = "NEW MESSAGE"
					messageNotificationCell.notificationIcon.image = #imageLiteral(resourceName: "message_icon")
					if let title = notifications.data?.name, title != "" {
						messageNotificationCell.notificationTitleLabel.text = title
					} else {
						messageNotificationCell.notificationTitleLabel.text = ""

					}

					if let avatar = notifications.data?.avatar, avatar != "" {
						let avatarUrl = URL(string: avatar)
						let resource = ImageResource(downloadURL: avatarUrl!)
						messageNotificationCell.notificationProfileImage.kf.setImage(with: resource, placeholder: UIImage(named: ""), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
					} else {
						messageNotificationCell.notificationProfileImage.image = #imageLiteral(resourceName: "default_avatar")
					}
				default:
					break
				}
			}
		case .byType?:
			break
		case .off?:
			let notifications = userNotificationsElement?[indexPath.row]

			if let creationDate = notifications?.creationDate {
				messageNotificationCell.notificationDate.text = Date.timeAgo(creationDate)
				sessionNotificationCell.notificationDate.text = Date.timeAgo(creationDate)
			}

			if let description = notifications?.message {
				messageNotificationCell.notificationTextLable.text = description
				sessionNotificationCell.notificationTextLable.text = description
			}

			if let notificationType = notifications?.type, notificationType != "" {
				let type: NotifcationType = NotifcationType(rawValue: notificationType)!

				switch type {
				case .session:
					sessionNotificationCell.notificationType.text = "NEW SESSION"
					sessionNotificationCell.notificationIcon.image = #imageLiteral(resourceName: "session_icon")

					return sessionNotificationCell
				case .follower:
					messageNotificationCell.notificationType.text = "NEW MESSAGE"
					messageNotificationCell.notificationIcon.image = #imageLiteral(resourceName: "message_icon")
					if let title = notifications?.data?.name, title != "" {
						messageNotificationCell.notificationTitleLabel.text = title
					} else {
						messageNotificationCell.notificationTitleLabel.text = ""

					}

					if let avatar = notifications?.data?.avatar, avatar != "" {
						let avatarUrl = URL(string: avatar)
						let resource = ImageResource(downloadURL: avatarUrl!)
						messageNotificationCell.notificationProfileImage.kf.setImage(with: resource, placeholder: UIImage(named: ""), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
					} else {
						messageNotificationCell.notificationProfileImage.image = #imageLiteral(resourceName: "default_avatar")
					}
				default:
					break
				}
			}
		case .none:
			break
		}

		return messageNotificationCell
	}
}











//// MARK: - UITableViewDataSource
//extension NotificationsViewController: UITableViewDataSource {
//	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		if let notificationsCount = notifications?.count {
//			return notificationsCount
//		}
//		return 0
//	}
//
//	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//	let userNotificationCell:UserNotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "UserNotificationCell", for: indexPath as IndexPath) as! UserNotificationCell
//	let notificationCell:NotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath as IndexPath) as! NotificationCell
//
//	if let time = notifications?[indexPath.row]["time_string"].stringValue, time != "" {
//		userNotificationCell.notificationDate.text = time
//		notificationCell.notificationDate.text = time
//	} else {
//		userNotificationCell.notificationDate.text = ""
//		notificationCell.notificationDate.text = ""
//	}
//
//	if let description = notifications?[indexPath.row]["string"].stringValue, description != "" {
//		userNotificationCell.notificationTextLable.text = description
//		notificationCell.notificationTextLable.text = description
//	} else {
//		userNotificationCell.notificationTextLable.text = ""
//		notificationCell.notificationTextLable.text = ""
//	}
//
//	if let notificationType = notifications?[indexPath.row]["type"].stringValue, notificationType != "" {
//		let type: NotifcationType = NotifcationType(rawValue: notificationType)!
//
//		switch type {
//		case .session:
//			notificationCell.notificationType.text = "NEW SESSION"
//			notificationCell.notificationIcon.image = UIImage(named: "session_icon")
//
//			return notificationCell
//		case .follower:
//			userNotificationCell.notificationType.text = "NEW MESSAGE"
//			userNotificationCell.notificationIcon.image = UIImage(named: "message_icon")
//			if let title = notifications?[indexPath.row]["data"]["follower_name"].stringValue, title != "" {
//				userNotificationCell.notificationTitleLabel.text = title
//			} else {
//				userNotificationCell.notificationTitleLabel.text = ""
//
//			}
//
//			if let avatar = notifications?[indexPath.row]["data"]["follower_avatar"].stringValue, avatar != "" {
//				let avatarUrl = URL(string: avatar)
//				let resource = ImageResource(downloadURL: avatarUrl!)
//				userNotificationCell.notificationProfileImage.kf.setImage(with: resource, placeholder: UIImage(named: ""), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
//			} else {
//				userNotificationCell.notificationProfileImage.image = UIImage(named: "")
//			}
//		default:
//			break
//		}
//	}
//
//	return userNotificationCell
//	}
//}
