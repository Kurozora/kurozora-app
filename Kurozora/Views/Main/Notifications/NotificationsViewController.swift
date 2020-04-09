//
//  NotificationsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SwiftyJSON
import SCLAlertView
import SwipeCellKit
import SwiftTheme

protocol NotificationsViewControllerDelegate: class {
    func notificationsViewControllerHasUnreadNotifications(count: Int)
    func notificationsViewControllerClearedAllNotifications()
}

class NotificationsViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var markAllButton: UIBarButtonItem!

	// MARK: - Properties
	var kSearchController: KSearchController = KSearchController()
	var grouping: KNotification.GroupStyle = KNotification.GroupStyle(rawValue: UserSettings.notificationsGrouping) ?? .automatic
	var oldGrouping: Int? = nil
	var userNotificationsElement: [UserNotificationsElement]? {
		didSet {
			self.groupNotifications(userNotificationsElement)

			_prefersActivityIndicatorHidden = true

			self.tableView.reloadData {
				self.refreshControl?.endRefreshing()
				self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your notifications list!", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue])
			}
		}
	} // Grouping type: Off
	var groupedNotifications = [GroupedNotifications]() // Grouping type: Automatic, ByType

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if oldGrouping == nil || oldGrouping != UserSettings.notificationsGrouping, User.isSignedIn {
			let notificationsGrouping = UserSettings.notificationsGrouping
			grouping = KNotification.GroupStyle(rawValue: notificationsGrouping)!

			DispatchQueue.global(qos: .background).async {
				self.fetchNotifications()
			}
		}
	}

	override func viewWillReload() {
		super.viewWillReload()

		enableActions()
		fetchNotifications()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if User.isSignedIn {
			oldGrouping = UserSettings.notificationsGrouping
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Unhide activity indicator if user is signed in.
		_prefersActivityIndicatorHidden = !User.isSignedIn

		// Setup search bar.
		setupSearchBar()

		// Refresh controller.
		refreshControl?.theme_tintColor = KThemePicker.tintColor.rawValue
		refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your notifications!", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue])
		refreshControl?.addTarget(self, action: #selector(fetchNotifications), for: .valueChanged)
		enableActions()
	}

	// MARK: - Functions
	/// Sets up the search bar.
	fileprivate func setupSearchBar() {
		// Configure search bar
		kSearchController.searchScope = .user
		kSearchController.viewController = self

		// Add search bar to navigation controller
		navigationItem.searchController = kSearchController
	}

	override func setupEmptyDataSetView() {
		tableView.emptyDataSetView { (view) in
			let detailLabelString = User.isSignedIn ? "When you have notifications, you will see them here!" : "Notifications is only available to registered Kurozora users."
			view.titleLabelString(NSAttributedString(string: "No Notifications", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .medium), .foregroundColor: KThemePicker.textColor.colorValue]))
				.detailLabelString(NSAttributedString(string: detailLabelString, attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.subTextColor.colorValue]))
				.image(R.image.empty.notifications())
				.imageTintColor(KThemePicker.textColor.colorValue)
				.verticalOffset(-60)
				.verticalSpace(5)

			if !User.isSignedIn {
				view.buttonTitle(NSAttributedString(string: "Sign In", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.tintColor.colorValue]), for: .normal)
					.buttonTitle(NSAttributedString(string: "Sign In", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: KThemePicker.tintColor.colorValue.darken()]), for: .highlighted)
					.didTapDataButton {
						if let signInTableViewController = R.storyboard.onboarding.signInTableViewController() {
							let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
							self.present(kNavigationController)
						}
				}
			}
		}
	}

	/// Enables and disables actions such as buttons and the refresh control according to the user sign in state.
	private func enableActions() {
		markAllButton.isEnabled = User.isSignedIn
		markAllButton.title = User.isSignedIn ? "Mark all" : ""
		refreshControl?.isEnabled = User.isSignedIn
	}

	/// Fetch the notifications for the current user.
	@objc func fetchNotifications() {
		if User.isSignedIn {
			DispatchQueue.main.async {
				self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing notifications list...", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue])
			}

			guard let userID = User().current?.id else { return }
			KService.getNotifications(forUserID: userID, withSuccess: { (notifications) in
				self.userNotificationsElement = []
				DispatchQueue.main.async {
					self.userNotificationsElement = notifications
				}
			})
		} else {
			self.userNotificationsElement = nil
			self.groupedNotifications = []
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
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
				guard let creationDate = userNotificationsElement.creationDate else { return }
				let timeKey = creationDate.groupTime

				result[timeKey, default: []].append(userNotificationsElement)
			})

			// Append the grouped elements to the grouped notifications array
			guard let groupedNotificationsArray = groupedNotifications else { return }
			for (key, value) in groupedNotificationsArray {
				self.groupedNotifications.append(GroupedNotifications(sectionTitle: key, sectionNotifications: value))
			}

			// Reorder grouped notifiactions so the recent one is at the top (Recent, Earlier Today, Yesterday, etc.)
			self.groupedNotifications.sort(by: { $0.sectionNotifications.first?.creationDate?.toDate ?? Date() > $1.sectionNotifications.first?.creationDate?.toDate ?? Date() })
		case .byType:
			self.groupedNotifications = []

			// Group notifications by type and assign a group title as key (Sessions, Messages etc.)
			let groupedNotifications = userNotificationsElement?.reduce(into: [String: [UserNotificationsElement]](), { (result, userNotificationsElement) in
				guard let type = userNotificationsElement.type else { return }
				guard let notificationType = KNotification.CustomType(rawValue: type) else { return }
				let timeKey = notificationType.stringValue

				result[timeKey, default: []].append(userNotificationsElement)
			})

			// Append the grouped elements to the grouped notifications array
			guard let groupedNotificationsArray = groupedNotifications else { return }
			for (key, value) in groupedNotificationsArray {
				self.groupedNotifications.append(GroupedNotifications(sectionTitle: key, sectionNotifications: value))
			}

			// Reorder grouped notifiactions so the recent one is at the top (Recent, Earlier Today, Yesterday, etc.)
			self.groupedNotifications.sort(by: { $0.sectionNotifications.first?.creationDate?.toDate ?? Date() > $1.sectionNotifications.first?.creationDate?.toDate ?? Date() })
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
	func updateNotification(at indexPaths: [IndexPath]? = nil, for notificationID: String, with status: Int) {
		KService.updateNotification(notificationID, withStatus: status) { (read) in
			if indexPaths == nil {
				for userNotificationElement in self.userNotificationsElement ?? [] {
					userNotificationElement.read = read
				}
				self.tableView.reloadData()
			} else {
				for indexPath in indexPaths ?? [] {
					switch self.grouping {
					case .automatic, .byType:
						self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].read = read
					case .off:
						self.userNotificationsElement?[indexPath.row].read = read
					}

					let baseNotificationCell = self.tableView.cellForRow(at: indexPath) as? BaseNotificationCell
					baseNotificationCell?.updateReadStatus(animated: indexPaths?.count == 1)
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
		let action = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Mark all as read action
		let markAllAsRead = UIAlertAction.init(title: "Mark all as read", style: .default, handler: { (_) in
			self.updateNotification(for: "all", with: 1)
		})
		markAllAsRead.setValue(R.image.symbols.checkmark_circle_fill()!, forKey: "image")
		markAllAsRead.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		action.addAction(markAllAsRead)

		// Mark all as unread action
		let markAllAsUnread = UIAlertAction.init(title: "Mark all as unread", style: .default, handler: { (_) in
			self.updateNotification(for: "all", with: 0)
		})
		markAllAsUnread.setValue(R.image.symbols.checkmark_circle()!, forKey: "image")
		markAllAsUnread.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		action.addAction(markAllAsUnread)

		action.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		// Present the controller
		if let popoverController = action.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		if (navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(action, animated: true, completion: nil)
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
						notificationIDs += "\(notificationID)"
					}
				} else if let notificationID = groupedNotifications[section].sectionNotifications[row].id {
					notificationIDs += "\(notificationID),"
				}
			case .off:
				if let notificationStatus = userNotificationsElement?[row].read, notificationStatus {
					status = 0
				}
				if let userNotificationsElementCount = userNotificationsElement?.count, row == userNotificationsElementCount - 1 {
					if let notificationID = userNotificationsElement?[row].id {
						notificationIDs += "\(notificationID)"
					}
				} else if let notificationID = userNotificationsElement?[row].id {
					notificationIDs += "\(notificationID),"
				}
			}

			indexPaths.append(IndexPath(row: row, section: section))
		}
		sender.setTitle(status == 0 ? "Mark as read" : "Mark as unread", for: .normal)
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

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.grouping {
		case .automatic, .byType:
			return groupedNotifications[section].sectionNotifications.count
		case .off:
			return userNotificationsElement?.count ?? 0
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
		let notificationTitleCell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.notificationTitleCell.identifier) as? NotificationTitleCell
		notificationTitleCell?.notificationMarkButton.tag = section
		notificationTitleCell?.notificationMarkButton.addTarget(self, action: #selector(notificationMarkButtonPressed(_:)), for: .touchUpInside)

		switch self.grouping {
		case .automatic, .byType:
			notificationTitleCell?.notificationTitleLabel.text = groupedNotifications[section].sectionTitle
			let allNotificationsRead = groupedNotifications[section].sectionNotifications.contains(where: { $0.read ?? false })
			notificationTitleCell?.notificationMarkButton.setTitle(allNotificationsRead ? "Mark as unread" : "Marks as read", for: .normal)
			return notificationTitleCell?.contentView
		case .off: break
		}

		return nil
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Prepare necessary information for setting up the correct cell
		var notificationType: KNotification.CustomType = .other
		var notificationCellIdentifier: String = notificationType.identifierString

		let notifications = (self.grouping == .off) ? userNotificationsElement?[indexPath.row] : groupedNotifications[indexPath.section].sectionNotifications[indexPath.row]
		if let notificationsType = notifications?.type, !notificationsType.isEmpty {
			notificationType = KNotification.CustomType(rawValue: notificationsType) ?? notificationType
			notificationCellIdentifier = notificationType.identifierString
		}

		// Setup cell
		let baseNotificationCell = self.tableView.dequeueReusableCell(withIdentifier: notificationCellIdentifier, for: indexPath) as! BaseNotificationCell
		baseNotificationCell.delegate = self
		baseNotificationCell.notificationType = notificationType
		baseNotificationCell.userNotificationsElement = notifications
		return baseNotificationCell
	}
}

