//
//  Episode+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 18/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit
import WidgetKit

extension Episode {
	/// The authenticated user's watch status for the episode.
	@MainActor var watchStatus: WatchStatus? {
		return WatchedStore.shared.status(forEpisodeID: self.id.rawValue)
	}

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
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			return EpisodeDetailsCollectionViewController()(with: self.id)
		}, actionProvider: { _ in
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
			let watchStatus = self.watchStatus
			let updateWatchStatusTitle = watchStatus == .watched ? L10n.markAsUnwatched : L10n.markAsWatched
			let updateWatchStatusImage = watchStatus == .watched ? UIImage(systemName: "eye.slash.fill") : UIImage(systemName: "eye.fill")
			let attributes: UIAction.Attributes = watchStatus == .watched ? .destructive : []

			let watchAction = UIAction(title: updateWatchStatusTitle, image: updateWatchStatusImage, attributes: attributes) { _ in
				Task {
					await self.updateWatchStatus(userInfo: userInfo)
				}
			}
			menuElements.append(watchAction)
		}

		// Create "share" menu
		var shareMenuChildren: [UIMenuElement] = []

		// Create "copy" action
		let copyTitleAction = UIAction(title: L10n.copyTitle, image: UIImage(systemName: "document.on.document.fill")) { _ in
			UIPasteboard.general.string = self.attributes.title
		}
		let copyLinkAction = UIAction(title: L10n.copyLink, image: UIImage(systemName: "document.on.document.fill")) { _ in
			UIPasteboard.general.string = self.webpageURLString
		}
		let copyMenu = UIMenu(title: L10n.copy, image: UIImage(systemName: "doc.on.doc.fill"), children: [copyTitleAction, copyLinkAction])

		// Create "share" action
		let shareAction = UIAction(title: L10n.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
			self.openShareSheet(on: viewController, sourceView: sourceView, barButtonItem: barButtonItem)
		}
		shareMenuChildren.append(copyMenu)
		shareMenuChildren.append(shareAction)

		let shareMenu = UIMenu(title: "", options: .displayInline, children: shareMenuChildren)
		menuElements.append(shareMenu)

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}

	/// Updates the watch status of the episode.
	///
	/// - Parameter userInfo: A dictionary that contains information related to the notification.
	@MainActor
	func updateWatchStatus(userInfo: [AnyHashable: Any]?) async {
		guard let slug = User.current?.attributes.slug else { return }

		await LibraryOutbox.shared.enqueueEpisodeWatchToggle(episodeID: self.id.rawValue, userSlug: slug)

		NotificationCenter.default.post(name: .KEpisodeWatchStatusDidUpdate, object: nil, userInfo: userInfo)
		WidgetCenter.shared.reloadTimelines(ofKind: "app.kurozora.tracker.upNextWidget")
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
		activityItems.append(L10n.shareEpisode(self.attributes.title))

		if let bannerImageURLString = self.attributes.banner?.url ?? self.attributes.poster?.url, !bannerImageURLString.isEmpty {
			activityItems.append(ImageActivityItemProvider(urlString: bannerImageURLString, placeholder: .Placeholders.episodeBanner))
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
	func rate(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard await self.validateIsWatched() else { return nil }
		let episodeIdentity = EpisodeIdentity(id: self.id)

		do {
			_ = try await KService.rate(episodeIdentity, score: rating).description(description).response()

			return rating
		} catch let error as APIError {
			print(error.localizedDescription)
			throw error
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}

	/// Delete the user's rating and review for this episode.
	///
	/// - Returns: `true` if the backend accepted the deletion.
	func deleteRating() async throws(APIError) -> Bool {
		let episodeIdentity = EpisodeIdentity(id: self.id)

		do {
			// The identity lets the open lists drop that one row.
			if let reviewIdentity = try await KService.deleteRating(episodeIdentity).response().data.first {
				NotificationCenter.default.post(name: .KReviewDidDelete, object: nil, userInfo: ["reviewID": reviewIdentity.id])
			}

			return true
		} catch let error as APIError {
			print(error.localizedDescription)
			throw error
		} catch {
			print(error.localizedDescription)
			return false
		}
	}

	@MainActor
	private func validateIsWatched() async -> Bool {
		if self.watchStatus == nil {
			await UIApplication.topViewController?.presentAlertController(title: L10n.addToLibrary, message: "Please watch \(self.attributes.title) first.")

			return false
		}

		return true
	}
}
