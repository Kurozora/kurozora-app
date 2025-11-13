//
//  Episode+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Episode {
	/// The webpage URL of the episode.
	var webpageURLString: String {
		return "https://kurozora.app/episodes/\(self.id)"
	}

	/// Create a context menu configuration for the episode.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIContextMenuConfiguration` representing the context menu for the episode.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	@MainActor
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?)
		-> UIContextMenuConfiguration?
	{
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: { [weak self] in
			guard let self = self else { return nil }
			return EpisodeDetailsCollectionViewController.`init`(with: self.id)
		}, actionProvider: { [weak self] _ in
			guard let self = self else { return nil }
			return self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		})
	}

	/// Create a context menu for the episode.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the episode.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	@MainActor
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		if User.isSignedIn {
			// Create "update watch status" element
			let watchStatus = self.attributes.watchStatus

			if watchStatus != .disabled {
				let updateWatchStatusTitle = watchStatus == .watched ? Trans.markAsUnwatched : Trans.markAsWatched
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

	/// Updates the watch status of the episode.
	///
	/// - Parameter userInfo: A dictionary that contains information related to the notification.
	func updateWatchStatus(userInfo: [AnyHashable: Any]?) async {
		do {
			let episodeIdentity = EpisodeIdentity(id: self.id)
			let episodeUpdateResponse = try await KService.updateEpisodeWatchStatus(episodeIdentity).value
			let watchStatus = episodeUpdateResponse.data.watchStatus

			// Update watch status
			self.attributes = self.attributes.updated(using: watchStatus)

			NotificationCenter.default.post(name: .KEpisodeWatchStatusDidUpdate, object: nil, userInfo: userInfo)
		} catch let error as KKAPIError {
			await UIApplication.topViewController?.presentAlertController(title: Trans.addToLibrary, message: error.message)
			print("----- Update episode watch status failed", error.message)
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Present share sheet for the episode.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, sourceView: UIView?, barButtonItem: UIBarButtonItem?) {
		var activityItems: [Any] = []
		activityItems.append(self.webpageURLString)
		activityItems.append("Track your watch progress of \"\(self.attributes.title)\" via @KurozoraApp")

		if let episodeImage = self.attributes.banner?.url {
			activityItems.append(episodeImage)
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

		if (viewController?.navigationController?.visibleViewController as? UIAlertController) == nil {
			viewController?.present(activityViewController, animated: true, completion: nil)
		}
	}

	/// Rate the episode with the given rating.
	///
	/// - Parameters:
	///    - rating: The rating given by the user.
	///    - description: The review given by the user.
	///
	/// - Returns: the rating applied to the episode if rated successfully.
	func rate(using rating: Double, description: String?) async throws(KKAPIError) -> Double? {
		guard await self.validateIsWatched() else { return nil }
		let episodeIdentity = EpisodeIdentity(id: self.id)

		do {
			_ = try await KService.rateEpisode(episodeIdentity, with: rating, description: description).value

			// Update current rating for the user.
			self.attributes.givenRating = rating

			// Update review only if the user removes it explicitly.
			if description != nil {
				self.attributes.givenReview = description
			}

			return rating
		} catch let error as KKAPIError {
			print(error.localizedDescription)
			throw error
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}

	private func validateIsWatched() async -> Bool {
		if self.attributes.watchStatus == nil {
			await UIApplication.topViewController?.presentAlertController(title: Trans.addToLibrary, message: "Please watch \(self.attributes.title) first.")

			return false
		}

		return true
	}
}
