//
//  ManageActiveSessionsController+EditMode.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension ManageActiveSessionsController {
	// MARK: - Properties
	/// The sessions currently selected in batch-edit mode.
	private var selectedSessions: [ItemKind] {
		guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
			return []
		}
		return selectedIndexPaths.compactMap { self.dataSource.itemIdentifier(for: $0) }
	}

	/// The total number of sessions that can be signed out, excluding the current device.
	private var totalOtherSessionCount: Int {
		let otherAppSessions = self.appSessions.filter { $0.id != self.currentAccessToken?.id }
		return otherAppSessions.count + self.webSessions.count
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
		self.selectionCountLabel.text = L10n.selectItems

		self.deleteBatchBarButtonItem.tintColor = .systemRed
		self.deleteBatchBarButtonItem.primaryAction = UIAction(image: UIImage(systemName: "trash")) { [weak self] _ in
			guard let self = self else { return }
			self.confirmBatchSignOut(selectedSessions: self.selectedSessions)
		}
	}

	/// Activates the batch-edit chrome.
	///
	/// - Parameter animated: A boolean value that indicates whether the chrome change is animated.
	func enterBatchEditChrome(animated: Bool) {
		guard !self.batchEditIsActive else { return }
		self.batchEditIsActive = true

		self.savedRightBarButtonItems = self.navigationItem.rightBarButtonItems
		self.savedLeftBarButtonItems = self.navigationItem.leftBarButtonItems

		self.refreshSelectAllBarButtonItem(allSelected: false, hasItems: self.totalOtherSessionCount > 0)
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
		let totalLoaded = self.totalOtherSessionCount
		let allSelected = totalLoaded > 0 && selectedCount >= totalLoaded
		self.refreshSelectAllBarButtonItem(allSelected: allSelected, hasItems: totalLoaded > 0)
	}

	/// Selects every loaded session, excluding the current device.
	private func selectAllLoadedSessions() {
		let snapshot = self.dataSource.snapshot()

		for sectionIdentifier in snapshot.sectionIdentifiers where sectionIdentifier != .current {
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

	/// Deselects every selected session.
	private func deselectAllVisibleSessions() {
		self.tableView.indexPathsForSelectedRows?.forEach { indexPath in
			self.tableView.deselectRow(at: indexPath, animated: false)
		}
		self.didUpdateBatchSelection()
	}

	/// Updates the count label and the enabled state of the batch sign-out action.
	private func refreshBatchActionToolbar() {
		let count = self.selectedSessions.count
		let hasSelection = count > 0

		self.selectionCountLabel.text = hasSelection ? L10n.itemsSelected(count) : L10n.selectItems
		self.deleteBatchBarButtonItem.isEnabled = hasSelection
	}

	/// Updates the select-all bar button item's state.
	///
	/// - Parameters:
	///    - allSelected: A boolean value that indicates whether every other session is selected.
	///    - hasItems: A boolean value that indicates whether the list has any selectable sessions.
	private func refreshSelectAllBarButtonItem(allSelected: Bool, hasItems: Bool) {
		self.selectAllBarButtonItem.title = allSelected ? L10n.deselectAll : L10n.selectAll
		self.selectAllBarButtonItem.isEnabled = hasItems
		self.selectAllBarButtonItem.primaryAction = UIAction(title: self.selectAllBarButtonItem.title ?? "") { [weak self] _ in
			guard let self = self else { return }

			if allSelected {
				self.deselectAllVisibleSessions()
			} else {
				self.selectAllLoadedSessions()
			}
		}
	}

	/// Asks for the password before signing out the selected sessions.
	///
	/// - Parameter selectedSessions: The sessions currently selected.
	private func confirmBatchSignOut(selectedSessions: [ItemKind]) {
		guard !selectedSessions.isEmpty else { return }

		self.presentPasswordAlert(title: L10n.signOut, message: L10n.signOutSessionsConfirmation) { [weak self] password in
			self?.performBatchSignOut(selectedSessions: selectedSessions, password: password)
		}
	}

	/// Asks for the password before signing out every other session.
	func confirmSignOutAllOtherSessions() {
		self.presentPasswordAlert(title: L10n.signOutAllOtherSessions, message: L10n.signOutAllOtherSessionsConfirmation) { [weak self] password in
			self?.performSignOutAllOtherSessions(password: password)
		}
	}

	/// Presents an alert that collects the account password before a destructive sign-out.
	///
	/// - Parameters:
	///    - title: The alert's title.
	///    - message: The alert's message.
	///    - handler: A closure called with the entered password when the user confirms.
	private func presentPasswordAlert(title: String, message: String, handler: @escaping (String) -> Void) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

		alertController.addTextField { textField in
			textField.placeholder = L10n.password
			textField.isSecureTextEntry = true
			textField.textContentType = .password
		}

		let confirmAction = UIAlertAction(title: L10n.signOut, style: .destructive) { _ in
			handler(alertController.textFields?.first?.text ?? "")
		}
		alertController.addAction(confirmAction)
		alertController.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))

		self.present(alertController, animated: true)
	}

	/// Signs out the selected sessions and exits edit mode on success.
	///
	/// - Parameters:
	///    - selectedSessions: The sessions currently selected.
	///    - password: The account password confirming the action.
	private func performBatchSignOut(selectedSessions: [ItemKind], password: String) {
		var accessTokens: [AccessToken] = []
		var sessionIdentities: [SessionIdentity] = []

		for item in selectedSessions {
			switch item {
			case .accessToken(let accessToken):
				accessTokens.append(accessToken)
			case .sessionIdentity(let sessionIdentity):
				sessionIdentities.append(sessionIdentity)
			}
		}

		Task { [weak self] in
			guard let self = self else { return }

			do {
				if !accessTokens.isEmpty {
					_ = try await KService.deleteAccessTokens(accessTokens, password: password).response()
					let signedOutIDs = Set(accessTokens.map { $0.id })
					self.appSessions.removeAll { signedOutIDs.contains($0.id) }
				}

				if !sessionIdentities.isEmpty {
					_ = try await KService.deleteSessions(sessionIdentities, password: password).response()
					let signedOutIDs = Set(sessionIdentities.map { $0.id })
					self.webSessions.removeAll { signedOutIDs.contains($0.id) }
				}

				self.updateDataSource()
				self.createAnnotations()
				self.setEditing(false, animated: true)
			} catch let error as APIError {
				self.presentAlertController(title: L10n.couldNotSignOutSessions, message: error.message)
			} catch {
				self.presentAlertController(title: L10n.couldNotSignOutSessions, message: error.localizedDescription)
			}
		}
	}

	/// Signs out every session except the current device.
	///
	/// - Parameter password: The account password confirming the action.
	private func performSignOutAllOtherSessions(password: String) {
		Task { [weak self] in
			guard let self = self else { return }

			do {
				_ = try await KService.deleteAllAccessTokens(password: password).response()
				_ = try await KService.deleteAllSessions(password: password).response()

				let currentAccessTokenID = self.currentAccessToken?.id
				self.appSessions.removeAll { $0.id != currentAccessTokenID }
				self.webSessions.removeAll()

				self.updateDataSource()
				self.createAnnotations()
				self.setEditing(false, animated: true)
			} catch let error as APIError {
				self.presentAlertController(title: L10n.couldNotSignOutSessions, message: error.message)
			} catch {
				self.presentAlertController(title: L10n.couldNotSignOutSessions, message: error.localizedDescription)
			}
		}
	}
}
