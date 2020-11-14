//
//  NotificationsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SwipeCellKit

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
	var userNotifications: [UserNotification] = [] {
		didSet {
			self.groupNotifications(userNotifications)

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
		tableView.emptyDataSetView { [weak self] (view) in
			guard let self = self else { return }

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
							self.present(kNavigationController, animated: true)
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

			KService.getNotifications { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let notifications):
					self.userNotifications = notifications
				case .failure: break
				}
			}
		} else {
			self.userNotifications = []
			self.groupedNotifications = []
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}

	/**
		Group the fetched notifications according to the user's notification preferences.

		- Parameter userNotifications: The array of the fetched notifications.
	*/
	func groupNotifications(_ userNotifications: [UserNotification]) {
		switch self.grouping {
		case .automatic:
			self.groupedNotifications = []

			// Group notifications by date and assign a group title as key (Recent, Last Week, Yesterday etc.)
			let groupedNotifications = userNotifications.reduce(into: [String: [UserNotification]](), { (result, userNotification) in
				let creationDate = userNotification.attributes.createdAt
				let timeKey = creationDate.groupTime

				result[timeKey, default: []].append(userNotification)
			})

			// Append the grouped elements to the grouped notifications array
			let groupedNotificationsArray = groupedNotifications
			for (key, value) in groupedNotificationsArray {
				self.groupedNotifications.append(GroupedNotifications(sectionTitle: key, sectionNotifications: value))
			}

			// Reorder grouped notifiactions so the recent one is at the top (Recent, Earlier Today, Yesterday, etc.)
			self.groupedNotifications.sort(by: { $0.sectionNotifications.first?.attributes.createdAt.dateTime ?? Date() > $1.sectionNotifications.first?.attributes.createdAt.dateTime ?? Date() })
		case .byType:
			self.groupedNotifications = []

			// Group notifications by type and assign a group title as key (Sessions, Messages etc.)
			let groupedNotifications = userNotifications.reduce(into: [String: [UserNotification]](), { (result, userNotification) in
				let type = userNotification.attributes.type
				guard let notificationType = KNotification.CustomType(rawValue: type) else { return }
				let timeKey = notificationType.stringValue

				result[timeKey, default: []].append(userNotification)
			})

			// Append the grouped elements to the grouped notifications array
			let groupedNotificationsArray = groupedNotifications
			for (key, value) in groupedNotificationsArray {
				self.groupedNotifications.append(GroupedNotifications(sectionTitle: key, sectionNotifications: value))
			}

			// Reorder grouped notifiactions so the recent one is at the top (Recent, Earlier Today, Yesterday, etc.)
			self.groupedNotifications.sort(by: { $0.sectionNotifications.first?.attributes.createdAt.dateTime ?? Date() > $1.sectionNotifications.first?.attributes.createdAt.dateTime ?? Date() })
		case .off:
			self.groupedNotifications = []
		}
	}

	/**
		Update the read/unread status for the given notification id.

		- Parameter indexPath: The IndexPath of the notifications in the tableView.
		- Parameter notificationID: The id of the notification to be updated. Accepts array of id’s or all.
		- Parameter readStatus: The `ReadStatus` value indicating whether to mark the notification as read or unread.
	*/
	func updateNotification(at indexPaths: [IndexPath]? = nil, for notificationID: String, withReadStatus readStatus: ReadStatus) {
		KService.updateNotification(notificationID, withReadStatus: readStatus) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let readStatus):
				if let indexPaths = indexPaths {
					let shouldUpdateIndividually = indexPaths.count == 1
					for indexPath in indexPaths {
						switch self.grouping {
						case .automatic, .byType:
							self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].attributes.readStatus = readStatus
						case .off:
							self.userNotifications[indexPath.row].attributes.readStatus = readStatus
						}

						if shouldUpdateIndividually {
							let baseNotificationCell = self.tableView.cellForRow(at: indexPath) as? BaseNotificationCell
							baseNotificationCell?.updateReadStatus(with: readStatus, animated: true)
						}
					}

					if !shouldUpdateIndividually {
						self.tableView.reloadData()
					}
				} else {
					for index in self.userNotifications.indices {
						self.userNotifications[index].attributes.readStatus = readStatus
					}
					self.tableView.reloadData()
				}
			case .failure: break
			}
		}
	}

	// MARK: - IBActions
	/**
		Show options for editing notifications in batch.

		- Parameter sender: The object containing a reference to the button that initiated this action.
	*/
	@IBAction func moreOptionsButtonPressed(_ sender: UIBarButtonItem) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		// Mark all as read action
		let markAllAsRead = UIAlertAction.init(title: "Mark all as read", style: .default, handler: { (_) in
			self.updateNotification(for: "all", withReadStatus: .read)
		})
		markAllAsRead.setValue(R.image.symbols.checkmark_circle()!, forKey: "image")
		markAllAsRead.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		alertController.addAction(markAllAsRead)

		// Mark all as unread action
		let markAllAsUnread = UIAlertAction.init(title: "Mark all as unread", style: .default, handler: { (_) in
			self.updateNotification(for: "all", withReadStatus: .unread)
		})
		markAllAsUnread.setValue(R.image.symbols.checkmark_circle_fill()!, forKey: "image")
		markAllAsUnread.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
		alertController.addAction(markAllAsUnread)

		alertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

		// Present the controller
		if let popoverController = alertController.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		if (navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(alertController, animated: true, completion: nil)
		}
	}

	/**
		Update notifications status withtin a specific section.

		- Parameter sender: The object containing a reference to the button that initiated this action.
	*/
	@objc func notificationMarkButtonPressed(_ sender: UIButton) {
		let section = sender.tag
		let numberOfRows = tableView.numberOfRows(inSection: section)
		var readStatus: ReadStatus = .unread

		// Iterate over all the rows of a section
		var notificationIDs = ""
		var indexPaths = [IndexPath]()
		for row in 0..<numberOfRows {
			switch self.grouping {
			case .automatic, .byType:
				let notificationStatus = self.groupedNotifications[section].sectionNotifications[row].attributes.readStatus
				if notificationStatus == .unread && readStatus == .unread {
					readStatus = .read
				}

				let userNotificationsCount = self.groupedNotifications[section].sectionNotifications.count
				if row == userNotificationsCount - 1 {
					let notificationID = self.groupedNotifications[section].sectionNotifications[row].id
					notificationIDs += "\(notificationID)"
				} else {
					let notificationID = self.groupedNotifications[section].sectionNotifications[row].id
					notificationIDs += "\(notificationID),"
				}
			case .off:
				let notificationStatus = self.userNotifications[row].attributes.readStatus
				if notificationStatus == .read {
					readStatus = .unread
				}

				let userNotificationsCount = self.userNotifications.count
				if row == userNotificationsCount - 1 {
					notificationIDs += "\(self.userNotifications[row].id)"
				} else {
					notificationIDs += "\(self.userNotifications[row].id),"
				}
			}

			indexPaths.append(IndexPath(row: row, section: section))
		}
		sender.setTitle(readStatus == .unread ? "Mark as read" : "Mark as unread", for: .normal)
		updateNotification(at: indexPaths, for: notificationIDs, withReadStatus: readStatus)
	}
}

