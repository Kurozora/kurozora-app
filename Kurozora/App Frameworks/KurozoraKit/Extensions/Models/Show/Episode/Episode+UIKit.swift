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

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: { [weak self] in
			guard let self = self else { return nil }
			return EpisodeDetailCollectionViewController.`init`(with: self.id)
		}, actionProvider: { [weak self] _ in
			guard let self = self else { return nil }
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		})
	}

	private func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		if User.isSignedIn {
			// Create "update watch status" element
			let watchStatus = self.attributes.watchStatus ?? .notWatched
			let updateWatchStatusTitle = watchStatus == .notWatched ? "Mark as Watched" : "Mark as Un-watched"
			let updateWatchStatusImage = watchStatus == .notWatched ? UIImage(systemName: "plus.circle") : UIImage(systemName: "minus.circle")
			let attributes: UIAction.Attributes = watchStatus == .notWatched ? [] : .destructive

			let watchAction = UIAction(title: updateWatchStatusTitle, image: updateWatchStatusImage, attributes: attributes) { [weak self] _ in
				guard let self = self else { return }
				self.updateWatchStatus(userInfo: userInfo)
			}
			menuElements.append(watchAction)
		}

//		// Create "rate" element
//		let rateAction = UIAction(title: "Rate", image: UIImage(systemName: "star.circle")) { [weak self] _ in
//			// TODO: - Implement rate episode feature.
//			guard let self = self else { return }
//			self.rate(using: 1.0)
//		}
//		menuElements.append(rateAction)

		// Create "share" element
		let shareAction = UIAction(title: Trans.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { [weak self] _ in
			guard let self = self else { return }
			self.openShareSheet(on: viewController)
		}
		menuElements.append(shareAction)

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}

	/// Updates the watch status of the episode.
	///
	/// - Parameter userInfo: A dictionary that contains information related to the notification.
	func updateWatchStatus(userInfo: [AnyHashable: Any]?) {
		let episodeIdentity = EpisodeIdentity(id: self.id)

		KService.updateEpisodeWatchStatus(episodeIdentity) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let watchStatus):
				// Update watch status
				self.attributes = self.attributes.updated(using: watchStatus)

				NotificationCenter.default.post(name: .KEpisodeWatchStatusDidUpdate, object: nil, userInfo: userInfo)
			case .failure: break
			}
		}
	}

	/// Present share sheet for the episode.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - view: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		let shareText = "https://kurozora.app/episodes/\(self.id)\nYou should watch \"\(self.attributes.title)\" via @KurozoraApp"

		var activityItems: [Any] = []
		activityItems.append(shareText)
		if let episodeImage = self.attributes.banner?.url {
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

	/// Rate the show with the given rating.
	///
	/// - Parameter rating: The rating to be saved when the show has been rated by the user.
	func rate(using rating: Double) {
		let episodeIdentity = EpisodeIdentity(id: self.id)
		KService.rateEpisode(episodeIdentity, with: rating, description: nil) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success:
					// Update current rating for the user.
				self.attributes.givenRating = rating

					// Show a success alert thanking the user for rating.
				let alertController = UIApplication.topViewController?.presentAlertController(title: "Rating Submitted", message: "Thank you for rating.")

				DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
					alertController?.dismiss(animated: true, completion: nil)
				}
			case .failure: break
			}
		}
	}
}
