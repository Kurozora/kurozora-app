//
//  Show+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 15/11/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension Show {
	/// The webpage URL of the show.
	var webpageURLString: String {
		return "https://kurozora.app/anime/\(self.attributes.slug)"
	}

	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?)
	-> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: { [weak self] in
			guard let self = self else { return nil }
			return ShowDetailsCollectionViewController.`init`(with: self.id)
		}) { [weak self] _ in
			guard let self = self else { return nil }
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		}
	}

	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?) -> UIMenu {
		var menuElements: [UIMenuElement] = []
		let libraryStatus = self.attributes.library?.status ?? .none

		if User.isSignedIn {
			// Create "add to library" element
			let addToLibraryAction = self.addToLibrary()
			menuElements.append(addToLibraryAction)
		}

		if User.isSignedIn {
			// Create "mark as hidden" element
			let hiddenStatus = self.attributes.library?.hiddenStatus

			if hiddenStatus != .disabled {
				let updateHiddenStatusTitle = hiddenStatus == .hidden ? Trans.showToPublic : Trans.hideFromPublic
				let updateHiddenStatusImage = hiddenStatus == .hidden ? UIImage(systemName: "eye.slash.fill") : UIImage(systemName: "eye.fill")

				let hideAction = UIAction(title: updateHiddenStatusTitle, image: updateHiddenStatusImage) { [weak self] _ in
					guard let self = self else { return }
					guard let isHidden = self.attributes.library?.isHidden else { return }

					Task {
						await self.markAsHidden(!isHidden)
					}
				}
				menuElements.append(hideAction)
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

		// Create "remove from library" menu
		if User.isSignedIn {
			if libraryStatus != .none {
				let removeFromLibraryAction = UIAction(title: Trans.removeFromLibrary, image: UIImage(systemName: "minus.circle"), attributes: .destructive) { [weak self] _ in
					guard let self = self else { return }

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
	///    - view: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		let shareText = "\(self.webpageURLString)\nYou should watch \"\(self.attributes.title)\" via @KurozoraApp"
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

	func addToLibrary() -> UIMenu {
		let libraryStatus = self.attributes.library?.status ?? .none
		let addToLibraryMenuTitle = libraryStatus == .none ? Trans.addToLibrary : Trans.updateLibraryStatus
		let addToLibraryMenuImage = libraryStatus == .none ? UIImage(systemName: "plus") : UIImage(systemName: "arrow.left.arrow.right")
		var menuElements: [UIMenuElement] = []

		KKLibrary.Status.all.forEach { [weak self] actionLibraryStatus in
			guard let self = self else { return }
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

	fileprivate func addToLibrary(status: KKLibrary.Status) async {
		do {
			let libraryUpdateResponse = try await KService.addToLibrary(.shows, withLibraryStatus: status, modelID: String(self.id)).value

			// Update entry in library
			self.attributes.library?.update(using: libraryUpdateResponse.data)

			let libraryAddToNotificationName = Notification.Name("AddTo\(status.sectionValue)Section")
			NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)

			// Request review
			ReviewManager.shared.requestReview(for: .itemAddedToLibrary(status: status))
		} catch let error as KKAPIError {
			//			self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
			print("----- Add to library failed:", error.message)
		} catch {
			print("----- Add to library failed with generic error:", error.localizedDescription)
		}
	}

	func removeFromLibrary() async {
		do {
			let libraryUpdateResponse = try await KService.removeFromLibrary(.shows, modelID: String(self.id)).value

			// Update entry in library
			self.attributes.library?.update(using: libraryUpdateResponse.data)

			if let oldLibraryStatus = self.attributes.library?.status {
				let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
				NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
			}
		} catch let error as KKAPIError {
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
			let favoriteResponse = try await KService.updateFavoriteStatus(inLibrary: .shows, modelID: String(self.id)).value

			self.attributes.library?.favoriteStatus = favoriteResponse.data.favoriteStatus
			NotificationCenter.default.post(name: .KModelFavoriteIsToggled, object: nil, userInfo: [
				"favoriteStatus": favoriteResponse.data.favoriteStatus
			])
		} catch let error as KKAPIError {
			viewController?.presentAlertController(title: "Can't Favorite", message: error.message)
			print("----- Toggle favorite failed:", error.message)
		} catch {
			viewController?.presentAlertController(title: "Can't Favorite", message: error.localizedDescription)
			print("----- Toggle favorite failed:", error.localizedDescription)
		}
	}

	@MainActor
	func toggleReminder(on viewController: UIViewController? = nil) async {
		let signedIn = await WorkflowController.shared.isSignedIn(on: viewController)
		guard signedIn else { return }

		let viewController = viewController ?? UIApplication.topViewController

		if await WorkflowController.shared.isSubscribed(on: viewController) {
			do {
				if self.attributes.library?.status == nil {
					await self.addToLibrary(status: .planning)
				}

				let updateReminderResponse = try await KService.updateReminderStatus(inLibrary: .shows, modelID: self.id).value

				self.attributes.library?.reminderStatus = updateReminderResponse.data.reminderStatus
				NotificationCenter.default.post(name: .KModelReminderIsToggled, object: nil, userInfo: [
					"reminderStatus": updateReminderResponse.data.reminderStatus
				])
			} catch let error as KKAPIError {
				viewController?.presentAlertController(title: "Can't Add Reminder", message: error.message)
				print("----- Toggle reminder failed:", error.message)
			} catch {
				viewController?.presentAlertController(title: "Can't Add Reminder", message: error.localizedDescription)
				print("----- Toggle reminder failed:", error.localizedDescription)
			}
		}
	}

	/// Rate the show with the given rating.
	///
	/// - Parameters:
	///    - rating: The rating given by the user.
	///    - description: The review given by the user.
	///
	/// - Returns: the rating applied to the show if rated successfully.
	func rate(using rating: Double, description: String?) async throws(KKAPIError) -> Double? {
		guard await self.validateIsInLibrary() else { return nil }
		let showIdentity = ShowIdentity(id: self.id)

		do {
			_ = try await KService.rateShow(showIdentity, with: rating, description: description).value

			// Update current rating for the user.
			self.attributes.library?.rating = rating

			// Update review only if the user removes it explicitly.
			if description != nil {
				self.attributes.library?.review = description
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

	/// Update the hidden status of the show.
	///
	/// - Parameters:
	///    - hidden: The boolean value determining whether to hide the show in the user's library.
	func markAsHidden(_ hidden: Bool) async {
		guard await self.validateIsInLibrary() else { return }

		do {
			_ = try await KService.updateInLibrary(.shows, modelID: self.id, rewatchCount: nil, isHidden: hidden).value

			// Update current rating for the user.
			self.attributes.library?.isHidden = hidden
		} catch {
			print(error.localizedDescription)
		}
	}

	/// Update the rewatch count of the show.
	///
	/// - Parameters:
	///    - count: The number to update the rewatch count with.
	func rewatch(for count: Int) async {
		guard await self.validateIsInLibrary() else { return }

		do {
			_ = try await KService.updateInLibrary(.shows, modelID: self.id, rewatchCount: count, isHidden: nil).value

			// Update current rating for the user.
			self.attributes.library?.rewatchCount = count
		} catch {
			print(error.localizedDescription)
		}
	}

	private func validateIsInLibrary() async -> Bool {
		if self.attributes.library?.status == nil {
			await UIApplication.topViewController?.presentAlertController(title: Trans.addToLibrary, message: "Please add \"\(self.attributes.title)\" to your library first.")

			return false
		}

		return true
	}
}
