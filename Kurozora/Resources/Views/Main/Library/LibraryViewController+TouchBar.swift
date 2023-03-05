//
//  LibraryViewController+TouchBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

// MARK: - NSTouchBarDelegate
#if targetEnvironment(macCatalyst)
extension LibraryViewController: NSTouchBarDelegate {
	override func makeTouchBar() -> NSTouchBar? {
		var itemIdentifiers: [NSTouchBarItem.Identifier] = [
			.fixedSpaceSmall,
			.fixedSpaceSmall
		]
		let touchBar = NSTouchBar()
		touchBar.delegate = self
		if User.isSignedIn {
			itemIdentifiers.append(contentsOf: [
				.listTabBar,
				.flexibleSpace,
				.showFavorites
			])
		}
		touchBar.defaultItemIdentifiers = itemIdentifiers
		return touchBar
	}

	func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
		let touchBarItem: NSTouchBarItem?

		switch identifier {
		case .listTabBar:
			let labels: [String] = KKLibrary.Status.all.map { libraryStatus in
				switch self.libraryKind {
				case .shows:
					return libraryStatus.showStringValue
				case .literatures:
					return libraryStatus.literatureStringValue
				case .games:
					return libraryStatus.gameStringValue
				}
			}

			self.tabBarTouchBarItem = NSPickerTouchBarItem(identifier: identifier, labels: labels, selectionMode: .selectOne, target: self, action: #selector(goToSelectedView(_:)))
			self.tabBarTouchBarItem?.selectedIndex = self.currentIndex ?? 0
			touchBarItem = self.tabBarTouchBarItem
		case .showFavorites:
			guard let image = UIImage(systemName: "heart.circle") else { return nil }
			touchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(self.segueToFavoriteShows))
		default:
			touchBarItem = nil
		}
		return touchBarItem
	}
}
#endif
