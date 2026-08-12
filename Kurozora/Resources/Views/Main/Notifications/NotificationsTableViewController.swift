//
//  NotificationsTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 14/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import Foundation
import KurozoraKit
import UIKit

class NotificationDataSource: UITableViewDiffableDataSource<NotificationsTableViewController.SectionLayoutKind, UserNotification> {}

class NotificationsTableViewController: KTableViewController, ProfileNavigable, TypedSegueHandling {
	// MARK: - Enums
	enum SegueIdentifiers: String, SegueIdentifier {
		case notificationsGroupingSegue
	}

	// MARK: - Views
	var profileBarButtonItem: ProfileBarButtonItem?

	/// The bar button item that opens the weekly digest.
	var digestBarButtonItem = UIBarButtonItem()

	/// The bar button item that enters batch-edit mode.
	var selectBarButtonItem = UIBarButtonItem()

	/// The bar button item that exits batch-edit mode.
	var cancelEditingBarButtonItem = UIBarButtonItem()

	/// The bar button item that toggles between selecting and deselecting every loaded notification.
	var selectAllBarButtonItem = UIBarButtonItem()

	/// The bar button item that hosts the mark-as-read/unread menu in batch-edit mode.
	var statusBatchBarButtonItem = UIBarButtonItem()

	/// The bar button item that hosts the destructive delete confirmation menu in batch-edit mode.
	var deleteBatchBarButtonItem = UIBarButtonItem()

	/// The label that displays the selected-notification count in the bottom toolbar.
	var selectionCountLabel = UILabel()

	// MARK: - Properties
	var grouping: KNotification.GroupStyle = KNotification.GroupStyle(rawValue: UserSettings.notificationsGrouping) ?? .automatic
	var oldGrouping: Int?
	var userNotifications: [UserNotification] = []
	var groupedNotifications: [GroupedNotifications] = []
	var dataSource: NotificationDataSource!

	/// A boolean value that indicates whether a fetch request is currently in progress.
	var isRequestInProgress: Bool = false

	/// The right bar button items captured before entering batch-edit mode.
	var savedRightBarButtonItems: [UIBarButtonItem]?

	/// The left bar button items captured before entering batch-edit mode.
	var savedLeftBarButtonItems: [UIBarButtonItem]?

	/// A boolean value that indicates whether batch-edit  is currently displayed.
	var batchEditIsActive: Bool = false

	/// A boolean value that indicates whether this controller hid the tab bar to enter edit mode.
	var didHideTabBarForEdit: Bool = false

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
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - Initializers
	init() {
		super.init(style: .insetGrouped)
		self.sharedInit()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.sharedInit()
	}

