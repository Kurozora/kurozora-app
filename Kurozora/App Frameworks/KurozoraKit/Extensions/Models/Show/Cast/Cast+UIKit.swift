//
//  Cast+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/02/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension Cast {
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any]?)
	-> UIContextMenuConfiguration? {
		let identifier = userInfo?["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil, actionProvider: { _ in
			return self.makeContextMenu(in: viewController)
		})
	}

	private func makeContextMenu(in viewController: UIViewController) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// Create "share" element
		let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
			self.openShareSheet(on: viewController)
		}
		menuElements.append(shareAction)

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}

	/**
		Present share sheet for the cast.

		Make sure to send either the view or the bar button item that's sending the request.

		- Parameter viewController: The view controller presenting the share sheet.
		- Parameter view: The `UIView` sending the request.
		- Parameter barButtonItem: The `UIBarButtonItem` sending the request.
	*/
	func openShareSheet(on viewController: UIViewController? = UIApplication.topViewController, _ view: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
		var activityItems: [Any] = []

		if let person = self.relationships.people.data.first?.attributes.fullName,
		   let character = self.relationships.characters.data.first?.attributes.name {
			activityItems.append("TIL, \(person) is the voice actor of \(character) via @KurozoraApp")
		}

		if let castImage = castImage() {
			activityItems.append(castImage)
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

	/**
		Merges and returns the combined image of the cast.

		- Returns: a combined image of the cast.
	*/
	private func castImage() -> UIImage? {
		guard let personImage = self.relationships.people.data.first?.attributes.personalImage else { return nil}
		guard let characterImage = self.relationships.characters.data.first?.attributes.personalImage else {return nil }
		let leftImage = personImage
		let rightImage = characterImage

		let size = CGSize(width: leftImage.size.width + rightImage.size.width, height: max(leftImage.size.height, rightImage.size.height))
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

		leftImage.draw(in: CGRect(x: 0, y: 0, width: size.width / 2, height: size.height))
		rightImage.draw(in: CGRect(x: size.width / 2, y: 0, width: size.width, height: size.height))

		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage
	}
}
