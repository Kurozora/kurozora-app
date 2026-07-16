//
//  Literature+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/02/2023.
//  Copyright © 2023 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Literature {
	/// The webpage URL of the literature.
	var webpageURLString: String {
		return "https://kurozora.app/manga/\(self.attributes.slug)"
	}

	/// The authenticated user's library state for the literature.
	@MainActor var libraryAttributes: LibraryAttributes? {
		return LibraryStore.shared.effectiveLibrary(forTrackableID: self.id.rawValue, kind: .literatures)
	}

	/// Create a context menu configuration for the literature.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIContextMenuConfiguration` representing the context menu for the literature.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			return LiteratureDetailsCollectionViewController()(with: self.id)
		}) { _ in
			return self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		}
	}

	/// Create a context menu for the literature.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the literature.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	@MainActor
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []
		let libraryStatus = self.libraryAttributes?.status ?? .none

		if User.isSignedIn {
			// Create "add to library" element
			let addToLibraryAction = self.addToLibrary()
			menuElements.append(addToLibraryAction)
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

	/// Present share sheet for the literature.
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
		activityItems.append(L10n.shareLiterature(self.attributes.title))

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

			menuElements.append(UIAction(title: actionLibraryStatus.literatureStringValue, image: selectedLibraryStatus ? UIImage(systemName: "checkmark") : nil, handler: { _ in
				Task {
					let signedIn = await WorkflowController.shared.isSignedIn()
					guard signedIn else { return }
					await self.addToLibrary(status: actionLibraryStatus)
				}
			}))
		}

		return UIMenu(title: addToLibraryMenuTitle, image: addToLibraryMenuImage, children: menuElements)
	}

	@MainActor
	fileprivate func addToLibrary(status: LibraryStatus) async {
		do {
			let libraryUpdateResponse = try await KService.addToLibrary(.literatures, status: status, itemIDs: [self.id]).response()


			// Apply the freshly-created rows into the local store immediately.
			if let slug = User.current?.attributes.slug {
				LibraryStore.shared.apply(libraryUpdateResponse.data.relationships.libraries, forUserSlug: slug, kind: .literatures)
			}

			// Request review
			await ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: status))
		} catch let error as APIError {
//			self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
			print("----- Add to library failed:", error.message)
		} catch {
			print("----- Add to library failed with generic error:", error.localizedDescription)
		}
	}

	@MainActor
	func removeFromLibrary() async {
		do {
			let libraryUpdateResponse = try await KService.removeFromLibrary(.literatures, itemIDs: [self.id]).response()


			// Optimistic local write — drop the cached entry.
			if let slug = User.current?.attributes.slug {
				LibraryStore.shared.applyRemoved(forTrackableID: self.id.rawValue, userSlug: slug, kind: .literatures)
			}
		} catch let error as APIError {
			print("----- Remove from library failed", error.message)
		} catch {
			print(error.localizedDescription)
		}
	}

	@MainActor
	func toggleFavorite(on viewController: UIViewController? = nil) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		do {
			let favoriteResponse = try await KService.toggleFavorite(inLibrary: .literatures, itemIDs: [self.id]).response()


			// Optimistic local write — flip the cached isFavorited flag.
			if let slug = User.current?.attributes.slug {
				LibraryStore.shared.applyFavorite(favoriteResponse.data.favoriteStatus == .favorited, forTrackableID: self.id.rawValue, userSlug: slug, kind: .literatures)
			}

			// The favorites list covers kinds outside the local library store; refresh via notification.
			NotificationCenter.default.post(name: .KFavoriteModelsListDidChange, object: nil)
		} catch let error as APIError {
			viewController?.presentAlertController(title: L10n.cantFavorite, message: error.message)
			print("----- Toggle favorite failed:", error.message)
		} catch {
			viewController?.presentAlertController(title: L10n.cantFavorite, message: error.localizedDescription)
			print("----- Toggle favorite failed with generic error:", error.localizedDescription)
		}
	}

	@MainActor
	func toggleReminder(on viewController: UIViewController? = nil) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }
		let viewController = viewController ?? UIApplication.topViewController

		if await WorkflowController.shared.isSubscribed(on: viewController) {
			do {
				if self.libraryAttributes?.status == nil {
					await self.addToLibrary(status: .planning)
				}

				let updateReminderResponse = try await KService.toggleReminder(inLibrary: .literatures, itemIDs: [self.id]).response()


				// Optimistic local write — flip the cached isReminded flag.
				if let slug = User.current?.attributes.slug {
					LibraryStore.shared.applyReminder(updateReminderResponse.data.reminderStatus == .reminded, forTrackableID: self.id.rawValue, userSlug: slug, kind: .literatures)
				}

				// The reminders list fetches from the network; refresh via notification.
				NotificationCenter.default.post(name: .KReminderModelsListDidChange, object: nil)
			} catch let error as APIError {
				viewController?.presentAlertController(title: L10n.cantAddReminder, message: error.message)
				print("----- Toggle reminder failed:", error.localizedDescription)
			} catch {
				viewController?.presentAlertController(title: L10n.cantAddReminder, message: error.localizedDescription)
				print("----- Toggle reminder failed with generic error:", error.localizedDescription)
			}
		}
	}

	/// Rate the literature with the given rating.
	///
	/// - Parameters:
	///    - rating: The rating given by the user.
	///    - description: The review given by the user.
	///
	/// - Returns: the rating applied to the literature if rated successfully.
	@MainActor
	func rate(using rating: Double, description: String?) async throws(APIError) -> Double? {
		guard await self.validateIsInLibrary() else { return nil }
		let literatureIdentity = LiteratureIdentity(id: self.id)

		do {
			_ = try await KService.rate(literatureIdentity, score: rating).description(description).response()


			// Optimistic local write — mirror the rate/review onto the cached entry.
			if let slug = User.current?.attributes.slug {
				LibraryStore.shared.applyRating(score: rating, description: description, forTrackableID: self.id.rawValue, userSlug: slug, kind: .literatures)
			}

			return rating
		} catch let error as APIError {
			print(error.localizedDescription)
			throw error
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}

	/// Delete the user's rating and review for this literature.
	///
	/// - Returns: `true` if the backend accepted the deletion.
	@MainActor
	func deleteRating() async throws(APIError) -> Bool {
		let literatureIdentity = LiteratureIdentity(id: self.id)

		do {
			_ = try await KService.deleteRating(literatureIdentity).response()

			// Optimistic local write — clear the rate/review on the cached entry.
			if let slug = User.current?.attributes.slug {
				LibraryStore.shared.applyRatingRemoved(forTrackableID: self.id.rawValue, userSlug: slug, kind: .literatures)
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

	/// Update the hidden status of the literature.
	///
	/// - Parameters:
	///    - hidden: The boolean value determining whether to hide the literature in the user's library.
	@MainActor
	func markAsHidden(_ hidden: Bool) async {
		guard await self.validateIsInLibrary() else { return }

		do {
			_ = try await KService.updateInLibrary(.literatures, itemIDs: [self.id]).hidden(hidden).response()


			// Optimistic local write — mirror the hidden state onto the cached entry.
			if let slug = User.current?.attributes.slug {
				LibraryStore.shared.applyHidden(hidden, forTrackableID: self.id.rawValue, userSlug: slug, kind: .literatures)
			}
		} catch let error as APIError {
			UIApplication.topViewController?.presentAlertController(title: L10n.cantUpdateLibraryTitle, message: error.message)
			print("----- Update hidden status failed:", error.message)
		} catch {
			UIApplication.topViewController?.presentAlertController(title: L10n.cantUpdateLibraryTitle, message: error.localizedDescription)
			print("----- Update hidden status failed:", error.localizedDescription)
		}
	}

	@MainActor
	func toggleVisibility(on viewController: UIViewController? = nil) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		guard self.libraryAttributes?.hiddenStatus != .disabled else { return }
		let isHidden = self.libraryAttributes?.isHidden ?? false
		await self.markAsHidden(!isHidden)
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
