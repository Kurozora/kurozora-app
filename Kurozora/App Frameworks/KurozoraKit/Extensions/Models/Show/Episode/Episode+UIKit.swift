//
//  Episode+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension Episode {
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?)
	-> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			return EpisodeDetailCollectionViewController.`init`(with: self.id)
		}, actionProvider: { _ in
			return self.makeContextMenu(in: viewController)
		})
	}

	private func makeContextMenu(in viewController: UIViewController) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		if User.isSignedIn {
			// Create "update watch status" element
			let watchStatus = self.attributes.watchStatus ?? .notWatched
			let updateWatchStatusTitle = watchStatus == .notWatched ? "Mark as Watched" : "Mark as Un-watched"
			let updateWatchStatusImage = watchStatus == .notWatched ? UIImage(systemName: "plus.circle") : UIImage(systemName: "minus.circle")
			var menuElements: [UIMenuElement] = []

			menuElements.append(UIAction(title: updateWatchStatusTitle, image: updateWatchStatusImage, handler: { _ in
				self.updateWatchStatus()
			}))
		}

		// Create "rate" element
		let rateAction = UIAction(title: "Rate", image: UIImage(systemName: "star.circle")) { _ in
			// TODO: - Implement rate episode feature.
		}
		menuElements.append(rateAction)

		// Create "share" element
		let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
			self.openShareSheet(on: viewController)
		}
		menuElements.append(shareAction)

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}

	/// Updates the watch status of the episode.
	func updateWatchStatus() {
		KService.updateEpisodeWatchStatus(self.id) { result in
			switch result {
			case .success(let watchStatus):
//				self.configureWatchButton(with: watchStatus)
				NotificationCenter.default.post(name: .KEpisodeWatchStatusDidUpdate, object: nil)
			case .failure: break
			}
		}
	}

	/**
		Present share sheet for the episode.

		Make sure to send either the view or the bar button item that's sending the request.

		- Parameter viewController: The view controller presenting the share sheet.
		- Parameter view: The `UIView` sending the request.
		- Parameter barButtonItem: The `UIBarButtonItem` sending the request.
	*/
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		let shareText = "https://kurozora.app/episode/\(self.id)\nYou should watch \"\(self.attributes.title)\" via @KurozoraApp"

		var activityItems: [Any] = []
		activityItems.append(shareText)
		if let episodeImage = self.attributes.previewImage {
			activityItems.append(episodeImage)
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

		if (viewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			viewController?.present(activityViewController, animated: true, completion: nil)
		}
	}
}
