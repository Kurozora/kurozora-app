//
//  FeedTableViewControllerTouchBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

// MARK: - NSTouchBarDelegate
#if targetEnvironment(macCatalyst)
extension FeedTableViewController: NSTouchBarDelegate {
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self
		touchBar.defaultItemIdentifiers = [
			.fixedSpaceSmall,
			.showSettings,
			.flexibleSpace,
			.feedComposeMessage,
			.showProfile
		]
		return touchBar
	}

	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		let touchBarItem: NSTouchBarItem?

		switch identifier {
		case .showSettings:
			guard let image = UIImage(systemName: "gear") else { return nil }
			touchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(segueToSettings))
		case .feedComposeMessage:
			guard let image = UIImage(systemName: "pencil.circle") else { return nil }
			touchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(postNewMessage))
		case .showProfile:
			guard let image = UIImage(systemName: "person.crop.circle") else { return nil }
			touchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(segueToProfile))
		default:
			touchBarItem = nil
		}
		return touchBarItem
	}
}
#endif
