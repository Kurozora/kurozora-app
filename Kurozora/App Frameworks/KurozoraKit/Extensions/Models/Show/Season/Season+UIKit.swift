//
//  Season+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension Season {
	/// The webpage URL of the season.
	var webpageURLString: String {
		return "https://kurozora.app/seasons/\(self.id)"
	}

	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?)
	-> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: { [weak self] in
			guard let self = self else { return nil }
			return EpisodesListCollectionViewController.`init`(with: self.id)
		}, actionProvider: { [weak self] _ in
			guard let self = self else { return nil }
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		})
	}

	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		if User.isSignedIn {
			// Create "update watch status" element
			let watchStatus = self.attributes.watchStatus

			if watchStatus != .disabled {
				let updateWatchStatusTitle = watchStatus == .watched ? Trans.markAllUnwatched : Trans.markAllWatched
				let updateWatchStatusImage = watchStatus == .watched ? UIImage(systemName: "eye.slash.fill") : UIImage(systemName: "eye.fill")
				let attributes: UIAction.Attributes = watchStatus == .notWatched ? [] : .destructive

				let watchAction = UIAction(title: updateWatchStatusTitle, image: updateWatchStatusImage, attributes: attributes) { [weak self] _ in
					guard let self = self else { return }
					Task {
						await self.updateWatchStatus(userInfo: userInfo)
					}
				}
				menuElements.append(watchAction)
			}
		}

		// Create "share" menu
		var shareMenuChildren: [UIMenuElement] = []
		let copyTitleAction = UIAction(title: "Copy Title", image: UIImage(systemName: "document.on.document.fill")) { [weak self] _ in
			guard let self = self else { return }
			UIPasteboard.general.string = self.attributes.title
		}
		let copyLinkAction = UIAction(title: "Copy Link", image: UIImage(systemName: "document.on.document.fill")) { [weak self] _ in
			guard let self = self else { return }
			UIPasteboard.general.string = self.webpageURLString
		}
		let shareAction = UIAction(title: Trans.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { [weak self] _ in
			guard let self = self else { return }
			self.openShareSheet(on: viewController)
		}
		shareMenuChildren.append(copyTitleAction)
		shareMenuChildren.append(copyLinkAction)
		shareMenuChildren.append(shareAction)

		let shareMenu = UIMenu(title: "", options: .displayInline, children: shareMenuChildren)
		menuElements.append(shareMenu)

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}

	/// Updates the watch status of the season.
	///
	/// - Parameter userInfo: A dictionary that contains information related to the notification.
	func updateWatchStatus(userInfo: [AnyHashable: Any]?) async {
		do {
			let seasonIdentity = SeasonIdentity(id: self.id)
			let seasonUpdateResponse = try await KService.updateSeasonWatchStatus(seasonIdentity).value
			let watchStatus = seasonUpdateResponse.data.watchStatus

			// Update watch status
			self.attributes = self.attributes.updated(using: watchStatus)

			NotificationCenter.default.post(name: .KSeasonWatchStatusDidUpdate, object: nil, userInfo: userInfo)
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Present share sheet for the season.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - view: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		let shareText = "\(self.webpageURLString)/episodes\nYou should watch \"\(self.attributes.title)\" season via @KurozoraApp"
		let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: [])

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
}
