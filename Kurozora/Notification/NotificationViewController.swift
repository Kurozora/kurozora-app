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
import SwipeCellKit

protocol NotificationsViewControllerDelegate: class {
    func notificationsViewControllerHasUnreadNotifications(count: Int)
    func notificationsViewControllerClearedAllNotifications()
}

class NotificationsViewController: UIViewController, EmptyDataSetDelegate, EmptyDataSetSource {
    @IBOutlet var tableView: UITableView!

	var grouping: GroupingType = .off
	var oldGrouping: Int?

	var userNotificationsElement: [UserNotificationsElement]? // Grouping type: Off
	var groupedNotifications = [GroupedNotifications]() // Grouping type: Automatic, ByType

	// Notification types
	enum NotificationType: String {
        case unknown = "TYPE_UNKNOWN"
        case session = "TYPE_NEW_SESSION"
        case follower = "TYPE_NEW_FOLLOWER"
    }

	// Notification group types
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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if oldGrouping == nil || oldGrouping != UserSettings.notificationsGrouping() {
			let notificationsGrouping = UserSettings.notificationsGrouping()
			grouping = GroupingType(rawValue: notificationsGrouping)!
			fetchNotifications()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		oldGrouping = UserSettings.notificationsGrouping()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
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

	func fetchNotifications() {
		Service.shared.getNotifications(withSuccess: { (notifications) in
			self.userNotificationsElement = []
			DispatchQueue.main.async() {
				self.userNotificationsElement = notifications

				switch self.grouping {
				case .automatic, .byType:
					self.groupNotifications(notifications)
				case .off: break
				}

				self.tableView.reloadData()
			}
		})
	}

	func groupNotificationsElement(by type: NotificationType) -> String {
		var typeString = ""
		// Name of week day
		switch type {
		case .follower:
			typeString = "Messages"
		case .session:
			typeString = "Sessions"
		case .unknown: break
		}

		return typeString
	}

	func groupNotifications(_ userNotificationsElement: [UserNotificationsElement]?) {
		switch self.grouping {
		case .automatic:
			// Group notifications by date and assign a group title as key (Recent, Last Week, Yesterday etc.)
			self.groupedNotifications = []
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
		case .byType:
			self.groupedNotifications = []
			// Group notifications by type and assign a group title as key (Sessions, Messages etc.)
			let groupedNotifications = userNotificationsElement?.reduce(into: [String: [UserNotificationsElement]](), { (result, userNotificationsElement) in
				guard let type = userNotificationsElement.type else { return }
				guard let notificationType = NotificationType(rawValue: type) else { return }
				let timeKey = groupNotificationsElement(by: notificationType)

				result[timeKey, default: []].append(userNotificationsElement)
			})

			// Append the grouped elements to the grouped notifications array
			guard let groupedNotificationsArray = groupedNotifications else { return }
			for (key, value) in groupedNotificationsArray {
				self.groupedNotifications.append(GroupedNotifications(sectionTitle: key, sectionNotifications: value))
			}

			// Reorder grouped notifiactions so the recent one is at the top (Recent, Earlier Today, Yesterday, etc.)
			self.groupedNotifications.sort(by: {Date.stringToDateTime(string: $0.sectionNotifications[0].creationDate) > Date.stringToDateTime(string: $1.sectionNotifications[0].creationDate)})
		case .off:
			self.groupedNotifications = []
		}
	}
}

// MARK: - UITableViewDataSource
extension NotificationsViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		switch self.grouping {
		case .automatic, .byType:
			return groupedNotifications.count
		case .off:
			return 1
		}
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch self.grouping {
		case .automatic, .byType:
			return groupedNotifications[section].sectionTitle
		case .off: break
		}

