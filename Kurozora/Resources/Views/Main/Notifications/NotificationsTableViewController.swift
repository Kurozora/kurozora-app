//
//  NotificationsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class NotificationsTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var markAllButton: UIBarButtonItem!

	// MARK: - Properties
	var grouping: KNotification.GroupStyle = KNotification.GroupStyle(rawValue: UserSettings.notificationsGrouping) ?? .automatic
	var oldGrouping: Int? = nil
	var userNotifications: [UserNotification] = [] {
		didSet {
			self.groupNotifications(userNotifications)
			self.tableView.reloadData {
				self._prefersActivityIndicatorHidden = true
				self.toggleEmptyDataView()

				#if !targetEnvironment(macCatalyst)
				self.refreshControl?.endRefreshing()
				self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your notifications list!")
				#endif
			}
		}
	} // Grouping type: Off
	var groupedNotifications = [GroupedNotifications]() // Grouping type: Automatic, ByType

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

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

			DispatchQueue.global(qos: .userInteractive).async {
				self.fetchNotifications()
			}
		}
	}

	override func viewWillReload() {
		super.viewWillReload()

		self.enableRefreshControl()
		self.enableActions()
		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(updateNotifications(_:)), name: .KUNDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(removeNotification(_:)), name: .KUNDidDelete, object: nil)

		// Hide activity indicator if user is not signed in.
		if !User.isSignedIn {
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
		}

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your notifications!")
		#endif

		self.enableRefreshControl()
		self.enableActions()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if User.isSignedIn {
			oldGrouping = UserSettings.notificationsGrouping
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		self.fetchNotifications()
	}

	override func configureEmptyDataView() {
		var detailString: String
		var buttonTitle: String = ""
		var buttonAction: (() -> Void)? = nil

		if User.isSignedIn {
			detailString = "When you have notifications, you will see them here!"
		} else {
			detailString = "Notifications are only available to registered Kurozora users."
			buttonTitle = "Sign In"
			buttonAction = {
				if let signInTableViewController = R.storyboard.onboarding.signInTableViewController() {
					let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
					self.present(kNavigationController, animated: true)
				}
			}
		}

		emptyBackgroundView.configureImageView(image: R.image.empty.notifications()!)
		emptyBackgroundView.configureLabels(title: "No Notifications", detail: detailString)
		emptyBackgroundView.configureButton(title: buttonTitle, handler: buttonAction)

		tableView.backgroundView?.alpha = 0
	}

	/// Fades in and out the empty data view according to the number of sections.
	func toggleEmptyDataView() {
		if self.tableView.numberOfSections == 0 || !User.isSignedIn {
			self.tableView.backgroundView?.animateFadeIn()
		} else {
			self.tableView.backgroundView?.animateFadeOut()
		}
	}

	/// Enables and disables the refresh control according to the user sign in state.
	private func enableRefreshControl() {
		self._prefersRefreshControlDisabled = !User.isSignedIn
	}

	/// Enables and disables actions such as buttons and the refresh control according to the user sign in state.
	private func enableActions() {
		markAllButton.isEnabled = User.isSignedIn
		markAllButton.title = User.isSignedIn ? "Mark all" : ""
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.isEnabled = User.isSignedIn
		#endif
	}

	/// Fetch the notifications for the current user.
	func fetchNotifications() {
		DispatchQueue.main.async {
			#if !targetEnvironment(macCatalyst)
			self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing notifications list...")
			#endif
		}

		if User.isSignedIn {
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
			self.tableView.reloadData {
				self.toggleEmptyDataView()
			}

			self._prefersActivityIndicatorHidden = true
		}
	}

	// MARK: - IBActions
	/// Show options for editing notifications in batch.
	///
	/// - Parameter sender: The object containing a reference to the button that initiated this action.
	@IBAction func moreOptionsButtonPressed(_ sender: UIBarButtonItem) {
		let actionSheetAlertController = UIAlertController.actionSheet(title: nil, message: nil) { [weak self] actionSheetAlertController in
			guard let self = self else { return }
			// Mark all as read action
			let markAllAsRead = UIAlertAction(title: "Mark all as read", style: .default) { _ in
				self.userNotifications.batchUpdate(for: "all", withReadStatus: .read)
			}
			markAllAsRead.setValue(UIImage(systemName: "circlebadge"), forKey: "image")
			markAllAsRead.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			actionSheetAlertController.addAction(markAllAsRead)

			// Mark all as unread action
			let markAllAsUnread = UIAlertAction(title: "Mark all as unread", style: .default) { _ in
				self.userNotifications.batchUpdate(for: "all", withReadStatus: .unread)
			}
			markAllAsUnread.setValue(UIImage(systemName: "circlebadge.fill"), forKey: "image")
			markAllAsUnread.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			actionSheetAlertController.addAction(markAllAsUnread)
		}

		// Present the controller
		if let popoverController = actionSheetAlertController.popoverPresentationController {
			popoverController.barButtonItem = sender
		}

		if (navigationController?.visibleViewController as? UIAlertController) == nil {
			self.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	/// Update notifications status withtin a specific section.
	///
	/// - Parameter sender: The object containing a reference to the button that initiated this action.
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

		switch self.grouping {
		case .automatic, .byType:
			self.groupedNotifications[section].sectionNotifications.batchUpdate(at: indexPaths, for: notificationIDs, withReadStatus: readStatus)
		case .off:
			self.userNotifications.batchUpdate(at: indexPaths, for: notificationIDs, withReadStatus: readStatus)
		}

		sender.setTitle(readStatus == .unread ? "Mark as read" : "Mark as unread", for: .normal)
	}
}

