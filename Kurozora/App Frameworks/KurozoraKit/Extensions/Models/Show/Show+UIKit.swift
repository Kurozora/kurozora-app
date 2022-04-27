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
			return self.makeContextMenu(in: viewController)
		}
	}

	private func makeContextMenu(in viewController: UIViewController) -> UIMenu {
		var menuElements: [UIMenuElement] = []
		let libraryStatus = self.attributes.libraryStatus ?? .none

		if User.isSignedIn {
			// Create "add to library" element
			let addToLibraryAction = self.addToLibrary()
			menuElements.append(addToLibraryAction)
		}

		// Create "share" element
		let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up.fill")) { [weak self] _ in
			guard let self = self else { return }
			self.openShareSheet(on: viewController)
		}
		menuElements.append(shareAction)

		if User.isSignedIn {
			if libraryStatus != .none {
				let removeFromLibraryAction = UIAction(title: "Remove from Library", image: UIImage(systemName: "minus.circle"), attributes: .destructive) { [weak self] _ in
					guard let self = self else { return }
					self.removeFromLibrary()
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
		let addToLibraryMenuTitle = libraryStatus == .none ? "Add to Library" : "Update Library Status"
		let addToLibraryMenuImage = libraryStatus == .none ? UIImage(systemName: "plus") : UIImage(systemName: "arrow.left.arrow.right")
		var menuElements: [UIMenuElement] = []

		KKLibrary.Status.all.forEach { [weak self] actionLibraryStatus in
			guard let self = self else { return }
			let selectedLibraryStatus = libraryStatus == actionLibraryStatus

			menuElements.append(UIAction(title: actionLibraryStatus.stringValue, image: selectedLibraryStatus ? UIImage(systemName: "checkmark") : nil, handler: { _ in
				WorkflowController.shared.isSignedIn {
					KService.addToLibrary(withLibraryStatus: actionLibraryStatus, showID: self.id) { result in
						switch result {
						case .success(let libraryUpdate):
							// Update entry in library
							self.attributes.update(using: libraryUpdate)

							let libraryAddToNotificationName = Notification.Name("AddTo\(actionLibraryStatus.sectionValue)Section")
							NotificationCenter.default.post(name: libraryAddToNotificationName, object: nil)
						case .failure:
							break
						}
					}
				}
			}))
		}

		return UIMenu(title: addToLibraryMenuTitle, image: addToLibraryMenuImage, children: menuElements)
	}

	private func removeFromLibrary() {
		KService.removeFromLibrary(showID: self.id) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let libraryUpdate):
				// Update entry in library
				self.attributes = self.attributes.updated(using: libraryUpdate)

				if let oldLibraryStatus = self.attributes.libraryStatus {
					let libraryRemoveFromNotificationName = Notification.Name("RemoveFrom\(oldLibraryStatus.sectionValue)Section")
					NotificationCenter.default.post(name: libraryRemoveFromNotificationName, object: nil)
				}
			case .failure:
				break
			}
		}
	}

	func toggleFavorite() {
		WorkflowController.shared.isSignedIn {
			KService.updateFavoriteShowStatus(self.id) { [weak self] result in
				guard let self = self else { return }
				switch result {
				case .success(let favoriteStatus):
					self.attributes.favoriteStatus = favoriteStatus
					NotificationCenter.default.post(name: .KShowFavoriteIsToggled, object: nil)
				case .failure: break
				}
			}
		}
	}

	func toggleReminder() {
		WorkflowController.shared.isSignedIn {
			Task {
				await WorkflowController.shared.isPro {
					KService.updateReminderStatus(forShow: self.id) { [weak self] result in
						guard let self = self else { return }
						switch result {
						case .success(let reminderStatus):
							self.attributes.reminderStatus = reminderStatus
							NotificationCenter.default.post(name: .KShowReminderIsToggled, object: nil)
						case .failure: break
						}
					}
				}
			}
		}
	}
}
