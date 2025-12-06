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
			ProfileTableViewController.`init`(with: self.id)
		}, actionProvider: { _ in
			self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		})
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
		let libraryAction = UIAction(title: Trans.library, image: UIImage(systemName: "rectangle.stack")) { _ in
			self.openLibrary(on: viewController)
		}
		menuElements.append(libraryAction)

		// Create "Favorites" element
		let includeUser = userInfo?["includeUser"] as? Bool ?? true
		let favoritesAction = UIAction(title: Trans.favorites, image: UIImage(systemName: "heart.circle")) { _ in
			self.openFavorites(on: viewController, includeUser: includeUser)
		}
		menuElements.append(favoritesAction)

		if User.current?.id == self.id {
			// Create "Reminders" element
			let remindersAction = UIAction(title: Trans.reminders, image: UIImage(systemName: "bell.circle")) { _ in
				self.openReminders(on: viewController)
			}
			menuElements.append(remindersAction)

			// Create "Settings" element
			let settingsAction = UIAction(title: Trans.settings, image: UIImage(systemName: "gear")) { _ in
				self.openSettings(on: viewController)
			}
			menuElements.append(settingsAction)
		}

		// Block action
		if User.isSignedIn, User.current?.id != self.id {
			let blockAction = UIAction(title: Trans.block, image: UIImage(systemName: "xmark.shield")) { [weak self] _ in
				guard let self = self else { return }
				self.confirmBlock(via: viewController, userInfo: userInfo)
			}
			menuElements.append(blockAction)
		}

		// Create "Share" element
		let shareAction = UIAction(title: Trans.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { [weak self] _ in
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
			let followUpdateResponse = try await KService.updateFollowStatus(forUser: userIdentity).value
			self.attributes.update(using: followUpdateResponse.data)
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	@MainActor
	private func block(on viewController: UIViewController?) async {
		let userIdentity = UserIdentity(id: self.id)
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		do {
			let blockUpdateResponse = try await KService.updateBlockStatus(forUser: userIdentity).value
			self.attributes.update(using: blockUpdateResponse.data)
		} catch {
			print("-----", error.localizedDescription)
		}
	}

	/// Confirm if the user wants to block the message.
	func confirmBlock(via viewController: UIViewController? = nil, userInfo: [AnyHashable: Any]?) {
		let actionSheetAlertController = UIAlertController.alert(title: "Block @\(self.attributes.username)", message: Trans.blockMessageSubheadline) { alertController in
			let blockAction = UIAlertAction(title: Trans.block, style: .destructive) { [weak self] _ in
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
		if let libraryViewController = R.storyboard.library.libraryViewController() {
			libraryViewController.user = self

			viewController?.show(libraryViewController, sender: nil)
		}
	}

	/// Performs segue to `FavoritesCollectionViewController`.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - includeUser: A boolean value indicating whether to pass the user to `FavoritesCollectionViewController`.
	func openFavorites(on viewController: UIViewController? = UIApplication.topViewController, includeUser: Bool) {
		if let favoritesCollectionViewController = R.storyboard.favorites.favoritesCollectionViewController() {
			if includeUser {
				favoritesCollectionViewController.user = self
			}

			viewController?.show(favoritesCollectionViewController, sender: nil)
		}
	}

	/// Performs segue to `RemindersCollectionViewController`.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	func openReminders(on viewController: UIViewController? = UIApplication.topViewController) {
		if let remindersCollectionViewController = R.storyboard.reminders.remindersCollectionViewController() {
			viewController?.show(remindersCollectionViewController, sender: nil)
		}
	}

	/// Performs segue to `SettingsSplitViewController`.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	func openSettings(on viewController: UIViewController? = UIApplication.topViewController) {
		if let settingsSplitViewController = R.storyboard.settings.instantiateInitialViewController() {
			settingsSplitViewController.modalPresentationStyle = .fullScreen
			viewController?.present(settingsSplitViewController, animated: true)
		}
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

		// Create "Layout" element
		let index = userInfo?["index"] as? Int ?? 0
		let libraryStatus = KKLibrary.Status.all[index]
		let libraryCellStyles = UserSettings.libraryCellStyles[libraryStatus.sectionValue] ?? 0
		let layoutActions = KKLibrary.CellStyle.all.map { style in
			let action = UIAction(title: style.stringValue, image: style.imageValue, state: style.rawValue == libraryCellStyles ? .on : .off) { _ in
				viewController.changeLayout(to: style)
			}
			return action
		}
		let subMenu = UIMenu(title: "", options: .displayInline, children: layoutActions)
		menuElements.append(subMenu)

		// Create "Favorites" element
		let includeUser = userInfo?["includeUser"] as? Bool ?? true
		let favoritesAction = UIAction(title: Trans.favorites, image: UIImage(systemName: "heart.circle")) {  [weak self] _ in
			guard let self = self else { return }
			self.openFavorites(on: viewController, includeUser: includeUser)
		}
		menuElements.append(favoritesAction)

		if User.current?.id == self.id {
			// Create "Reminders" element
			let remindersAction = UIAction(title: Trans.reminders, image: UIImage(systemName: "bell.circle")) {  [weak self] _ in
				guard let self = self else { return }
				self.openReminders(on: viewController)
			}
			menuElements.append(remindersAction)
		}

		// Create "Share" element
		let shareAction = UIAction(title: Trans.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { [weak self] _ in
			guard let self = self else { return }
			var activityItems: [Any] = []
			activityItems.append("https://kurozora.app/profile/\(self.attributes.slug)/\(UserSettings.libraryKind.urlPathName)")
			activityItems.append("Check out \(self.attributes.username)’s library via @KurozoraApp")

			self.openShareSheet(activityItems: activityItems, on: viewController, sourceView: sourceView, barButtonItem: barButtonItem)
		}
		menuElements.append(shareAction)

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}
}
