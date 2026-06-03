//
//  NotificationsTableViewController+EditMode.swift
//  Kurozora
//
//  Created by Khoren Katklian on 02/05/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension NotificationsTableViewController {
	// MARK: - Properties
	/// The notifications currently selected in batch-edit mode.
	private var selectedNotifications: [UserNotification] {
		guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
			return []
		}
		return selectedIndexPaths.compactMap { self.dataSource.itemIdentifier(for: $0) }
	}

	/// The total number of notifications loaded across all sections.
	var totalNotificationCount: Int {
		switch self.grouping {
		case .automatic, .byType:
			return self.groupedNotifications.reduce(0) {
				$0 + $1.sectionNotifications.count
			}
		case .off:
			return self.userNotifications.count
		}
	}

	// MARK: - View
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		if editing {
			self.enterBatchEditChrome(animated: animated)
		} else {
			self.exitBatchEditChrome(animated: animated)
		}
	}

	// MARK: - Functions
	/// Configures the bar-button items used by batch-edit chrome.
	func configureBatchEditBarButtonItems() {
		self.cancelEditingBarButtonItem.image = UIImage(systemName: "xmark")
		self.cancelEditingBarButtonItem.style = .plain
		self.cancelEditingBarButtonItem.accessibilityLabel = L10n.cancel
		self.cancelEditingBarButtonItem.primaryAction = UIAction(image: UIImage(systemName: "xmark")) { [weak self] _ in
			self?.setEditing(false, animated: true)
		}

		self.selectAllBarButtonItem.title = L10n.selectAll
		self.selectAllBarButtonItem.style = .plain
	}

	/// Configures the selection-count label and the batch-action items shown in the bottom toolbar.
	func configureBottomActionContainer() {
		self.selectionCountLabel.font = .preferredFont(forTextStyle: .subheadline).bold
		self.selectionCountLabel.textAlignment = .center
		self.selectionCountLabel.theme_textColor = KThemePicker.textColor.rawValue
		self.selectionCountLabel.text = L10n.selectNotifications

		self.statusBatchBarButtonItem.title = L10n.markAsRead
		self.statusBatchBarButtonItem.image = UIImage(systemName: "circlebadge")

		self.deleteBatchBarButtonItem.title = L10n.delete
		self.deleteBatchBarButtonItem.image = UIImage(systemName: "trash")
		self.deleteBatchBarButtonItem.tintColor = .systemRed
	}

	/// Activates the batch-edit chrome.
	///
	/// - Parameter animated: A boolean value that indicates whether the chrome change is animated.
	func enterBatchEditChrome(animated: Bool) {
		guard !self.batchEditIsActive else { return }
		self.batchEditIsActive = true

		self.savedRightBarButtonItems = self.navigationItem.rightBarButtonItems
		self.savedLeftBarButtonItems = self.navigationItem.leftBarButtonItems

		self.refreshSelectAllBarButtonItem(allSelected: false, hasItems: self.totalNotificationCount > 0)
		self.navigationItem.leftBarButtonItems = [self.selectAllBarButtonItem]
		self.navigationItem.rightBarButtonItems = [self.cancelEditingBarButtonItem]

		if !(self.tabBarController?.tabBar.isHidden ?? true) {
			self.didHideTabBarForEdit = true

			if #available(iOS 18.0, *) {
				self.tabBarController?.setTabBarHidden(true, animated: animated)
			} else {
				self.tabBarController?.tabBar.isHidden = true
				self.view.setNeedsLayout()
				self.view.layoutIfNeeded()
			}
		}

		self.toolbarItems = self.makeBatchToolbarItems()
		self.refreshBatchActionToolbar()
		self.navigationController?.setToolbarHidden(false, animated: animated)
	}

	/// Deactivates the batch-edit chrome.
	///
	/// - Parameter animated: A boolean value that indicates whether the chrome change is animated.
	func exitBatchEditChrome(animated: Bool) {
		guard self.batchEditIsActive else { return }
		self.batchEditIsActive = false

		self.tableView.indexPathsForSelectedRows?.forEach { indexPath in
			self.tableView.deselectRow(at: indexPath, animated: animated)
		}

		self.navigationItem.leftBarButtonItems = self.savedLeftBarButtonItems
		self.navigationItem.rightBarButtonItems = self.savedRightBarButtonItems

		if self.didHideTabBarForEdit {
			self.didHideTabBarForEdit = false

			if #available(iOS 18.0, *) {
				self.tabBarController?.setTabBarHidden(false, animated: animated)
			} else {
				self.tabBarController?.tabBar.isHidden = false
				self.view.setNeedsLayout()
				self.view.layoutIfNeeded()
			}
		}

		self.navigationController?.setToolbarHidden(true, animated: animated)
		self.toolbarItems = nil
	}

	/// Returns the bar button items that populate the bottom toolbar in batch-edit mode.
	func makeBatchToolbarItems() -> [UIBarButtonItem] {
		let countItem = UIBarButtonItem(customView: self.selectionCountLabel)

		if #available(iOS 26.0, macOS 26.0, tvOS 26.0, visionOS 26.0, watchOS 26.0, *) {
			countItem.hidesSharedBackground = true
		}

		return [
			self.statusBatchBarButtonItem,
			.flexibleSpace(),
			countItem,
			.flexibleSpace(),
			self.deleteBatchBarButtonItem
		]
	}

	/// Notifies the controller that the batch selection changed.
	func didUpdateBatchSelection() {
		guard self.batchEditIsActive else { return }

		self.refreshBatchActionToolbar()

		let selectedCount = self.tableView.indexPathsForSelectedRows?.count ?? 0
		let totalLoaded = self.totalNotificationCount
		let allSelected = totalLoaded > 0 && selectedCount >= totalLoaded
		self.refreshSelectAllBarButtonItem(allSelected: allSelected, hasItems: totalLoaded > 0)
	}

	/// Selects every loaded notification.
	private func selectAllLoadedNotifications() {
		let snapshot = self.dataSource.snapshot()

		for sectionIdentifier in snapshot.sectionIdentifiers {
			let items = snapshot.itemIdentifiers(inSection: sectionIdentifier)

			for item in items {
				guard let indexPath = self.dataSource.indexPath(for: item) else {
					continue
				}
				self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
			}
		}

		self.didUpdateBatchSelection()
	}

	/// Deselects every selected notification.
	private func deselectAllVisibleNotifications() {
		self.tableView.indexPathsForSelectedRows?.forEach { indexPath in
			self.tableView.deselectRow(at: indexPath, animated: false)
		}
		self.didUpdateBatchSelection()
	}

	/// Updates the count label and rebuilds the batch toolbar menus.
	private func refreshBatchActionToolbar() {
		let selected = self.selectedNotifications
		let count = selected.count
		let hasSelection = count > 0

		self.selectionCountLabel.text = hasSelection ? L10n.itemsSelected(count) : L10n.selectNotifications

		self.statusBatchBarButtonItem.isEnabled = hasSelection
		self.deleteBatchBarButtonItem.isEnabled = hasSelection

		self.statusBatchBarButtonItem.menu = self.makeBatchStatusMenu(selectedNotifications: selected)
		self.deleteBatchBarButtonItem.menu = self.makeBatchDeleteMenu(selectedNotifications: selected)
	}

	/// Updates the select-all bar button item's title, action and enabled state.
	///
	/// - Parameters:
	///    - allSelected: A boolean value that indicates whether every loaded notification is selected.
	///    - hasItems: A boolean value that indicates whether the list has any selectable notifications.
	private func refreshSelectAllBarButtonItem(allSelected: Bool, hasItems: Bool) {
		self.selectAllBarButtonItem.title = allSelected ? L10n.deselectAll : L10n.selectAll
		self.selectAllBarButtonItem.isEnabled = hasItems
		self.selectAllBarButtonItem.primaryAction = UIAction(title: self.selectAllBarButtonItem.title ?? "") { [weak self] _ in
			guard let self = self else { return }

			if allSelected {
				self.deselectAllVisibleNotifications()
			} else {
				self.selectAllLoadedNotifications()
			}
		}
	}

	/// Returns the read-status menu for the selected notifications.
	///
	/// - Parameter selectedNotifications: The notifications currently selected.
	///
	/// - Returns: A menu with one element per available batch action.
	private func makeBatchStatusMenu(selectedNotifications: [UserNotification]) -> UIMenu {
		let anyUnread = selectedNotifications.contains { $0.attributes.readStatus == .unread }
		let targetReadStatus: ReadStatus = anyUnread ? .read : .unread

		let title = targetReadStatus == .read ? L10n.markAsRead : L10n.markAsUnread
		let image = targetReadStatus == .read ? UIImage(systemName: "circlebadge") : UIImage(systemName: "circlebadge.fill")

		let action = UIAction(title: title, image: image) { [weak self] _ in
			self?.performBatchReadStatusUpdate(selectedNotifications: selectedNotifications, readStatus: targetReadStatus)
		}
		return UIMenu(title: "", children: [action])
	}

	/// Returns a destructive confirmation menu for removing the selected notifications.
	///
	/// - Parameter selectedNotifications: The notifications currently selected.
	///
	/// - Returns: A destructive menu containing the delete confirmation action.
	private func makeBatchDeleteMenu(selectedNotifications: [UserNotification]) -> UIMenu {
		let count = selectedNotifications.count
		let buttonTitle: String = L10n.deleteNotifications(count)
		let message: String = L10n.deleteNotificationsConfirmation(count)

		let confirmAction = UIAction(title: buttonTitle, image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
			self?.performBatchDelete(selectedNotifications: selectedNotifications)
		}
		return UIMenu(title: message, options: .destructive, children: [confirmAction])
	}

	/// Sets the read status of the selected notifications.
	///
	/// - Parameters:
	///    - selectedNotifications: The notifications currently selected.
	///    - readStatus: The target read status to apply.
	private func performBatchReadStatusUpdate(selectedNotifications: [UserNotification], readStatus: ReadStatus) {
		let notificationsToUpdate = selectedNotifications.filter { $0.attributes.readStatus != readStatus }

		guard !notificationsToUpdate.isEmpty else {
			self.setEditing(false, animated: true)
			return
		}

		let joinedIDs = notificationsToUpdate.map { $0.id.rawValue }.joined(separator: ",")

		Task { [weak self] in
			guard let self = self else { return }

			do {
				let response = try await KService.updateNotification(joinedIDs, readStatus: readStatus).response()
				self.updateUserNotifications(notificationsToUpdate, withStatus: response.data.readStatus)
				self.setEditing(false, animated: true)
			} catch let error as APIError {
				self.presentAlertController(title: L10n.couldNotUpdateNotifications, message: error.message)
			} catch {
				self.presentAlertController(title: L10n.couldNotUpdateNotifications, message: error.localizedDescription)
			}
		}
	}

	/// Removes the selected notifications and exits edit mode on success.
	///
	/// - Parameter selectedNotifications: The notifications currently selected.
	private func performBatchDelete(selectedNotifications: [UserNotification]) {
		guard !selectedNotifications.isEmpty else {
			return
		}

		let identities = selectedNotifications.map { UserNotificationIdentity(id: $0.id) }

		Task { [weak self] in
			guard let self = self else { return }

			do {
				_ = try await KService.deleteNotifications(identities).response()
				self.removeNotifications(selectedNotifications)
				self.setEditing(false, animated: true)
			} catch let error as APIError {
				self.presentAlertController(title: L10n.couldNotRemoveNotifications, message: error.message)
			} catch {
				self.presentAlertController(title: L10n.couldNotRemoveNotifications, message: error.localizedDescription)
			}
		}
	}
}
