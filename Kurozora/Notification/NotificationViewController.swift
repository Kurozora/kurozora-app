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
import SwiftTheme

protocol NotificationsViewControllerDelegate: class {
    func notificationsViewControllerHasUnreadNotifications(count: Int)
    func notificationsViewControllerClearedAllNotifications()
}

class NotificationsViewController: UITableViewController, EmptyDataSetDelegate, EmptyDataSetSource {
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
			searchController.viewController = self
		}

		// Refresh controller
		refreshControl?.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your notifications!", attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.tintColor.stringValue) ?? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
		refreshControl?.addTarget(self, action: #selector(refreshNotificationsData(_:)), for: .valueChanged)

		// Setup table view
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
	/**
		Refresh the notification data by fetching new notifications from the server.

		- Parameter sender: The object requesting the refresh.
	*/
	@objc private func refreshNotificationsData(_ sender: Any) {
		// Fetch library data
		refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing notifications list...", attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.tintColor.stringValue) ?? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
		fetchNotifications()
	}

	/**
		Fetch the notifications for the current user.
	*/
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
				self.refreshControl?.endRefreshing()
				self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your notifications list!", attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.color(for: KThemePicker.tintColor.stringValue) ?? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1)])
			}
		})
	}

	/**
		Group the fetched notifications according to the user's notification preferences.

		- Parameter userNotificationsElement: The array of the fetched notifications.
	*/
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

	/**
		Update the read/unread status for the given notification id.

		- Parameter indexPath: The IndexPath of the notifications in the tableView.
		- Parameter notificationID: The id of the notification to be updated. Accepts array of id’s or all.
		- Parameter status: The integer indicating whether to mark the notification as read or unread.
	*/
	func updateNotification(at indexPaths: [IndexPath], for notificationID: String, with status: Int) {
		Service.shared.updateNotification(for: notificationID, withStatus: status) { (read) in
			for indexPath in indexPaths {
				if notificationID == "all" {
					self.userNotificationsElement?[indexPath.row].read = read
				} else {
					switch self.grouping {
					case .automatic, .byType:
						self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].read = read
					case .off:
						self.userNotificationsElement?[indexPath.row].read = read
					}
				}

				if indexPaths.count == 1, let indexPath = indexPaths.first {
					if let sessionNotificationCell = self.tableView.cellForRow(at: indexPath) as? SessionNotificationCell {
						sessionNotificationCell.updateReadStatus(animated: true)
					}
				} else {
					if let sessionNotificationCell = self.tableView.cellForRow(at: indexPath) as? SessionNotificationCell {
						sessionNotificationCell.updateReadStatus(animated: false)
					}
				}
			}
		}
	}

	// MARK: - IBActions
	/**
		Show options for editing notifications in batch.

		- Parameter sender: The object containing a reference to the button that initiated this action.
	*/
	@IBAction func moreOptionsButtonPressed(_ sender: UIBarButtonItem) {
		var status = 0
		var indexPaths = [IndexPath]()

		let numberOfRows = tableView.numberOfRows()
		for row in 0..<numberOfRows {
			if let read = userNotificationsElement?[row].read, !read && status == 0 {
				status = 1
			}
			indexPaths.append(IndexPath(row: row, section: 0))
		}

		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let markActionTitle = (status == 0) ? "Mark All as Unread" : "Mark All as Read"

		// Mark action
		let markAction = UIAlertAction.init(title: markActionTitle, style: .default, handler: { (_) in
			self.updateNotification(at: indexPaths, for: "all", with: status)
		})
		markAction.setValue(#imageLiteral(resourceName: "check_circle"), forKey: "image")
		markAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		action.addAction(markAction)

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
		action.view.theme_tintColor = KThemePicker.tintColor.rawValue

		// Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		if !(navigationController?.visibleViewController?.isKind(of: UIAlertController.self))! {
			present(action, animated: true, completion: nil)
		}
	}

	/**
		Update notifications status withtin a specific section.

		- Parameter sender: The object containing a reference to the button that initiated this action.
	*/
	@objc func notificationMarkButtonPressed(_ sender: UIButton) {
		let section = sender.tag
		let numberOfRows = tableView.numberOfRows(inSection: section)
		var status = 0

		// Iterate over all the rows of a section
		var notificationIDs = ""
		var indexPaths = [IndexPath]()
		for row in 0..<numberOfRows {
			switch self.grouping {
			case .automatic, .byType:
				if let read = groupedNotifications[section].sectionNotifications[row].read, !read && status == 0 {
					status = 1
				}
				if row == groupedNotifications[section].sectionNotifications.count - 1 {
					if let notificationID = groupedNotifications[section].sectionNotifications[row].id {
						notificationIDs += ("\(notificationID)")
					}
				} else if let notificationID = groupedNotifications[section].sectionNotifications[row].id {
					notificationIDs += ("\(notificationID), ")
				}
			case .off:
				if let notificationStatus = userNotificationsElement?[row].read, notificationStatus {
					status = 0
				}
				if let userNotificationsElementCount = userNotificationsElement?.count, row == userNotificationsElementCount - 1 {
					if let notificationID = userNotificationsElement?[row].id {
						notificationIDs += ("\(notificationID)")
					}
				} else if let notificationID = userNotificationsElement?[row].id {
					notificationIDs += ("\(notificationID), ")
				}
			}

			indexPaths.append(IndexPath(row: row, section: section))
		}

		updateNotification(at: indexPaths, for: notificationIDs, with: status)
	}
}

