//
//  Song+UIKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/11/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

extension Song {
	func contextMenuConfiguration(in viewController: UIViewController, userInfo: [AnyHashable: Any?])
	-> UIContextMenuConfiguration? {
		let identifier = userInfo["indexPath"] as? NSCopying

		return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
			return SongDetailsCollectionViewController.`init`(with: self.id)
		}) { _ in
			return self.makeContextMenu(in: viewController, userInfo: userInfo)
		}
	}

	func makeContextMenu(in viewController: UIViewController?, userInfo: [AnyHashable: Any?]) -> UIMenu {
		var menuElements: [UIMenuElement] = []

		// Create "Apple Music" element
		if let appleMusicLink = userInfo["appleMusicLink"] as? URL {
			let amAction = UIAction(title: Trans.viewOnAppleMusic, image: R.image.symbols.musicNoteCircle()) { _ in
				self.openAMLink(appleMusicLink)
			}
			menuElements.append(amAction)
		}

		// Create "share" element
		let shareAction = UIAction(title: Trans.share, image: UIImage(systemName: "square.and.arrow.up.fill")) { _ in
			self.openShareSheet(on: viewController)
		}
		menuElements.append(shareAction)

		// Create and return a UIMenu with the share action
		return UIMenu(title: "", children: menuElements)
	}

	/// Open Apple Music link.
	func openAMLink(_ appleMusicLink: URL) {
		UIApplication.shared.open(appleMusicLink)
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
		let shareText = "https://kurozora.app/songs/\(self.id)\nListen to \"\(self.attributes.title)\" by \"\(self.attributes.artist)\" on @KurozoraApp"
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
}
