//
//  LocalLibraryEntry+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/06/2026.
//  Copyright © 2026 Kurozora. All rights reserved.
//

import KurozoraKit
import os.log
import UIKit

private let entryLogger = Logger(subsystem: "app.kurozora.Kurozora", category: "LocalLibraryEntry")

extension LocalLibraryEntry {
	// MARK: - Functions
	/// Builds a context-menu configuration for the library entry.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIContextMenuConfiguration` representing the context menu for the entry.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` takes precedence.
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying
		let itemID = KurozoraItemID(self.trackableID)
		let kind = self.kind

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			switch kind {
			case .shows:
				return ShowDetailsCollectionViewController()(with: itemID)
			case .literatures:
				return LiteratureDetailsCollectionViewController()(with: itemID)
			case .games:
				return GameDetailsCollectionViewController()(with: itemID)
			}
		}) { [weak self] _ in
			guard let self = self else { return nil }
			return self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		}
	}

	/// Builds the context menu shown for the library entry.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the entry.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` takes precedence.
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
		var menuElements: [UIMenuElement] = []
		let libraryStatus = self.libraryStatus

		if User.isSignedIn {
			// Create "add to library" element
			let addToLibraryAction = self.addToLibrary()
			menuElements.append(addToLibraryAction)
		}

		if User.isSignedIn {
			// Create "mark as hidden" element
			let isHidden = self.isHidden
			let updateHiddenStatusTitle = isHidden ? L10n.showToPublic : L10n.hideFromPublic
			let updateHiddenStatusImage = isHidden ? UIImage(systemName: "eye.slash.fill") : UIImage(systemName: "eye.fill")

			let hideAction = UIAction(title: updateHiddenStatusTitle, image: updateHiddenStatusImage) { [weak self] _ in
				guard let self = self else { return }

				Task {
					await self.markAsHidden(!self.isHidden)
				}
			}
			menuElements.append(hideAction)
		}

		// Create "share" menu
		var shareMenuChildren: [UIMenuElement] = []

		// Create "copy" action
		let copyTitleAction = UIAction(title: L10n.copyTitle, image: UIImage(systemName: "document.on.document.fill")) { [weak self] _ in
			guard let self = self else { return }
			UIPasteboard.general.string = self.title
		}
		let copyLinkAction = UIAction(title: L10n.copyLink, image: UIImage(systemName: "document.on.document.fill")) { [weak self] _ in
			guard let self = self else { return }
			UIPasteboard.general.string = self.webpageURLString
		}
		let copyMenu = UIMenu(title: L10n.copy, image: UIImage(systemName: "doc.on.doc.fill"), children: [copyTitleAction, copyLinkAction])

		// Create "share" action
		let shareAction = UIAction(title: L10n.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { [weak self] _ in
			guard let self = self else { return }
			self.openShareSheet(on: viewController, sourceView: sourceView, barButtonItem: barButtonItem)
		}
		shareMenuChildren.append(copyMenu)
		shareMenuChildren.append(shareAction)

		let shareMenu = UIMenu(title: "", options: .displayInline, children: shareMenuChildren)
		menuElements.append(shareMenu)

		// Create "remove from library" menu
		if User.isSignedIn {
			if libraryStatus != .none {
				let removeFromLibraryAction = UIAction(title: L10n.removeFromLibrary, image: UIImage(systemName: "minus.circle"), attributes: .destructive) { [weak self] _ in
					guard let self = self else { return }

					Task {
						await self.removeFromLibrary()
					}
				}
				let subMenu = UIMenu(title: "", options: .displayInline, children: [removeFromLibraryAction])
				menuElements.append(subMenu)
			}
		}

		return UIMenu(title: "", children: menuElements)
	}

	/// Presents the share sheet for the library entry.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` takes precedence.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, sourceView: UIView?, barButtonItem: UIBarButtonItem?) {
		let entryTitle = self.title ?? ""
		var activityItems: [Any] = []
		activityItems.append(self.webpageURLString)
		switch self.kind {
		case .shows:
			activityItems.append(L10n.shareShow(entryTitle))
		case .literatures:
			activityItems.append(L10n.shareLiterature(entryTitle))
		case .games:
			activityItems.append(L10n.shareGame(entryTitle))
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

	/// Builds the per-status "Add to library" submenu.
	func addToLibrary() -> UIMenu {
		let libraryStatus = self.libraryStatus
		let addToLibraryMenuTitle = libraryStatus == .none ? L10n.addToLibrary : L10n.updateLibraryStatus
		let addToLibraryMenuImage = libraryStatus == .none ? UIImage(systemName: "plus") : UIImage(systemName: "arrow.left.arrow.right")
		var menuElements: [UIMenuElement] = []
		let kind = self.kind

		LibraryStatus.all.forEach { [weak self] actionLibraryStatus in
			guard let self = self else { return }
			let selectedLibraryStatus = libraryStatus == actionLibraryStatus

			let actionTitle: String
			switch kind {
			case .shows:
				actionTitle = actionLibraryStatus.showStringValue
			case .literatures:
				actionTitle = actionLibraryStatus.literatureStringValue
			case .games:
				actionTitle = actionLibraryStatus.gameStringValue
			}

			menuElements.append(UIAction(title: actionTitle, image: selectedLibraryStatus ? UIImage(systemName: "checkmark") : nil, handler: { _ in
				Task {
					let signedIn = await WorkflowController.shared.isSignedIn()
					guard signedIn else { return }
					await self.addToLibrary(status: actionLibraryStatus)
				}
			}))
		}

		return UIMenu(title: addToLibraryMenuTitle, image: addToLibraryMenuImage, children: menuElements)
	}

	/// Adds the entry to the user's library with the given status.
	@MainActor
	fileprivate func addToLibrary(status: LibraryStatus) async {
		do {
			let libraryUpdateResponse = try await KService.addToLibrary(self.kind, status: status, itemIDs: [KurozoraItemID(self.trackableID)]).response()

			// Apply the freshly-created rows into the local store immediately.
			if let slug = User.current?.attributes.slug {
				LibraryStore.shared.apply(libraryUpdateResponse.data.relationships.libraries, forUserSlug: slug, kind: self.kind)
			}

			// Request review
			await ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: status))
		} catch let error as APIError {
			UIApplication.topViewController?.presentAlertController(title: L10n.cantAddToLibraryTitle, message: error.message)
			entryLogger.error("Add to library failed: \(error.message)")
		} catch {
			entryLogger.error("Add to library failed: \(error.localizedDescription)")
		}
	}

	/// Removes the entry from the user's library.
	@MainActor
	func removeFromLibrary() async {
		do {
			_ = try await KService.removeFromLibrary(self.kind, itemIDs: [KurozoraItemID(self.trackableID)]).response()

			// Optimistic local write — drop the cached entry.
			if let slug = User.current?.attributes.slug {
				LibraryStore.shared.applyRemoved(forTrackableID: self.trackableID, userSlug: slug, kind: self.kind)
			}
		} catch let error as APIError {
			UIApplication.topViewController?.presentAlertController(title: L10n.cantRemoveFromLibraryTitle, message: error.message)
			entryLogger.error("Remove from library failed: \(error.message)")
		} catch {
			entryLogger.error("Remove from library failed: \(error.localizedDescription)")
		}
	}

	/// Updates the hidden status of the entry.
	///
	/// - Parameter hide: `true` to hide the entry from public views of the user's library.
	@MainActor
	func markAsHidden(_ hide: Bool) async {
		do {
			_ = try await KService.updateInLibrary(self.kind, itemIDs: [KurozoraItemID(self.trackableID)]).hidden(hide).response()

			self.isHidden = hide
			self.updatedAt = Date()
			PersistenceController.shared.save(PersistenceController.shared.viewContext)
		} catch let error as APIError {
			UIApplication.topViewController?.presentAlertController(title: L10n.cantUpdateLibraryTitle, message: error.message)
			entryLogger.error("Update hidden status failed: \(error.message)")
		} catch {
			UIApplication.topViewController?.presentAlertController(title: L10n.cantUpdateLibraryTitle, message: error.localizedDescription)
			entryLogger.error("Update hidden status failed: \(error.localizedDescription)")
		}
	}
}