// MARK: - UITableViewDataSource
extension NotificationsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		switch self.grouping {
		case .automatic, .byType:
			return groupedNotifications.count
		case .off:
			return 1
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch self.grouping {
		case .automatic, .byType:
			return groupedNotifications[section].sectionTitle
		case .off: break
		}

		return nil
	}

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let notificationTitleCell = self.tableView.dequeueReusableCell(withIdentifier: "NotificationTitleCell") as! NotificationTitleCell
		notificationTitleCell.notificationMarkButton.tag = section
		notificationTitleCell.notificationMarkButton.addTarget(self, action: #selector(notificationMarkButtonPressed(_:)), for: .touchUpInside)

		switch self.grouping {
		case .automatic, .byType:
			notificationTitleCell.notificationTitleLabel.text = groupedNotifications[section].sectionTitle
			return notificationTitleCell.contentView
		case .off: break
		}

		return nil
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.grouping {
		case .automatic, .byType:
			return groupedNotifications[section].sectionNotifications.count
		case .off:
			return userNotificationsElement?.count ?? 0
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
					sessionNotificationCell.notificationsElement = notifications
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
					sessionNotificationCell.notificationsElement = notifications
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
extension NotificationsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.cellForRow(at: indexPath) as? SessionNotificationCell != nil {
			// Change notification status to read
			var notificationID = 0
			switch self.grouping {
			case .automatic, .byType:
				if let id = self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].id {
					notificationID = id
				}
			case .off:
				if let id = self.userNotificationsElement?[indexPath.row].id {
					notificationID = id
				}
			}

			self.updateNotification(at: [indexPath], for: "\(notificationID)", with: 1)

			// Show sessions view
			WorkflowController.showSessions()
		}
	}
}

// MARK: - SwipeTableViewCellDelegate
extension NotificationsViewController: SwipeTableViewCellDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		switch orientation {
		case .right:
			let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
				switch self.grouping {
				case .automatic, .byType:
					let notificationID = self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].id
					Service.shared.deleteNotification(with: notificationID, withSuccess: { (success) in
						DispatchQueue.main.async {
							if success {
								self.groupedNotifications[indexPath.section].sectionNotifications.remove(at: indexPath.row)
								tableView.deleteRows(at: [indexPath], with: .left)

								if self.groupedNotifications[indexPath.section].sectionNotifications.count == 0 {
									self.groupedNotifications.remove(at: indexPath.section)
									tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section), with: .left)
								}
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
		case .left:
			var isRead = false
			switch self.grouping {
			case .automatic, .byType:
				if let read = self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].read {
					isRead = read
				}
			case .off:
				if let read = self.userNotificationsElement?[indexPath.row].read {
					isRead = read
				}
			}

			let markedAction = SwipeAction(style: .default, title: "") { action, indexPath in
				var notificationID = 0

				switch self.grouping {
				case .automatic, .byType:
					if let id = self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].id {
						notificationID = id
					}
				case .off:
					if let id = self.userNotificationsElement?[indexPath.row].id {
						notificationID = id
					}
				}

				self.updateNotification(at: [indexPath], for: "\(notificationID)", with: isRead ? 0 : 1)
			}
			markedAction.backgroundColor = .clear
			markedAction.title = isRead ? "Mark as Unread" : "Mark as Read"
			markedAction.image = isRead ? #imageLiteral(resourceName: "watched_circle") : #imageLiteral(resourceName: "unwatched_circle")
			markedAction.textColor = isRead ? #colorLiteral(red: 1, green: 0.5764705882, blue: 0, alpha: 1) : #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
			markedAction.font = .systemFont(ofSize: 16, weight: .semibold)
			markedAction.transitionDelegate = ScaleTransition.default
			return [markedAction]
		}
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

		switch orientation {
		case .right:
			options.expansionStyle = .destructive(automaticallyDelete: false)
		case .left:
			options.expansionStyle = .selection
		}

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