// MARK: - UITableViewDataSource
extension NotificationsViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		switch self.grouping {
		case .automatic, .byType:
			return self.groupedNotifications.count
		case .off:
			return 1
		}
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.grouping {
		case .automatic, .byType:
			return self.groupedNotifications[section].sectionNotifications.count
		case .off:
			return self.userNotifications.count
		}
	}

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch self.grouping {
		case .automatic, .byType:
			return self.groupedNotifications[section].sectionTitle
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
			let allNotificationsRead = groupedNotifications[section].sectionNotifications.contains(where: { $0.attributes.readStatus == .read })
			notificationTitleCell?.notificationMarkButton.setTitle(allNotificationsRead ? "Mark as unread" : "Mark as read", for: .normal)
			return notificationTitleCell?.contentView
		case .off: break
		}

		return nil
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// Prepare necessary information for setting up the correct cell
		var notificationType: KNotification.CustomType = .other
		var notificationCellIdentifier: String = notificationType.identifierString

		let userNotification = (self.grouping == .off) ? self.userNotifications[indexPath.row] : groupedNotifications[indexPath.section].sectionNotifications[indexPath.row]
		let notificationsType = userNotification.attributes.type
		notificationType = KNotification.CustomType(rawValue: notificationsType) ?? notificationType
		notificationCellIdentifier = notificationType.identifierString

		// Setup cell
		let baseNotificationCell = self.tableView.dequeueReusableCell(withIdentifier: notificationCellIdentifier, for: indexPath) as! BaseNotificationCell
		baseNotificationCell.delegate = self
		baseNotificationCell.notificationType = notificationType
		baseNotificationCell.userNotification = userNotification
		return baseNotificationCell
	}
}