	// MARK: - View
	override func viewWillReload() {
		super.viewWillReload()

		DispatchQueue.main.async { [weak self] in
			guard let self = self else { return }
			self.configureUserDetails()
			self.enableRefreshControl()
			self.enableActions()
		}
		self.handleRefreshControl()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotificationBadgeToggle), name: .KSNotificationsBadgeIsOn, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.updateNotifications(_:)), name: .KUNDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.removeNotification(_:)), name: .KUNDidDelete, object: nil)

		self.title = L10n.notifications

		// Setup refresh control
		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.notifications.lowercased(with: Locale.current)))
		#endif

		self.tableView.allowsMultipleSelectionDuringEditing = true

		self.configureNavigationItems()
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

	override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		coordinator.animate(alongsideTransition: { [weak self] _ in
			guard let self = self, self.batchEditIsActive else { return }
			self.toolbarItems = self.makeBatchToolbarItems()
		})
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
			detailString = L10n.notificationsEmptyDetail
		} else {
			detailString = L10n.notificationsSignedOutDetail
			buttonTitle = L10n.signIn
			buttonAction = {
				let signInTableViewController = SignInTableViewController()
				let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
				self.present(kNavigationController, animated: true)
			}
		}

		if let image = UIImage(systemName: "app.badge.fill") {
			emptyBackgroundView.configureImageView(image: image)
		}
		emptyBackgroundView.configureLabels(title: L10n.noItemsTitle(L10n.notifications), detail: detailString)
		emptyBackgroundView.configureButton(title: buttonTitle, handler: buttonAction)

		tableView.backgroundView?.alpha = 0
	}

	/// Fades the empty data view in or out according to the number of sections.
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
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.pullToRefreshItems(L10n.notifications.lowercased(with: Locale.current)))
		#endif
		self.updateTabBarBadge()
	}

	/// Fetches the notifications for the authenticated user.
	func fetchNotifications() async {
		guard !self.isRequestInProgress else { return }

		// Set request in progress
		self.isRequestInProgress = true

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.attributedTitle = NSAttributedString(string: L10n.refreshingItems(L10n.notifications.lowercased(with: Locale.current)))
		#endif

		if User.isSignedIn {
			do {
				let notificationResponse = try await KService.notifications().response()

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

	/// Configures the view with the user's details.
	func configureUserDetails() {
		self.profileBarButtonItem?.configure(for: User.current)
	}

	/// Updates the tab bar badge value according to the number of unread notifications.
	func updateTabBarBadge() {
		let unreadCount: Int

		switch self.grouping {
		case .automatic, .byType:
			unreadCount = self.groupedNotifications.reduce(0) { partialResult, groupedNotifications in
				partialResult + groupedNotifications.sectionNotifications.filter { $0.attributes.readStatus == .unread }.count
			}
		case .off:
			unreadCount = self.userNotifications.filter { $0.attributes.readStatus == .unread }.count
		}

		if let tabBarController = self.tabBarController as? KTabBarController {
			if unreadCount == 0 {
				tabBarController.setBadgeValue(nil, for: .notifications)
			} else {
				tabBarController.setBadgeValue("\(unreadCount)", for: .notifications)
			}
		}
	}

	/// Handles notification badge toggle.
	@objc func handleNotificationBadgeToggle() {
		Task { @MainActor [weak self] in
			guard let self = self else { return }
			self.updateTabBarBadge()
		}
	}

	/// Update notifications status within a specific section.
	///
	/// - Parameters:
	///    - userNotifications: The notifications whose read status changed.
	///    - readStatus: The new read status to apply locally.
	func updateUserNotifications(_ userNotifications: [UserNotification], withStatus readStatus: ReadStatus) {
		userNotifications.forEach { userNotification in
			userNotification.attributes.readStatus = readStatus
		}

		var snapshot = self.dataSource.snapshot()
		snapshot.reconfigureItems(userNotifications)
		self.dataSource.defaultRowAnimation = .automatic
		self.dataSource.apply(snapshot)
		self.updateTabBarBadge()
	}

	/// The shared settings used to initialize the table view.
	private func sharedInit() {
		self.tableView.cellLayoutMarginsFollowReadableWidth = true
	}

	/// Configures the profile bar button item.
	private func configureProfileBarButtonItem() {
		self.profileBarButtonItem = ProfileBarButtonItem(primaryAction: UIAction { [weak self] _ in
			guard let self = self else { return }

			Task {
				await self.segueToProfile()
			}
		})

		if let profileBarButtonItem = self.profileBarButtonItem {
			self.navigationItem.rightBarButtonItem = profileBarButtonItem
		}

		self.configureUserDetails()
	}

	/// Configures the bar button item that enters batch-edit mode.
	private func configureSelectBarButtonItem() {
		self.selectBarButtonItem.title = L10n.select
		self.selectBarButtonItem.image = UIImage(systemName: "checkmark.circle")
		self.selectBarButtonItem.style = .plain
		self.selectBarButtonItem.primaryAction = UIAction(title: L10n.select, image: UIImage(systemName: "checkmark.circle")) { [weak self] _ in
			self?.setEditing(true, animated: true)
		}
	}

	/// Configures the bar button item that opens the weekly digest.
	private func configureDigestBarButtonItem() {
		self.digestBarButtonItem.title = L10n.digest
		self.digestBarButtonItem.image = UIImage(systemName: "sparkles")
		self.digestBarButtonItem.style = .plain
		self.digestBarButtonItem.primaryAction = UIAction(title: L10n.digest, image: UIImage(systemName: "sparkles")) { [weak self] _ in
			guard let self = self else { return }
			let digestCollectionViewController = DigestCollectionViewController()
			self.show(digestCollectionViewController, sender: nil)
		}
	}

	/// Wires the navigation items used both in normal and batch edit mode.
	fileprivate func configureNavigationItems() {
		self.configureSelectBarButtonItem()
		self.configureDigestBarButtonItem()
		self.configureBatchEditBarButtonItems()
		self.configureBottomActionContainer()
		self.configureProfileBarButtonItem()
	}

	/// Enables and disables the refresh control according to the user's sign-in state.
	private func enableRefreshControl() {
		self._prefersRefreshControlDisabled = !User.isSignedIn
	}

	/// Refreshes the navigation bar items based on the current sign-in state.
	private func enableActions() {
		guard !self.batchEditIsActive else { return }

		var rightItems: [UIBarButtonItem] = []

		if let profileBarButtonItem = self.profileBarButtonItem {
			rightItems.append(profileBarButtonItem)
		}

		if User.isSignedIn {
			rightItems.append(self.selectBarButtonItem)
		}

		self.navigationItem.rightBarButtonItems = rightItems
		self.navigationItem.leftBarButtonItems = User.isSignedIn ? [self.digestBarButtonItem] : nil

		#if !targetEnvironment(macCatalyst)
		self.refreshControl?.isEnabled = User.isSignedIn
		#endif
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
			let groupedNotificationsArray = userNotifications.reduce(into: [String: [UserNotification]]()) { result, userNotification in
				let userNotificationType = userNotification.attributes.type
				let timeKey = userNotificationType.stringValue

				result[timeKey, default: []].append(userNotification)
			}

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
		if let userNotification = notification.object as? UserNotification {
			Task { @MainActor [weak self] in
				guard let self = self else { return }
				var newSnapshot = self.dataSource.snapshot()
				newSnapshot.reloadItems([userNotification])
				self.dataSource.defaultRowAnimation = .automatic
				self.dataSource.apply(newSnapshot)
				self.updateTabBarBadge()
			}
			return
		}

		if let ids = notification.userInfo?["ids"] as? [String], !ids.isEmpty {
			let read = (notification.userInfo?["read"] as? Bool) ?? true

			Task { @MainActor [weak self] in
				guard let self = self else { return }
				let matches = self.findUserNotifications(matching: ids)

				if matches.isEmpty {
					guard User.isSignedIn else { return }
					await self.fetchNotifications()
					return
				}

				self.updateUserNotifications(matches, withStatus: read ? .read : .unread)
				self.updateTabBarBadge()
			}

			return
		}

		Task { @MainActor [weak self] in
			guard let self = self, User.isSignedIn else { return }
			await self.fetchNotifications()
		}
	}

	/// Removes the notification specified in the received information.
	///
	/// - Parameter notification: An object containing information broadcast to registered observers.
	@objc fileprivate func removeNotification(_ notification: NSNotification) {
		if let userNotification = notification.object as? UserNotification {
			guard let indexPath = self.dataSource.indexPath(for: userNotification) else { return }

			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
				self.removeNotification(at: indexPath)
			}
			return
		}

		if let ids = notification.userInfo?["ids"] as? [String], !ids.isEmpty {
			Task { @MainActor [weak self] in
				guard let self = self else { return }
				let matches = self.findUserNotifications(matching: ids)

				if matches.isEmpty {
					guard User.isSignedIn else { return }
					await self.fetchNotifications()
					return
				}

				self.removeNotifications(matches)
			}

			return
		}

		Task { @MainActor [weak self] in
			guard let self = self, User.isSignedIn else { return }
			await self.fetchNotifications()
		}
	}

	/// Returns the locally-cached notifications whose identifiers are in the supplied list.
	///
	/// - Parameter ids: The identifiers to look up.
	///
	/// - Returns: The matching ``UserNotification`` instances.
	private func findUserNotifications(matching ids: [String]) -> [UserNotification] {
		let lookup = Set(ids)
		switch self.grouping {
		case .automatic, .byType:
			return self.groupedNotifications.flatMap { $0.sectionNotifications }
				.filter { lookup.contains($0.id.rawValue) }
		case .off:
			return self.userNotifications.filter { lookup.contains($0.id.rawValue) }
		}
	}

	/// Removes the notification at the given index path.
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

	/// Removes the given notifications.
	///
	/// - Parameter userNotifications: The notifications to remove.
	func removeNotifications(_ userNotifications: [UserNotification]) {
		guard !userNotifications.isEmpty else { return }
		let removedIDs = Set(userNotifications.map { $0.id })

		switch self.grouping {
		case .automatic, .byType:
			for index in (0 ..< self.groupedNotifications.count).reversed() {
				self.groupedNotifications[index].sectionNotifications.removeAll { removedIDs.contains($0.id) }

				if self.groupedNotifications[index].sectionNotifications.isEmpty {
					self.groupedNotifications.remove(at: index)
				}
			}
		case .off:
			self.userNotifications.removeAll { removedIDs.contains($0.id) }
		}

		self.dataSource.defaultRowAnimation = .top
		self.updateDataSource()
		self.toggleEmptyDataView()
		self.updateTabBarBadge()
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
