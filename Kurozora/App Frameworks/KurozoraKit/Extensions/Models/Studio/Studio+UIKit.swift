//
//  Studio+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 01/06/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

extension Studio {
	/// The webpage URL of the studio.
	var webpageURLString: String {
		return "https://kurozora.app/studios/\(self.attributes.slug)"
	}

	/// Create a context menu configuration for the studio.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIContextMenuConfiguration` representing the context menu for the studio.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?)
		-> UIContextMenuConfiguration?
	{
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			StudioDetailsCollectionViewController.`init`(with: self.id)
		}, actionProvider: { _ in
			self.makeContextMenu(in: viewController, userInfo: userInfo, sourceView: sourceView, barButtonItem: barButtonItem)
		})
	}

	/// Create a context menu for the studio.
	///
	/// - Parameters:
	///    - viewController: The view controller presenting the context menu.
	///    - userInfo: Additional information about the context menu.
	///    - sourceView: The `UIView` sending the request.
	///    - barButtonItem: The `UIBarButtonItem` sending the request.
	///
	/// - Returns: A `UIMenu` representing the context menu for the studio.
	///
	/// - NOTE: If both `sourceView` and `barButtonItem` are provided, `sourceView` will take precedence.
	func makeContextMenu(in viewController: UIViewController, userInfo: [AnyHashable: Any]?, sourceView: UIView?, barButtonItem: UIBarButtonItem?) -> UIMenu {
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

	/// Present share sheet for the studio.
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
		let shareText = "\(self.webpageURLString)\nYou should check out shows made by \"\(self.attributes.name)\" via @KurozoraApp"
		activityItems.append(shareText)

		if let personalImage = self.attributes.profileImageView.image {
			activityItems.append(personalImage)
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

	/// Rate the studio with the given rating.
	///
	/// - Parameters:
	///    - rating: The rating given by the user.
	///    - description: The review given by the user.
	///
	/// - Returns: the rating applied to the studio if rated successfully.
	func rate(using rating: Double, description: String?) async throws(KKAPIError) -> Double? {
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
		} catch let error as KKAPIError {
			print(error.localizedDescription)
			throw error
		} catch {
			print(error.localizedDescription)
			return nil
		}
	}
}