// MARK: - UITableViewDelegate
extension NotificationsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let baseNotificationCell = tableView.cellForRow(at: indexPath) as? BaseNotificationCell
		// Change notification status to read
		guard let notificationID = baseNotificationCell?.userNotificationsElement?.id else { return }
		self.updateNotification(at: [indexPath], for: notificationID, with: 1)

		if baseNotificationCell?.notificationType == .session {
			// Show sessions view
			WorkflowController.shared.showSessions()
		} else if baseNotificationCell?.notificationType == .follower {
			// Change notification status to read
			let userID = baseNotificationCell?.userNotificationsElement?.data?.userID
			if let profileViewController = R.storyboard.profile.profileTableViewController() {
				profileViewController.userID = userID
				profileViewController.dismissButtonIsEnabled = true

				let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController)
				self.present(kurozoraNavigationController)
			}
		}
	}
}

// MARK: - SwipeTableViewCellDelegate
extension NotificationsViewController: SwipeTableViewCellDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		switch orientation {
		case .right:
			let deleteAction = SwipeAction(style: .destructive, title: "Delete") { _, indexPath in
				switch self.grouping {
				case .automatic, .byType:
					guard let notificationID = self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].id else { return }
					KService.deleteNotification(notificationID, withSuccess: { (success) in
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
					guard let notificationID = self.userNotificationsElement?[indexPath.row].id else { return }
					KService.deleteNotification(notificationID, withSuccess: { (success) in
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
			deleteAction.image = R.image.trash_circle()!
			deleteAction.textColor = .kLightRed
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

			let markedAction = SwipeAction(style: .default, title: "") { _, indexPath in
				var notificationID = ""

				switch self.grouping {
				case .automatic, .byType:
					if let userNotificationID = self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].id {
						notificationID = userNotificationID
					}
				case .off:
					if let userNotificationID = self.userNotificationsElement?[indexPath.row].id {
						notificationID = userNotificationID
					}
				}

				self.updateNotification(at: [indexPath], for: notificationID, with: isRead ? 0 : 1)
			}
			markedAction.backgroundColor = .clear
			markedAction.title = isRead ? "Mark as Unread" : "Mark as Read"
			markedAction.image = isRead ? R.image.watched_circle()! : R.image.unwatched_circle()!
			markedAction.textColor = isRead ? .kurozora : #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
			markedAction.font = .systemFont(ofSize: 16, weight: .semibold)
			markedAction.transitionDelegate = ScaleTransition.default
			return [markedAction]
		}
	}

	func visibleRect(for tableView: UITableView) -> CGRect? {
		return tableView.safeAreaLayoutGuide.layoutFrame
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
		options.backgroundColor = .clear
		return options
	}
}