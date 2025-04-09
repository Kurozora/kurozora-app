//
//  Person+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension Person {
	/// The webpage URL of the person.
	var webpageURLString: String {
		return "https://kurozora.app/people/\(self.attributes.slug)"
	}

	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?)
	-> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			return PersonDetailsCollectionViewController.`init`(with: self.id)
		}, actionProvider: { _ in
			return self.makeContextMenu(in: viewController)
		})
	}

	private func makeContextMenu(in viewController: UIViewController) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// Create "share" menu
		var shareMenuChildren: [UIMenuElement] = []
		let copyTitleAction = UIAction(title: "Copy Name", image: UIImage(systemName: "document.on.document.fill")) { _ in
			UIPasteboard.general.string = self.attributes.fullName
		}
		let copyLinkAction = UIAction(title: "Copy Link", image: UIImage(systemName: "document.on.document.fill")) { _ in
			UIPasteboard.general.string = self.webpageURLString
		}
		let shareAction = UIAction(title: Trans.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
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

	/// Present share sheet for the person.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - view: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		var activityItems: [Any] = []
		let shareText = "\(self.webpageURLString)\nYou should check out \"\(self.attributes.fullName)\" via @KurozoraApp"
		activityItems.append(shareText)

		if let personalImage = self.attributes.personalImage.image {
			activityItems.append(personalImage)
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

		viewController?.present(activityViewController, animated: true, completion: nil)
	}

	/// Rate the person with the given rating.
	///
	/// - Parameters:
	///    - rating: The rating given by the user.
	///    - description: The review given by the user.
	///
	/// - Returns: the rating applied to the person if rated successfully.
	func rate(using rating: Double, description: String?) async -> Double? {
		let personIdentity = PersonIdentity(id: self.id)

		do {
			_ = try await KService.ratePerson(personIdentity, with: rating, description: description).value

			// Update current crating for the user.
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
}