// MARK: - UITableViewDelegate
extension NotificationsViewController {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let baseNotificationCell = tableView.cellForRow(at: indexPath) as? BaseNotificationCell
		// Change notification status to read
		guard let notificationID = baseNotificationCell?.userNotification?.id else { return }
		self.updateNotification(at: [indexPath], for: notificationID, withReadStatus: .read)

		if baseNotificationCell?.notificationType == .session {
			// Show sessions view
			WorkflowController.shared.showSessions()
		} else if baseNotificationCell?.notificationType == .follower {
			// Change notification status to read
			guard let userID = baseNotificationCell?.userNotification?.attributes.payload.userID else { return }
			if let profileViewController = R.storyboard.profile.profileTableViewController() {
				profileViewController.userID = userID
				profileViewController.dismissButtonIsEnabled = true

				let kurozoraNavigationController = KNavigationController.init(rootViewController: profileViewController)
				self.present(kurozoraNavigationController, animated: true)
			}
		}
	}
}

// MARK: - SwipeTableViewCellDelegate
extension NotificationsViewController: SwipeTableViewCellDelegate {
	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
		switch orientation {
		case .right:
			let deleteAction = SwipeAction(style: .destructive, title: "Delete") { [weak self] _, indexPath in
				guard let self = self else { return }
				switch self.grouping {
				case .automatic, .byType:
					let notificationID = self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].id
					KService.deleteNotification(notificationID) { [weak self] result in
						guard let self = self else { return }
						switch result {
						case .success:
							self.groupedNotifications[indexPath.section].sectionNotifications.remove(at: indexPath.row)
							tableView.deleteRows(at: [indexPath], with: .left)

							if self.groupedNotifications[indexPath.section].sectionNotifications.count == 0 {
								self.groupedNotifications.remove(at: indexPath.section)
								tableView.deleteSections([indexPath.section], with: .left)
							}
							tableView.endUpdates()
						case .failure:
							break
						}
					}
				case .off:
					KService.deleteNotification(self.userNotifications[indexPath.row].id) { [weak self] result in
						guard let self = self else { return }

						switch result {
						case .success:
							self.userNotifications.remove(at: indexPath.row)
							tableView.beginUpdates()
							tableView.deleteRows(at: [indexPath], with: .left)
							tableView.endUpdates()
						case .failure:
							break
						}
					}
				}
			}
			deleteAction.backgroundColor = .clear
			deleteAction.image = R.image.trash_circle()
			deleteAction.textColor = .kLightRed
			deleteAction.font = .systemFont(ofSize: 13)
			deleteAction.transitionDelegate = ScaleTransition.default
			return [deleteAction]
		case .left:
			var readStatus: ReadStatus = .unread
			switch self.grouping {
			case .automatic, .byType:
				let notificationReadStatus = self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].attributes.readStatus
				if notificationReadStatus == .unread {
					readStatus = .read
				}
			case .off:
				let notificationReadStatus = self.userNotifications[indexPath.row].attributes.readStatus
				if notificationReadStatus == .unread {
					readStatus = .read
				}
			}

			let markedAction = SwipeAction(style: .default, title: "") { _, indexPath in
				var notificationID = ""

				switch self.grouping {
				case .automatic, .byType:
					notificationID = self.groupedNotifications[indexPath.section].sectionNotifications[indexPath.row].id
				case .off:
					notificationID = self.userNotifications[indexPath.row].id
				}

				self.updateNotification(at: [indexPath], for: notificationID, withReadStatus: readStatus)
			}
			let isRead = readStatus == .read
			markedAction.backgroundColor = .clear
			markedAction.title = isRead ? "Mark as Read" : "Mark as Unread"
			markedAction.image = isRead ? R.image.unwatched_circle()! : R.image.watched_circle()!
			markedAction.textColor = isRead ? #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1) : .kurozora
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
