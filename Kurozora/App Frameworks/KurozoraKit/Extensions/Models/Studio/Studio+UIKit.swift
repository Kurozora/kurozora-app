//
//  Studio+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension Studio {
	/// The webpage URL of the studio.
	var webpageURLString: String {
		return "https://kurozora.app/studios/\(self.attributes.slug)"
	}

	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?)
	-> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			return StudioDetailsCollectionViewController.`init`(with: self.id)
		}, actionProvider: { _ in
			return self.makeContextMenu(in: viewController)
		})
	}

	private func makeContextMenu(in viewController: UIViewController) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// Create "share" menu
		var shareMenuChildren: [UIMenuElement] = []
		let copyTitleAction = UIAction(title: "Copy Name", image: UIImage(systemName: "document.on.document.fill")) { [weak self] _ in
			guard let self = self else { return }
			UIPasteboard.general.string = self.attributes.name
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

	/// Present share sheet for the character.
	///
	/// Make sure to send either the view or the bar button item that's sending the request.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the share sheet.
	///    - view: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		var activityItems: [Any] = []
		let shareText = "\(self.webpageURLString)\nYou should check out shows made by \"\(self.attributes.name)\" via @KurozoraApp"
		activityItems.append(shareText)

		if let personalImage = self.attributes.profileImageView.image {
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

	/// Rate the studio with the given rating.
	///
	/// - Parameters:
	///    - rating: The rating given by the user.
	///    - description: The review given by the user.
	///
	/// - Returns: the rating applied to the studio if rated successfully.
	func rate(using rating: Double, description: String?) async -> Double? {
		let studioIdentity = StudioIdentity(id: self.id)

		do {
			_ = try await KService.rateStudio(studioIdentity, with: rating, description: description).value

			// Update current rating for the user.
			self.attributes.library?.rating = rating

			// Update review only if the user removes it explicitly.
			if description != nil {
				self.attributes.library?.review = description
			}

			return rating
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
}
