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

		// Create "Favorites" element
		let favoritesAction = UIAction(title: Trans.favorites, image: UIImage(systemName: "heart.circle")) { _ in
			self.openFavorites(on: viewController)
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
			self.openShareSheet(on: viewController)
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
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		let shareText = "https://kurozora.app/profile/\(self.attributes.slug)\nFollow \(self.attributes.username) via @KurozoraApp"
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

	/// Performs segue to `FavoritesCollectionViewController` with `FavoritesSegue` as the identifier.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	fileprivate func openFavorites(on viewController: UIViewController? = UIApplication.topViewController) {
		if let favoritesCollectionViewController = R.storyboard.favorites.favoritesCollectionViewController() {
			favoritesCollectionViewController.user = self

			viewController?.show(favoritesCollectionViewController, sender: nil)
		}
	}

	/// Performs segue to `RemindersCollectionViewController` with `RemindersSegue` as the identifier.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	fileprivate func openReminders(on viewController: UIViewController? = UIApplication.topViewController) {
		if let remindersCollectionViewController = R.storyboard.reminders.remindersCollectionViewController() {
			viewController?.show(remindersCollectionViewController, sender: nil)
		}
	}
}