		return ""
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let titleNotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "TitleNotificationCell") as! TitleNotificationCell

		switch self.grouping {
		case .automatic, .byType:
			titleNotificationCell.notificationTitleLable.text = groupedNotifications[section].sectionTitle
		case .off: break
		}

		return titleNotificationCell.contentView
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.grouping {
		case .automatic, .byType:
			return groupedNotifications[section].sectionNotifications.count
		case .off:
			return userNotificationsElement?.count ?? 0
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let messageNotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "MessageNotificationCell", for: indexPath) as! MessageNotificationCell
		let sessionNotificationCell = self.tableView.dequeueReusableCell(withIdentifier: "SessionNotificationCell", for: indexPath) as! SessionNotificationCell

		messageNotificationCell.delegate = self
		sessionNotificationCell.delegate = self

		switch self.grouping {
		case .automatic, .byType:
			let notifications = groupedNotifications[indexPath.section].sectionNotifications[indexPath.row]

			if let creationDate = notifications.creationDate {
				messageNotificationCell.notificationDate.text = Date.timeAgo(creationDate)
				sessionNotificationCell.notificationDate.text = Date.timeAgo(creationDate)
			}

			if let description = notifications.message {
				messageNotificationCell.notificationTextLable.text = description
				sessionNotificationCell.notificationTextLable.text = description
			}

			if let type = notifications.type, type != "", let notificationType = NotificationType(rawValue: type) {
				switch notificationType {
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
						messageNotificationCell.notificationProfileImage.kf.setImage(with: resource, placeholder: UIImage(named: ""), options: [.transition(.fade(0.2))])
					} else {
						messageNotificationCell.notificationProfileImage.image = #imageLiteral(resourceName: "default_avatar")
					}
				default:
					break
				}
			}
		case .off:
			let notifications = userNotificationsElement?[indexPath.row]

			if let creationDate = notifications?.creationDate {
				messageNotificationCell.notificationDate.text = Date.timeAgo(creationDate)
				sessionNotificationCell.notificationDate.text = Date.timeAgo(creationDate)
			}

			if let description = notifications?.message {
				messageNotificationCell.notificationTextLable.text = description
				sessionNotificationCell.notificationTextLable.text = description
			}

			if let type = notifications?.type, type != "", let notificationType = NotificationType(rawValue: type) {
				switch notificationType {
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
						messageNotificationCell.notificationProfileImage.kf.setImage(with: resource, placeholder: UIImage(named: ""), options: [.transition(.fade(0.2))])
					} else {
						messageNotificationCell.notificationProfileImage.image = #imageLiteral(resourceName: "default_avatar")
					}
				default:
					break
				}
			}
		}
		return messageNotificationCell
	}
}

// MARK: - UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate {
}

// MARK: - SwipeTableViewCellDelegate
extension NotificationsViewController: SwipeTableViewCellDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		guard orientation == .right else { return nil }

		let deleteAction = SwipeAction(style: .default, title: "Delete") { action, indexPath in
			switch self.grouping {
			case .automatic, .byType:
				let notificationID = self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].id
				Service.shared.deleteNotification(with: notificationID, withSuccess: { (success) in
					DispatchQueue.main.async {
						if success {
							self.groupedNotifications[indexPath.section].sectionNotifications.remove(at: indexPath.row)
							tableView.beginUpdates()
							tableView.deleteRows(at: [indexPath], with: .left)
							tableView.endUpdates()
						}
					}
				})
			case .off:
				let notificationID = self.userNotificationsElement?[indexPath.row].id
				Service.shared.deleteNotification(with: notificationID, withSuccess: { (success) in
					if success {
						self.userNotificationsElement?.remove(at: indexPath.row)
						tableView.beginUpdates()
						tableView.deleteRows(at: [indexPath], with: .left)
						tableView.endUpdates()
					}
				})
			}
		}

		deleteAction.backgroundColor = .clear
		deleteAction.image = #imageLiteral(resourceName: "trash_circle")
		deleteAction.textColor = #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
		deleteAction.font = .systemFont(ofSize: 13)
		deleteAction.transitionDelegate = ScaleTransition.default

		return [deleteAction]
	}

	func visibleRect(for tableView: UITableView) -> CGRect? {
		if #available(iOS 11.0, *) {
			return tableView.safeAreaLayoutGuide.layoutFrame
		} else {
			let topInset = navigationController?.navigationBar.frame.height ?? 0
			let bottomInset = navigationController?.toolbar?.frame.height ?? 0
			let bounds = tableView.bounds

			return CGRect(x: bounds.origin.x, y: bounds.origin.y + topInset, width: bounds.width, height: bounds.height - bottomInset)
		}
	}

	func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
		var options = SwipeOptions()
		options.expansionStyle = .destructive(automaticallyDelete: false)
		options.transitionStyle = .reveal
		options.expansionDelegate = ScaleAndAlphaExpansion.default

		options.buttonSpacing = 4
		options.backgroundColor = #colorLiteral(red: 0.2705882353, green: 0.3098039216, blue: 0.3882352941, alpha: 1)

		return options
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
//				userNotificationCell.notificationProfileImage.kf.setImage(with: resource, placeholder: UIImage(named: ""), options: [.transition(.fade(0.2))])
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
