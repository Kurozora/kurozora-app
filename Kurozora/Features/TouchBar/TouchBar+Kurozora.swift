//
//  TouchBar+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 30/12/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit

#if targetEnvironment(macCatalyst)
extension NSTouchBarItem.Identifier {
	// MARK: - Misc
	static let toggleSearchBar = NSTouchBarItem.Identifier("app.kurozora.tracker.toggleSearchBar")

	// MARK: - ShowDetailsViewController
	static let toggleShowIsFavorite = NSTouchBarItem.Identifier("app.kurozora.tracker.toggleShowIsFavorite")
	static let toggleShowIsReminded = NSTouchBarItem.Identifier("app.kurozora.tracker.toggleShowIsReminded")

	// MARK: - KTabbedViewController
	static let listTabBar = NSTouchBarItem.Identifier("app.kurozora.tracker.listTabBar")

	// MARK: - Library
	static let showFavorites = NSTouchBarItem.Identifier("app.kurozora.tracker.showFavorites")

	// MARK: - Forums
	static let forumsComposeThread = NSTouchBarItem.Identifier("app.kurozora.tracker.forumsComposeThread")
}
#endif
