//
//  MenuController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit

/**
	A class that handles the Kurozora's main (statusbar) menu.
*/
class MenuController {
	/**
		Initialize a new `MenuController` object from the given builder.

		- Parameter builder: The [UIMenuBuilder]() object used to initialize the menu controller.
	*/
	init(with builder: UIMenuBuilder) {
		builder.remove(menu: .format)
		builder.remove(menu: .spelling)
		builder.remove(menu: .substitutions)
		builder.remove(menu: .transformations)
		builder.remove(menu: .speech)
		builder.remove(menu: .openRecent)
		builder.insertSibling(MenuController.refreshPage(), beforeMenu: .fullscreen)
		builder.insertSibling(MenuController.openPreferences(), afterMenu: .about)
	}

	/**
		Builds and returns the "Refresh Page" menu.

		- Returns: The "Refresh Page" UIMenu object.
	*/
	class func refreshPage() -> UIMenu {
		let refreshPageCommand = UIKeyCommand(title: "Refresh Page", action: #selector(AppDelegate.handleRefreshControl), input: "R", modifierFlags: .command, discoverabilityTitle: "Refresh Page")
		let refreshPageMenu =
			UIMenu(title: "Refresh", identifier: UIMenu.Identifier("app.kurozora.menu.refreshPage"), options: .displayInline, children: [refreshPageCommand])
		return refreshPageMenu
	}

	/**
		Builds and returns the "Preferences" menu.

		- Returns: The "Preferences" UIMenu object.
	*/
	class func openPreferences() -> UIMenu {
		let openPreferencesCommand = UIKeyCommand(title: "Preferences...", action: #selector(AppDelegate.handlePreferences), input: ",", modifierFlags: .command, discoverabilityTitle: "Preferences...")
		let openPreferencesMenu =
			UIMenu(title: "Preferences", identifier: UIMenu.Identifier("app.kurozora.menu.preferences"), options: .displayInline, children: [openPreferencesCommand])
		return openPreferencesMenu
	}
}
