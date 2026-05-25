//
//  User+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension User {
	/// The webpage URL of the user.
	var webpageURLString: String {
		return "https://kurozora.app/profile/\(self.attributes.slug)"
	}

	/// Create a context menu configuration for the user.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIContextMenuConfiguration` representing the context menu for the user.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			ProfileTableViewController()(with: self.id)
		}, actionProvider: { _ in
			self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		})
	}

	/// Create a context menu configuration for a row in the blocked users list.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///
	/// - Returns: A `UIContextMenuConfiguration` whose only action toggles the user's block state.
	func blockedRowContextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIContextMenuConfiguration {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { [weak self] _ in
			guard let self = self else { return UIMenu(title: "") }
			return self.makeBlockedRowContextMenu(in: viewController, userInfo: userInfo)
		}
	}

	/// Create the menu shown for a row in the blocked users list.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///
	/// - Returns: A `UIMenu` containing the block-toggle action.
	func makeBlockedRowContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
		let isBlocked = self.attributes.blockStatus == .blocked
		let title = isBlocked ? L10n.unblock : L10n.block
		let imageName = isBlocked ? "checkmark.shield" : "xmark.shield"

		let toggleAction = UIAction(title: title, image: UIImage(systemName: imageName)) { [weak self] _ in
			guard let self = self else { return }
			self.confirmBlock(via: viewController, userInfo: userInfo)
		}

		return UIMenu(title: "", children: [toggleAction])
	}

	/// Create a context menu for the user.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the user.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// Create "Library" element
		let libraryAction = UIAction(title: L10n.library, image: UIImage(systemName: "rectangle.stack")) { _ in
			self.openLibrary(on: viewController)
		}
		menuElements.append(libraryAction)

		// Create "Favorites" element
		let includeUser = userInfo?["includeUser"] as? Bool ?? true
		let favoritesAction = UIAction(title: L10n.favorites, image: UIImage(systemName: "heart.circle")) { _ in
			self.openFavorites(on: viewController, includeUser: includeUser)
		}
		menuElements.append(favoritesAction)

		if User.current?.id == self.id {
			// Create "Reminders" element
			let remindersAction = UIAction(title: L10n.reminders, image: UIImage(systemName: "bell.circle")) { _ in
				self.openReminders(on: viewController)
			}
			menuElements.append(remindersAction)

			// Create "Settings" element
			let settingsAction = UIAction(title: L10n.settings, image: UIImage(systemName: "gear")) { _ in
				self.openSettings(on: viewController)
			}
			menuElements.append(settingsAction)
		}

		// Block action
		if User.isSignedIn, User.current?.id != self.id {
			let isBlocked = self.attributes.blockStatus == .blocked
			let title = isBlocked ? L10n.unblock : L10n.block
			let imageName = isBlocked ? "checkmark.shield" : "xmark.shield"
			let blockAction = UIAction(title: title, image: UIImage(systemName: imageName)) { [weak self] _ in
				guard let self = self else { return }
				self.confirmBlock(via: viewController, userInfo: userInfo)
			}
			menuElements.append(blockAction)
		}

		// Mod actions
		menuElements.append(contentsOf: self.makeModerationMenuElements(in: viewController, userInfo: userInfo))

		// Create "Share" element
		let shareAction = UIAction(title: L10n.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { [weak self] _ in
			guard let self = self else { return }
			var activityItems: [Any] = []
			activityItems.append(self.webpageURLString)
			activityItems.append("Follow \(self.attributes.username) via @KurozoraApp")

			self.openShareSheet(activityItems: activityItems, on: viewController, sourceView: sourceView, barButtonItem: barButtonItem)
		}
		menuElements.append(shareAction)

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}

	/// Present share sheet for the user.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - activityItems: The items to share.
	///    - viewController: The view controller presenting the share sheet.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func openShareSheet(activityItems: [Any], on viewController: UIViewController? = UIApplication.topViewController, sourceView: UIView?, barButtonItem: UIBarButtonItem?) {
		var activityItems: [Any] = []
		activityItems.append(self.webpageURLString)
		activityItems.append("Follow \(self.attributes.username) via @KurozoraApp")

		if let profileImageView = self.attributes.profileImageView.image {
			activityItems.append(profileImageView)
		}

		let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			if let sourceView = sourceView {
				popoverController.sourceView = sourceView
				popoverController.sourceRect = sourceView.frame
			} else {
				popoverController.barButtonItem = barButtonItem
			}
		}

		viewController?.present(activityViewController, animated: true, completion: nil)
	}

	@MainActor
	func follow(on viewController: UIViewController?) async {
		let userIdentity = UserIdentity(id: self.id)
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		do {
			let followUpdateResponse = try await KService.toggleFollow(userIdentity).response()
			self.attributes.update(using: followUpdateResponse.data)
		} catch let error as APIError {
			viewController?.presentAlertController(title: nil, message: error.message)
			print("-----", error.localizedDescription)
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	/// Toggles the block status of the user, posting `KUserBlockStatusDidChange` on success.
	///
	/// - Parameter viewController: The view controller presenting the request, used to surface the sign-in flow if needed.
	@MainActor
	func block(on viewController: UIViewController?) async {
		let userIdentity = UserIdentity(id: self.id)
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		do {
			let blockUpdateResponse = try await KService.toggleBlock(userIdentity).response()
			self.attributes.update(using: blockUpdateResponse.data)
			NotificationCenter.default.post(name: .KUserBlockStatusDidChange, object: self.id)
		} catch let error as APIError {
			viewController?.presentAlertController(title: nil, message: error.message)
			print("-----", error.localizedDescription)
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	/// Confirm if the user wants to block the message.
	func confirmBlock(via viewController: UIViewController? = nil, userInfo: [AnyHashable: Any]?) {
		let isBlocked = self.attributes.blockStatus == .blocked
		let title = isBlocked
			? L10n.unblockTitle("@\(self.attributes.slug)")
			: L10n.blockTitle("@\(self.attributes.slug)")
		let actionTitle = isBlocked ? L10n.unblock : L10n.block
		let actionStyle: UIAlertAction.Style = isBlocked ? .default : .destructive

		let actionSheetAlertController = UIAlertController.alert(title: title, message: L10n.blockMessageSubheadline) { alertController in
			let blockAction = UIAlertAction(title: actionTitle, style: actionStyle) { [weak self] _ in
				guard let self = self else { return }
				Task {
					await self.block(on: viewController)
				}
			}
			alertController.addAction(blockAction)
		}

		if let popoverController = actionSheetAlertController.popoverPresentationController {
			if let view = viewController?.view {
				popoverController.sourceView = view
				popoverController.sourceRect = view.frame
			}
		}

		if (viewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			viewController?.present(actionSheetAlertController, animated: true, completion: nil)
		}
	}

	/// Performs segue to `LibraryViewController`.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	func openLibrary(on viewController: UIViewController? = UIApplication.topViewController) {
		let libraryViewController = LibraryViewController()
		libraryViewController.user = self

		viewController?.show(libraryViewController, sender: nil)
	}

	/// Performs segue to `FavoritesCollectionViewController`.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - includeUser: A boolean value indicating whether to pass the user to `FavoritesCollectionViewController`.
	func openFavorites(on viewController: UIViewController? = UIApplication.topViewController, includeUser: Bool) {
		let favoritesCollectionViewController = FavoritesCollectionViewController()
		if includeUser {
			favoritesCollectionViewController.user = self
		}

		viewController?.show(favoritesCollectionViewController, sender: nil)
	}

	/// Performs segue to `RemindersCollectionViewController`.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	func openReminders(on viewController: UIViewController? = UIApplication.topViewController) {
		let remindersCollectionViewController = RemindersCollectionViewController()
		viewController?.show(remindersCollectionViewController, sender: nil)
	}

	/// Performs segue to `SettingsSplitViewController`.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	func openSettings(on viewController: UIViewController? = UIApplication.topViewController) {
		let settingsSplitViewController = SettingsSplitViewController()
		settingsSplitViewController.modalPresentationStyle = .fullScreen
		viewController?.present(settingsSplitViewController, animated: true)
	}

	/// Builds the moderation section of the user context menu.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the menu.
	///    - userInfo: Additional information about the context menu.
	///
	/// - Returns: An element array containing the moderation submenu.
	func makeModerationMenuElements(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> [UIMenuElement] {
		guard User.isSignedIn, User.current?.id != self.id, User.current?.attributes.isModerator == true else {
			return []
		}

		var actions: [UIMenuElement] = []

		let issueTimeoutAction = UIAction(
			title: L10n.issueTimeout,
			image: UIImage(systemName: "clock.badge.exclamationmark")
		) { [weak self] _ in
			guard let self = self else { return }
			self.presentIssueTimeoutForm(on: viewController)
		}
		actions.append(issueTimeoutAction)

		if self.relationships?.timeout?.data.first != nil {
			let revokeTimeoutAction = UIAction(
				title: L10n.revokeTimeout,
				image: UIImage(systemName: "checkmark.seal"),
				attributes: .destructive
			) { [weak self] _ in
				guard let self = self else { return }
				self.confirmRevokeTimeout(via: viewController)
			}
			actions.append(revokeTimeoutAction)
		}

		return [UIMenu(title: "", options: .displayInline, children: actions)]
	}

	/// Presents the moderator issue-timeout compose flow against this user.
	///
	/// - Parameter viewController: The view controller from which to present the form.
	func presentIssueTimeoutForm(on viewController: UIViewController?) {
		let composeViewController = IssueTimeoutCollectionViewController()
		composeViewController.targetUser = self
		let navigationController = UINavigationController(rootViewController: composeViewController)
		viewController?.present(navigationController, animated: true)
	}

	/// Confirms revocation of the active timeout before issuing the request.
	///
	/// - Parameter viewController: The view controller presenting the confirmation alert.
	func confirmRevokeTimeout(via viewController: UIViewController?) {
		let title = L10n.confirmRevokeTimeoutTitle(self.attributes.username)
		let message = L10n.confirmRevokeTimeoutMessage

		let alertController = UIAlertController.alert(title: title, message: message) { alertController in
			let revokeAction = UIAlertAction(title: L10n.revokeTimeout, style: .destructive) { [weak self] _ in
				guard let self = self else { return }
				Task { await self.revokeTimeout(on: viewController) }
			}
			alertController.addAction(revokeAction)
		}

		if let popoverController = alertController.popoverPresentationController, let view = viewController?.view {
			popoverController.sourceView = view
			popoverController.sourceRect = view.frame
		}

		if (viewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			viewController?.present(alertController, animated: true, completion: nil)
		}
	}

	/// Revokes the active moderation timeout on this user.
	///
	/// - Parameter viewController: The view controller used to surface any error alert.
	@MainActor
	func revokeTimeout(on viewController: UIViewController?) async {
		let userIdentity = UserIdentity(id: self.id)

		do {
			_ = try await KService.revokeTimeout(userIdentity).response()
			NotificationCenter.default.post(name: .KUserTimeoutDidChange, object: self.id)
		} catch let error as APIError {
			viewController?.presentAlertController(title: nil, message: error.message)
			print("-----", error.localizedDescription)
		} catch {
			print("-----", error.localizedDescription)
		}
	}
}

// MARK: - Moderation
extension User.Attributes {
	/// Whether the user currently holds a moderation role.
	var isModerator: Bool {
		guard let role = self.role else { return false }
		return role == .superAdmin || role == .admin || role == .mod
	}
}

// MARK: - Library
extension User {
	/// Create a context menu for the user's library.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the game.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func makeLibraryContextMenu(in viewController: LibraryViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// Create "Edit" element — deferred so its visibility reflects the live item count
		// of the currently visible page each time the menu opens, rather than the count at
		// menu-build time (which is typically before items have loaded).
		let userID = self.id
		let editDeferred = UIDeferredMenuElement.uncached { [weak viewController] completion in
			guard
				let viewController = viewController,
				User.current?.id == userID,
				let currentSection = viewController.currentViewController as? LibraryListCollectionViewController,
				currentSection.totalLibraryItemsCount > 0
			else {
				completion([])
				return
			}

			let editAction = UIAction(title: L10n.edit, image: UIImage(systemName: "checkmark.circle")) { [weak viewController] _ in
				viewController?.setEditing(true, animated: true)
			}
			completion([editAction])
		}
		let editMenu = UIMenu(title: "", options: .displayInline, children: [editDeferred])
		menuElements.append(editMenu)

		// Create "Layout" element
		let index = userInfo?["index"] as? Int ?? 0
		let libraryStatus = LibraryStatus.all[index]
		let libraryKindRaw = userInfo?["libraryKind"] as? Int ?? UserSettings.libraryKind.rawValue
		let libraryKind = LibraryKind(rawValue: libraryKindRaw) ?? UserSettings.libraryKind
		let currentSection = viewController.currentViewController as? LibraryListCollectionViewController
		let activeCellStyle = currentSection?.libraryCellStyle ?? UserSettings.libraryCellStyle(for: libraryKind, status: libraryStatus)
		let layoutActions = LibraryCellStyle.all.map { style in
			let action = UIAction(title: style.stringValue, image: style.imageValue, state: style == activeCellStyle ? .on : .off) { _ in
				viewController.changeLayout(to: style)
			}
			return action
		}
		let subMenu = UIMenu(title: "", options: .displayInline, children: layoutActions)
		menuElements.append(subMenu)

		// Create "View Options" element
		if activeCellStyle == .table, let currentSection {
			let viewOptionsMenu = LibraryColumnMenuBuilder.makeMenu(
				kind: libraryKind,
				fetch: { [weak currentSection] in
					currentSection?.libraryColumnPreferences ?? .defaultShared
				},
				apply: { [weak viewController] updated in
					viewController?.applyColumnPreferencesToCurrentSection(updated)
				}
			)

			let iconViewOptions = UIMenu(title: L10n.viewOptions, image: UIImage(systemName: "slider.horizontal.3"), children: viewOptionsMenu.children)
			menuElements.append(iconViewOptions)
		} else if activeCellStyle == .compact, let currentSection {
			let compactOptionsMenu = LibraryCompactViewOptionsBuilder.makeMenu(
				fetch: { [weak currentSection] in
					currentSection?.libraryCompactTitleVisibility ?? .always
				},
				apply: { [weak viewController] visibility in
					viewController?.applyCompactTitleVisibilityToCurrentSection(visibility)
				}
			)

			let iconViewOptions = UIMenu(title: L10n.viewOptions, image: UIImage(systemName: "slider.horizontal.3"), options: .singleSelection, children: compactOptionsMenu.children)
			menuElements.append(iconViewOptions)
		}

		var otherMenuElements: [UIMenuElement] = []
		// Create "Favorites" element
		let includeUser = userInfo?["includeUser"] as? Bool ?? true
		let favoritesAction = UIAction(title: L10n.favorites, image: UIImage(systemName: "heart.circle")) {  [weak self] _ in
			guard let self = self else { return }
			self.openFavorites(on: viewController, includeUser: includeUser)
		}
		otherMenuElements.append(favoritesAction)

		if User.current?.id == self.id {
			// Create "Reminders" element
			let remindersAction = UIAction(title: L10n.reminders, image: UIImage(systemName: "bell.circle")) {  [weak self] _ in
				guard let self = self else { return }
				self.openReminders(on: viewController)
			}
			otherMenuElements.append(remindersAction)
		}

		// Create "Share" element
		let shareAction = UIAction(title: L10n.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { [weak self] _ in
			guard let self = self else { return }
			var activityItems: [Any] = []
			activityItems.append("https://kurozora.app/profile/\(self.attributes.slug)/\(UserSettings.libraryKind.urlPathName)")
			activityItems.append("Check out \(self.attributes.username)’s library via @KurozoraApp")

			self.openShareSheet(activityItems: activityItems, on: viewController, sourceView: sourceView, barButtonItem: barButtonItem)
		}
		otherMenuElements.append(shareAction)

		// Create and return a UIMenu
		menuElements.append(UIMenu(title: "", options: .displayInline, children: otherMenuElements))
		return UIMenu(title: "", children: menuElements)
	}
}
