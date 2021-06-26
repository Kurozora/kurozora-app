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
			let labels: [String] = KKLibrary.Status.all.map { (libraryStatus) -> String in
				libraryStatus.stringValue
			}

			tabBarTouchBarItem = NSPickerTouchBarItem(identifier: identifier, labels: labels, selectionMode: .selectOne, target: self, action: #selector(goToSelectedView(_:)))
			tabBarTouchBarItem?.selectedIndex = self.currentIndex ?? 0
			touchBarItem = tabBarTouchBarItem
		case .showFavorites:
			guard let image = UIImage(systemName: "heart.circle") else { return nil }
			touchBarItem = NSButtonTouchBarItem(identifier: identifier, image: image, target: self, action: #selector(segueToFavoriteShows))
		default:
			touchBarItem = nil
		}
		return touchBarItem
	}
}
#endif
