//
//  ShowDetailsCollectionViewController+TouchBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 12/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

#if targetEnvironment(macCatalyst)
import UIKit

extension ShowDetailsCollectionViewController: NSTouchBarDelegate {
	override func makeTouchBar() -> NSTouchBar? {
		let touchBar = NSTouchBar()
		touchBar.delegate = self

		touchBar.defaultItemIdentifiers = [
			.toggleModelIsReminded,
			.toggleModelIsFavorite
		]
		return touchBar
	}

	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		let touchBarItem: NSTouchBarItem?
		guard let show = self.show else { return nil }

		switch identifier {
		case .toggleModelIsFavorite:
			let name = show.attributes.library?.favoriteStatus == .favorited ? "heart.fill" : "heart"
			guard let image = UIImage(systemName: name) else { return nil }
			self.toggleShowIsFavoriteTouchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(self.toggleFavorite))
			touchBarItem = self.toggleShowIsFavoriteTouchBarItem
		case .toggleModelIsReminded:
			let name = show.attributes.library?.reminderStatus == .reminded ? "bell.fill" : "bell"
			guard let image = UIImage(systemName: name) else { return nil }
			self.toggleShowIsRemindedTouchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(self.toggleReminder))
			touchBarItem = self.toggleShowIsRemindedTouchBarItem
		default:
			touchBarItem = nil
		}
		return touchBarItem
	}
}
#endif
