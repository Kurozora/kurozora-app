//
//  NotificationViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
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

	var searchResultsViewController: SearchResultsTableViewController!
	var grouping: GroupingType = .off
	var oldGrouping: Int?
	var userNotificationsElement: [UserNotificationsElement]? // Grouping type: Off
	var groupedNotifications = [GroupedNotifications]() // Grouping type: Automatic, ByType

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if oldGrouping == nil || oldGrouping != UserSettings.notificationsGrouping {
			let notificationsGrouping = UserSettings.notificationsGrouping
			grouping = GroupingType(rawValue: notificationsGrouping)!
			fetchNotifications()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		oldGrouping = UserSettings.notificationsGrouping
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Search bar
		let storyboard: UIStoryboard = UIStoryboard(name: "search", bundle: nil)
		searchResultsViewController = storyboard.instantiateViewController(withIdentifier: "Search") as? SearchResultsTableViewController

		if #available(iOS 11.0, *) {
			let searchController = SearchController(searchResultsController: searchResultsViewController)
			searchController.delegate = self
			searchController.searchBar.selectedScopeButtonIndex = SearchScope.user.rawValue
			searchController.searchResultsUpdater = searchResultsViewController

			let searchControllerBar = searchController.searchBar
			searchControllerBar.delegate = searchResultsViewController

			navigationItem.searchController = searchController
//			navigationItem.hidesSearchBarWhenScrolling = false
			searchController.viewController = self
		}

		// Setup table view
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension

		// Setup empty table view
		tableView.emptyDataSetSource = self
		tableView.emptyDataSetDelegate = self
		tableView.emptyDataSetView { (view) in
			view.titleLabelString(NSAttributedString(string: "No notifications to show."))
				.image(UIImage(named: "notification"))
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
				let timeKey = notificationType.stringValue

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
		let notificationTitleCell = self.tableView.dequeueReusableCell(withIdentifier: "NotificationTitleCell") as! NotificationTitleCell

		switch self.grouping {
		case .automatic, .byType:
			notificationTitleCell.notificationTitleLabel.text = groupedNotifications[section].sectionTitle
		case .off: break
		}

		return notificationTitleCell.contentView
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

			if let type = notifications.type, type != "", let notificationType = NotificationType(rawValue: type) {
				switch notificationType {
				case .session:
					return sessionNotificationCell
				case .follower:
					messageNotificationCell.notificationsElement = notifications
				default: break
				}
			}
		case .off:
			let notifications = userNotificationsElement?[indexPath.row]
			if let type = notifications?.type, type != "", let notificationType = NotificationType(rawValue: type) {
				switch notificationType {
				case .session:
					return sessionNotificationCell
				case .follower:
					messageNotificationCell.notificationsElement = notifications
				default: break
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
		deleteAction.textColor = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1)
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
		options.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)

		return options
	}
}

// MARK: - UISearchControllerDelegate
extension NotificationsViewController: UISearchControllerDelegate {
	func willPresentSearchController(_ searchController: UISearchController) {
		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height + (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.frame = tabBarFrame
			})
		}
	}

	func willDismissSearchController(_ searchController: UISearchController) {
		if var tabBarFrame = self.tabBarController?.tabBar.frame {
			tabBarFrame.origin.y = self.view.frame.size.height - (tabBarFrame.size.height)
			UIView.animate(withDuration: 0.5, animations: {
				self.tabBarController?.tabBar.frame = tabBarFrame
			})
		}
	}
}
