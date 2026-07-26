//
//  Show+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Show {
	/// The webpage URL of the show.
	var webpageURLString: String {
		return "https://kurozora.app/anime/\(self.attributes.slug)"
	}

	/// The authenticated user's library state for the show.
	@MainActor var libraryAttributes: LibraryAttributes? {
		return LibraryStore.shared.effectiveLibrary(forTrackableID: self.id.rawValue, kind: .shows)
	}

	/// The denormalized display snapshot used to seed an offline library add.
	private var outboxSeed: LibraryOutboxSeed {
		LibraryOutboxSeed(
			title: self.attributes.title,
			sortTitle: LocalLibraryEntry.normalizedSortKey(self.attributes.title),
			tagline: self.attributes.tagline,
			posterURL: self.attributes.poster?.url,
			posterBackgroundColor: self.attributes.poster?.backgroundColor,
			bannerURL: self.attributes.banner?.url,
			bannerBackgroundColor: self.attributes.banner?.backgroundColor,
			genresLocalized: self.attributes.genres?.joined(separator: ", "),
			statusName: self.attributes.status.name,
			airingDate: self.attributes.nextBroadcastAt,
			durationCount: self.attributes.durationCount,
			mediaTypeName: self.attributes.type.name,
			popularityRank: self.attributes.stats?.rankTotal,
			publicRating: self.attributes.stats?.ratingAverage,
			slug: self.attributes.slug
		)
	}

	/// Create a context menu configuration for the show.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIContextMenuConfiguration` representing the context menu for the show.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			return ShowDetailsCollectionViewController()(with: self.id)
		}) { _ in
			return self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		}
	}

	/// Create a context menu for the show.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the show.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	@MainActor
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []
		let library = self.libraryAttributes
		let libraryStatus = library?.status ?? .none

		if User.isSignedIn {
			// Create "add to library" element
			let addToLibraryAction = self.addToLibrary()
			menuElements.append(addToLibraryAction)
		}

		if User.isSignedIn {
			// Create "mark as hidden" element
			let hiddenStatus = library?.hiddenStatus

			if hiddenStatus != .disabled {
				let updateHiddenStatusTitle = hiddenStatus == .hidden ? L10n.showToPublic : L10n.hideFromPublic
				let updateHiddenStatusImage = hiddenStatus == .hidden ? UIImage(systemName: "eye.slash.fill") : UIImage(systemName: "eye.fill")

				let hideAction = UIAction(title: updateHiddenStatusTitle, image: updateHiddenStatusImage) { _ in
					Task { @MainActor in
						guard let isHidden = self.libraryAttributes?.isHidden else { return }
						await self.markAsHidden(!isHidden)
					}
				}
				menuElements.append(hideAction)
			}
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

		// Create "remove from library" menu
		if User.isSignedIn {
			if libraryStatus != .none {
				let removeFromLibraryAction = UIAction(title: L10n.removeFromLibrary, image: UIImage(systemName: "minus.circle"), attributes: .destructive) { _ in
					Task {
						await self.removeFromLibrary()
					}
				}
				let subMenu = UIMenu(title: "", options: .displayInline, children: [removeFromLibraryAction])
				menuElements.append(subMenu)
			}
		}

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}

	/// Present share sheet for the show.
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
		activityItems.append(L10n.shareShow(self.attributes.title))

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
	func addToLibrary() -> UIMenu {
		let libraryStatus = self.libraryAttributes?.status ?? .none
		let addToLibraryMenuTitle = libraryStatus == .none ? L10n.addToLibrary : L10n.updateLibraryStatus
		let addToLibraryMenuImage = libraryStatus == .none ? UIImage(systemName: "plus") : UIImage(systemName: "arrow.left.arrow.right")
		var menuElements: [UIMenuElement] = []

		LibraryStatus.all.forEach { actionLibraryStatus in
			let selectedLibraryStatus = libraryStatus == actionLibraryStatus

			menuElements.append(UIAction(title: actionLibraryStatus.showStringValue, image: selectedLibraryStatus ? UIImage(systemName: "checkmark") : nil, handler: { _ in
				Task {
					let isSignedIn = await WorkflowController.shared.isSignedIn()
					guard isSignedIn else { return }
					await self.addToLibrary(status: actionLibraryStatus)
				}
			}))
		}

		return UIMenu(title: addToLibraryMenuTitle, image: addToLibraryMenuImage, children: menuElements)
	}

	/// Adds the show to the user's library with the given status.
	///
	/// - Parameter status: The library status to assign.
	@MainActor
	func addToLibrary(status: LibraryStatus) async {
		guard let slug = User.current?.attributes.slug else { return }

		await LibraryOutbox.shared.enqueueSetStatus(status, trackableID: self.id.rawValue, userSlug: slug, kind: .shows, seed: self.outboxSeed)
		await ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: status))
	}

	@MainActor
	func removeFromLibrary() async {
		guard let slug = User.current?.attributes.slug else { return }
		await LibraryOutbox.shared.enqueueRemove(trackableID: self.id.rawValue, userSlug: slug, kind: .shows)
	}

	@MainActor
	func toggleFavorite(on viewController: UIViewController? = nil) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }
		guard let slug = User.current?.attributes.slug else { return }

		let desired = !(self.libraryAttributes?.isFavorited ?? false)
		await LibraryOutbox.shared.enqueueSetFavorite(desired, trackableID: self.id.rawValue, userSlug: slug, kind: .shows)

		// The favorites list covers kinds outside the local library store; refresh via notification.
		NotificationCenter.default.post(name: .KFavoriteModelsListDidChange, object: nil)
	}

	@MainActor
	func toggleReminder(on viewController: UIViewController? = nil) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }
		guard let slug = User.current?.attributes.slug else { return }

		if self.libraryAttributes?.status == nil {
			await self.addToLibrary(status: .planning)
		}

		let desired = !(self.libraryAttributes?.isReminded ?? false)
		await LibraryOutbox.shared.enqueueSetReminder(desired, trackableID: self.id.rawValue, userSlug: slug, kind: .shows)

		// The reminders list fetches from the network; refresh via notification.
		NotificationCenter.default.post(name: .KReminderModelsListDidChange, object: nil)
	}

	/// Rate the show with the given rating.
	///
	/// - Parameters:
	///    - rating: The rating given by the user.
	///    - description: The review given by the user.
	///
	/// - Returns: the rating applied to the show if rated successfully.
	@MainActor
	func rate(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard await self.validateIsInLibrary() else { return nil }
		guard let slug = User.current?.attributes.slug else { return nil }

		await LibraryOutbox.shared.enqueueRate(score: rating, description: description, trackableID: self.id.rawValue, userSlug: slug, kind: .shows)
		return rating
	}

	/// Delete the user's rating and review for this show.
	///
	/// - Returns: `true` if the backend accepted the deletion.
	@MainActor
	func deleteRating() async throws(APIError) -> Bool {
		guard let slug = User.current?.attributes.slug else { return false }
		await LibraryOutbox.shared.enqueueDeleteRating(trackableID: self.id.rawValue, userSlug: slug, kind: .shows)
		return true
	}

	/// Update the hidden status of the show.
	///
	/// - Parameters:
	///    - hidden: The boolean value determining whether to hide the show in the user's library.
	@MainActor
	func markAsHidden(_ hidden: Bool) async {
		guard await self.validateIsInLibrary() else { return }
		guard let slug = User.current?.attributes.slug else { return }
		await LibraryOutbox.shared.enqueueSetHidden(hidden, trackableID: self.id.rawValue, userSlug: slug, kind: .shows)
	}

	@MainActor
	func toggleVisibility(on viewController: UIViewController? = nil) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		guard self.libraryAttributes?.hiddenStatus != .disabled else { return }
		let isHidden = self.libraryAttributes?.isHidden ?? false
		await self.markAsHidden(!isHidden)
	}

	/// Update the rewatch count of the show.
	///
	/// - Parameters:
	///    - count: The number to update the rewatch count with.
	@MainActor
	func rewatch(for count: Int) async {
		guard await self.validateIsInLibrary() else { return }
		guard let slug = User.current?.attributes.slug else { return }
		await LibraryOutbox.shared.enqueueSetRewatchCount(count, trackableID: self.id.rawValue, userSlug: slug, kind: .shows)
	}

	@MainActor
	private func validateIsInLibrary() async -> Bool {
		if self.libraryAttributes?.status == nil {
			await UIApplication.topViewController?.presentAlertController(title: L10n.addToLibrary, message: "Please add \"\(self.attributes.title)\" to your library first.")

			return false
		}

		return true
	}
}
