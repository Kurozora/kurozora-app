//
//  NotificationsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import Foundation

class NotificationDataSource: UITableViewDiffableDataSource<NotificationsTableViewController.SectionLayoutKind, UserNotification> { }

class NotificationsTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var markAllButton: UIBarButtonItem!

	// MARK: - Properties
	var grouping: KNotification.GroupStyle = KNotification.GroupStyle(rawValue: UserSettings.notificationsGrouping) ?? .automatic
	var oldGrouping: Int?
	var userNotifications: [UserNotification] = [] // Grouping type: Off
	var groupedNotifications: [GroupedNotifications] = [] // Grouping type: Automatic, ByType
	var dataSource: NotificationDataSource! = nil

	/// Whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

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
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.enableRefreshControl()
			self.enableActions()
		}
		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateNotifications(_:)), name: .KUNDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.removeNotification(_:)), name: .KUNDidDelete, object: nil)

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your notifications!")
		#endif

		self.enableRefreshControl()
		self.enableActions()

		self.configureDataSource()

		if !self.userNotifications.isEmpty {
			self.endFetch()
		} else {
			// Fetch sessions
			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchNotifications()
			}
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Hide activity indicator if user is not signed in.
		if !User.isSignedIn {
			self._prefersActivityIndicatorHidden = true
			self.toggleEmptyDataView()
		}

		if self.oldGrouping == nil || self.oldGrouping != UserSettings.notificationsGrouping, User.isSignedIn {
			let notificationsGrouping = UserSettings.notificationsGrouping
			self.grouping = KNotification.GroupStyle(rawValue: notificationsGrouping)!

			Task { [weak self] in
				guard let self = self else { return }
				await self.fetchNotifications()
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if User.isSignedIn {
			self.oldGrouping = UserSettings.notificationsGrouping
		}
	}

	// MARK: - Functions
	override func handleRefreshControl() {
		Task { [weak self] in
			guard let self = self else { return }
			await self.fetchNotifications()
		}
	}

	override func configureEmptyDataView() {
		var detailString: String
		var buttonTitle: String = ""
		var buttonAction: (() -> Void)?

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

		emptyBackgroundView.configureImageView(image: .Empty.notifications)
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

	func endFetch() {
		self.isRequestInProgress = false
		self.updateDataSource()
		self._prefersActivityIndicatorHidden = true
		self.toggleEmptyDataView()
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.endRefreshing()
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh your notifications.")
		#endif
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
	func fetchNotifications() async {
		guard !self.isRequestInProgress else {
			return
		}

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: "Refreshing notifications...")
		#endif

		if User.isSignedIn {
			do {
				let notificationResponse = try await KService.getNotifications().value

				switch self.grouping {
				case .automatic, .byType:
					self.groupNotifications(notificationResponse.data)
				case .off:
					self.userNotifications = notificationResponse.data
				}
			} catch {
				print(error.localizedDescription)
			}
		} else {
			self.userNotifications = []
			self.groupedNotifications = []
		}

		self.endFetch()
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
				Task {
					let readStatus = await self.updateNotification("all", withStatus: .read)
					let userNotifications = self.dataSource.snapshot().itemIdentifiers
					self.updateUserNotifications(userNotifications, withStatus: readStatus)
				}
			}
			markAllAsRead.setValue(UIImage(systemName: "circlebadge"), forKey: "image")
			markAllAsRead.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
			actionSheetAlertController.addAction(markAllAsRead)

			// Mark all as unread action
			let markAllAsUnread = UIAlertAction(title: "Mark all as unread", style: .default) { _ in
				Task {
					let readStatus = await self.updateNotification("all", withStatus: .unread)
					let userNotifications = self.dataSource.snapshot().itemIdentifiers
					self.updateUserNotifications(userNotifications, withStatus: readStatus)
				}
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

	/// Update notifications status within a specific section.
	///
	/// - Parameter sender: The object containing a reference to the button that initiated this action.
	@objc func updateNotifications(in section: Int, sender: UIButton) {
		guard let sectionLayoutKind = self.dataSource.sectionIdentifier(for: section) else { return }
		let userNotifications = self.dataSource.snapshot().itemIdentifiers(inSection: sectionLayoutKind)
		var readStatus: ReadStatus = .unread

		// Iterate over all the rows of a section
		let notificationIDs = userNotifications.compactMap { userNotification in
			if userNotification.attributes.readStatus == .unread && readStatus == .unread {
				readStatus = .read
			}

			return userNotification.id
		}.joined(separator: ",")

		Task { [weak self] in
			guard let self = self else { return }
			let readStatus = await self.updateNotification(notificationIDs, withStatus: readStatus)
			self.updateUserNotifications(userNotifications, withStatus: readStatus)
		}

		sender.setTitle(readStatus == .unread ? "Mark as read" : "Mark as unread", for: .normal)
	}

	func updateNotification(_ notificationID: String, withStatus readStatus: ReadStatus) async -> ReadStatus {
		do {
			let userNotificationUpdateResponse = try await KService.updateNotification(notificationID, withReadStatus: readStatus).value
			return userNotificationUpdateResponse.data.readStatus
		} catch {
			print(error.localizedDescription)
			return readStatus
		}
	}

	func updateUserNotifications(_ userNotifications: [UserNotification], withStatus readStatus: ReadStatus) {
		userNotifications.forEach { userNotification in
			userNotification.attributes.readStatus = readStatus
		}

		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems(userNotifications)
		self.dataSource.defaultRowAnimation = .automatic
		self.dataSource.apply(snapshot)
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
			// Group notifications by date and assign a group title as key (Recent, Last Week, Yesterday etc.)
			let groupedNotificationsArray = userNotifications.reduce(into: [String: [UserNotification]]()) { result, userNotification in
				let creationDate = userNotification.attributes.createdAt
				let timeKey = creationDate.groupTime

				result[timeKey, default: []].append(userNotification)
			}

			// Append the grouped elements to the grouped notifications array
			var groupedNotifications: [GroupedNotifications] = []
			for (key, value) in groupedNotificationsArray {
				groupedNotifications.append(GroupedNotifications(sectionTitle: key, sectionNotifications: value))
			}

			// Reorder grouped notifications so the recent one is at the top (Recent, Earlier Today, Yesterday, etc.)
			groupedNotifications.sort {
				$0.sectionNotifications.first?.attributes.createdAt ?? Date() > $1.sectionNotifications.first?.attributes.createdAt ?? Date()
			}

			self.groupedNotifications = groupedNotifications
		case .byType:
			// Group notifications by type and assign a group title as key (Sessions, Messages etc.)
			let groupedNotificationsArray = userNotifications.reduce(into: [String: [UserNotification]](), { (result, userNotification) in
				let userNotificationType = userNotification.attributes.type
				let timeKey = userNotificationType.stringValue

				result[timeKey, default: []].append(userNotification)
			})

			// Append the grouped elements to the grouped notifications array
			var groupedNotifications: [GroupedNotifications] = []
			for (key, value) in groupedNotificationsArray {
				groupedNotifications.append(GroupedNotifications(sectionTitle: key, sectionNotifications: value))
			}

			// Reorder grouped notifications so it's in alphabetical order
			groupedNotifications.sort {
				$0.sectionTitle < $1.sectionTitle
			}

			self.groupedNotifications = groupedNotifications
		case .off:
			self.groupedNotifications = []
		}
	}

	/// Updates the user's notifications with the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc fileprivate func updateNotifications(_ notification: NSNotification) {
		guard let userNotification = notification.object as? UserNotification else { return }

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			var newSnapshot = self.dataSource.snapshot()
			newSnapshot.reloadItems([userNotification])
			self.dataSource.defaultRowAnimation = .automatic
			self.dataSource.apply(newSnapshot)
		}
	}

	/// Removes the notification specified in the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc fileprivate func removeNotification(_ notification: NSNotification) {
		guard let userNotification = notification.object as? UserNotification else { return }
		guard let indexPath = self.dataSource.indexPath(for: userNotification) else { return }

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.removeNotification(at: indexPath)
		}
	}

	/// Removes the notification specified by the givne index path.
	///
	/// - Parameter indexPath: The index path of the notification.
	func removeNotification(at indexPath: IndexPath) {
		switch self.grouping {
		case .automatic, .byType:
			self.groupedNotifications[indexPath.section].sectionNotifications.remove(at: indexPath.row)

			if self.groupedNotifications[indexPath.section].sectionNotifications.count == 0 {
				self.groupedNotifications.remove(at: indexPath.section)
			}
		case .off:
			self.userNotifications.remove(at: indexPath.row)
		}

		self.dataSource.defaultRowAnimation = .top
		self.updateDataSource()
		self.endFetch()
	}
}

