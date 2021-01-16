//
//  NotificationsViewController+TouchBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

// MARK: - NSTouchBarDelegate
#if targetEnvironment(macCatalyst)
extension NotificationsViewController: NSTouchBarDelegate {
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self
		touchBar.defaultItemIdentifiers = [
			.fixedSpaceSmall,
			.toggleSearchBar,
			.fixedSpaceSmall
		]
		return touchBar
	}

	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		let touchBarItem: NSTouchBarItem?

		switch identifier {
		case .toggleSearchBar:
			guard let image = UIImage(systemName: "magnifyingglass") else { return nil }
			touchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(toggleSearchBar))
		default:
			touchBarItem = nil
		}
		return touchBarItem
	}
}
#endif
