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
		let libraryStatus = self.attributes.libraryStatus ?? .none

		if User.isSignedIn {
			// Create "add to library" element
			let addToLibraryAction = self.addToLibrary()
			menuElements.append(addToLibraryAction)
		}

		// Create "share" element
		let shareAction = UIAction(title: Trans.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { [weak self] _ in
			guard let self = self else { return }
			self.openShareSheet(on: viewController)
		}
		menuElements.append(shareAction)

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
		let shareText = "https://kurozora.app/anime/\(self.attributes.slug)\nYou should watch \"\(self.attributes.title)\" via @KurozoraApp"
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
		let libraryStatus = self.attributes.libraryStatus ?? .none
		let addToLibraryMenuTitle = libraryStatus == .none ? Trans.addTolibrary : Trans.updateLibraryStatus
		let addToLibraryMenuImage = libraryStatus == .none ? UIImage(systemName: "plus") : UIImage(systemName: "arrow.left.arrow.right")
		var menuElements: [UIMenuElement] = []

		KKLibrary.Status.all.forEach { [weak self] actionLibraryStatus in
			guard let self = self else { return }
			let selectedLibraryStatus = libraryStatus == actionLibraryStatus

			menuElements.append(UIAction(title: actionLibraryStatus.showStringValue, image: selectedLibraryStatus ? UIImage(systemName: "checkmark") : nil, handler: { _ in
				WorkflowController.shared.isSignedIn {
					Task {
						do {
							let libraryUpdateResponse = try await KService.addToLibrary(.shows, withLibraryStatus: actionLibraryStatus, modelID: String(self.id)).value

							// Update entry in library
							self.attributes.update(using: libraryUpdateResponse.data)

							let libraryAddToNotificationName = Notification.Name("AddTo\(actionLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
						} catch let error as KKAPIError {
							//						self.presentAlertController(title: "Can't Add to Your Library 😔", message: error.message)
							print("----- Add to library failed", error.message)
						}
					}
				}
			}))
		}

		return UIMenu(title: addToLibraryMenuTitle, image: addToLibraryMenuImage, children: menuElements)
	}

	func removeFromLibrary() async {
		do {
			let libraryUpdateResponse = try await KService.removeFromLibrary(.shows, modelID: String(self.id)).value

			// Update entry in library
			self.attributes = self.attributes.updated(using: libraryUpdateResponse.data)

			if let oldLibraryStatus = self.attributes.libraryStatus {
				let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
				NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
			}
		} catch let error as KKAPIError {
			print("----- Remove from library failed", error.message)
		} catch {
			print(error.localizedDescription)
		}
	}

	func toggleFavorite() {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }

			Task {
				do {
					let favoriteResponse = try await KService.updateFavoriteStatus(inLibrary: .shows, modelID: String(self.id)).value

					self.attributes.favoriteStatus = favoriteResponse.data.favoriteStatus
					NotificationCenter.default.post(name: .KModelFavoriteIsToggled, object: nil, userInfo: [
						"favoriteStatus": favoriteResponse.data.favoriteStatus
					])
				} catch {
					print(error.localizedDescription)
				}
			}
		}
	}

	func toggleReminder(on viewController: UIViewController? = nil) {
		WorkflowController.shared.isSignedIn { [weak self] in
			guard let self = self else { return }
			let viewController = viewController ?? UIApplication.topViewController

			Task {
				if await WorkflowController.shared.isSubscribed(on: viewController) {
					do {
						let updateReminderResponse = try await KService.updateReminderStatus(inLibrary: .shows, modelID: String(self.id)).value

						self.attributes.reminderStatus = updateReminderResponse.data.reminderStatus
						NotificationCenter.default.post(name: .KModelReminderIsToggled, object: nil, userInfo: [
							"reminderStatus": updateReminderResponse.data.reminderStatus
						])
					} catch {
						print(error.localizedDescription)
					}
				}
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
	func rate(using rating: Double, description: String?) async -> Double? {
		guard await self.validateIsInLibrary() else { return nil }
		let showIdentity = ShowIdentity(id: self.id)

		do {
			_ = try await KService.rateShow(showIdentity, with: rating, description: description).value

			// Update current rating for the user.
			self.attributes.givenRating = rating

			// Update review only if the user removes it explicitly.
			if description != nil {
				self.attributes.givenReview = description
			}

			return rating
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}

	private func validateIsInLibrary() async -> Bool {
		if self.attributes.libraryStatus == nil {
			await UIApplication.topViewController?.presentAlertController(title: Trans.addTolibrary, message: "Please add \"\(self.attributes.title)\" to your library first.")

			return false
		}

		return true
	}
}