// MARK: - TitleHeaderTableViewCellDelegate
extension NotificationsTableViewController: TitleHeaderTableReusableViewDelegate {
	func titleHeaderTableReusableView(_ reusableView: TitleHeaderTableReusableView, didPress button: UIButton) {
		guard let section = reusableView.section else { return }
		self.updateNotifications(in: section, sender: button)
	}
}

// MARK: - SectionLayoutKind
extension NotificationsTableViewController {
	/// List of notification section layout kind.
	///
	/// - `main`: a `main` notifications section.
	/// - `grouped`: a `grouped` notifications section.
	enum SectionLayoutKind: Hashable {
		// MARK: - Cases
		/// Indicates a main notifications section.
		case main

		/// Indicates a grouped notifications section.
		case grouped(_ groupedNotifications: GroupedNotifications)

		// MARK: - Functions
		func hash(into hasher: inout Hasher) {
			switch self {
			case .grouped(let groupedNotifications):
				hasher.combine(groupedNotifications)
			case .main: break
			}
		}

		static func == (lhs: SectionLayoutKind, rhs: SectionLayoutKind) -> Bool {
			switch (lhs, rhs) {
			case (.grouped(let groupedNotifications1), .grouped(let groupedNotifications2)):
				return groupedNotifications1 == groupedNotifications2
			case (.main, .main):
				return true
			default:
				return false
			}
		}
	}
}
