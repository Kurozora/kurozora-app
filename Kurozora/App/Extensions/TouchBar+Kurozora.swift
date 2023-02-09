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
	// MARK: - ShowDetailsViewController
	static let toggleModelIsFavorite = NSTouchBarItem.Identifier("app.kurozora.tracker.toggleModelIsFavorite")
	static let toggleModelIsReminded = NSTouchBarItem.Identifier("app.kurozora.tracker.toggleModelIsReminded")

	// MARK: - KTabbedViewController
	static let listTabBar = NSTouchBarItem.Identifier("app.kurozora.tracker.listTabBar")

	// MARK: - Library
	static let showFavorites = NSTouchBarItem.Identifier("app.kurozora.tracker.showFavorites")

	// MARK: - Feed
	static let showSettings = NSTouchBarItem.Identifier("app.kurozora.tracker.showSettings")
	static let showProfile = NSTouchBarItem.Identifier("app.kurozora.tracker.showProfile")
	static let feedComposeMessage = NSTouchBarItem.Identifier("app.kurozora.tracker.feedComposeMessage")
}
#endif
