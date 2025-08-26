//
//  User+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension User {
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?)
	-> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			return ProfileTableViewController.`init`(with: self.id)
		}, actionProvider: { _ in
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		})
	}

	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
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
		let shareAction = UIAction(title: Trans.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
			self.openShareSheet(on: viewController, shareText: "https://kurozora.app/profile/\(self.attributes.slug)\nFollow \(self.attributes.username) via @KurozoraApp")
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
	///    - viewController: The view controller presenting the share sheet.
	///    - view: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, shareText: String, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		var activityItems: [Any] = [shareText]

		if let personalImage = self.attributes.profileImageView.image {
			activityItems.append(personalImage)
		}

		let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: [])

		if let popoverController = activityViewController.popoverPresentationController {
			if let view = view {
				popoverController.sourceView = view
				popoverController.sourceRect = view.frame
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
	func makeLibraryContextMenu(in viewController: LibraryViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
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
		}

		// Create "Share" element
		let shareAction = UIAction(title: Trans.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
			self.openShareSheet(on: viewController, shareText: "https://kurozora.app/profile/\(self.attributes.slug)/\(UserSettings.libraryKind.urlPathName)\nCheck out \(self.attributes.username)’s library via @KurozoraApp")
		}
		menuElements.append(shareAction)

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}
}