// MARK: - UITableViewDataSource
extension NotificationsTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		switch self.grouping {
		case .automatic, .byType:
			return self.groupedNotifications.count
		case .off:
			return self.userNotifications.isEmpty ? 0 : 1
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
		let titleHeaderTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.titleHeaderTableViewCell.identifier) as? TitleHeaderTableViewCell
		titleHeaderTableViewCell?.headerButton.tag = section
		titleHeaderTableViewCell?.headerButton.addTarget(self, action: #selector(notificationMarkButtonPressed(_:)), for: .touchUpInside)

		switch self.grouping {
		case .automatic, .byType:
			titleHeaderTableViewCell?.titleLabel.text = groupedNotifications[section].sectionTitle
			titleHeaderTableViewCell?.subTitleLabel.text = nil
			let allNotificationsRead = groupedNotifications[section].sectionNotifications.contains(where: { $0.attributes.readStatus == .read })
			titleHeaderTableViewCell?.headerButton.setTitle(allNotificationsRead ? "Mark as unread" : "Mark as read", for: .normal)
			return titleHeaderTableViewCell?.contentView
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
		baseNotificationCell.notificationType = notificationType
		baseNotificationCell.userNotification = userNotification
		return baseNotificationCell
	}
}

// MARK: - KTableViewDataSource
extension NotificationsTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [TitleHeaderTableViewCell.self]
	}
}

// MARK: - Helper functions
extension NotificationsTableViewController {
	/// Group the fetched notifications according to the user's notification preferences.
	///
	/// - Parameter userNotifications: The array of the fetched notifications.
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
			self.groupedNotifications.sort(by: { $0.sectionNotifications.first?.attributes.createdAt ?? Date() > $1.sectionNotifications.first?.attributes.createdAt ?? Date() })
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
			self.groupedNotifications.sort(by: { $0.sectionNotifications.first?.attributes.createdAt ?? Date() > $1.sectionNotifications.first?.attributes.createdAt ?? Date() })
		case .off:
			self.groupedNotifications = []
		}
	}

	/// Updates the user's notifications with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc fileprivate func updateNotifications(_ notification: NSNotification) {
		let userInfo = notification.userInfo
		if let indexPath = userInfo?["indexPath"] as? IndexPath {
			self.tableView.performBatchUpdates({
				self.tableView.reloadSections([indexPath.section], with: .automatic)
			}, completion: nil)
		} else {
			self.tableView.reloadData {
				self.toggleEmptyDataView()
			}
		}
	}

	/// Removes the replies specified in the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc fileprivate func removeNotification(_ notification: NSNotification) {
		let userInfo = notification.userInfo
		if let indexPath = userInfo?["indexPath"] as? IndexPath {
			switch self.grouping {
			case .automatic, .byType:
				tableView.performBatchUpdates({
					self.groupedNotifications[indexPath.section].sectionNotifications.remove(at: indexPath.row)
					tableView.deleteRows(at: [indexPath], with: .left)

					if self.groupedNotifications[indexPath.section].sectionNotifications.count == 0 {
						self.groupedNotifications.remove(at: indexPath.section)
						tableView.deleteSections([indexPath.section], with: .left)
					}
				}, completion: nil)
			case .off:
				self.userNotifications[indexPath.row].remove(at: indexPath)

				tableView.performBatchUpdates({
					self.userNotifications.remove(at: indexPath.row)
					tableView.deleteRows(at: [indexPath], with: .automatic)
				}, completion: nil)
			}

			self.toggleEmptyDataView()
		}
	}
}
