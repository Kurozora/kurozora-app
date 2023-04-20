//
//  MenuController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

/// A class that handles the Kurozora's main (statusbar) menu.
class MenuController {
	/// Initialize a new `MenuController` object from the given builder.
	///
	/// - Parameter builder: The [UIMenuBuilder](doc://com.apple.documentation/documentation/uikit/uimenubuilder?language=swift) object used to initialize the menu controller.
	init(with builder: UIMenuBuilder) {
		builder.remove(menu: .newScene)
		builder.remove(menu: .openRecent)
		builder.remove(menu: .format)
		builder.remove(menu: .toolbar)
		builder.insertSibling(MenuController.search(), beforeMenu: .fullscreen)
		builder.insertSibling(MenuController.newScene(), beforeMenu: .bringAllToFront)
//		builder.insertSibling(MenuController.refreshPage(), beforeMenu: .fullscreen)
		builder.insertSibling(MenuController.openSettings(), afterMenu: .about)
		builder.insertSibling(MenuController.account(), beforeMenu: .window)

		if let minimizeAndZoom = MenuController.minimizeAndZoom(with: builder) {
			// Remove and add own menu
			builder.remove(menu: .minimizeAndZoom)
			builder.insertChild(minimizeAndZoom, atStartOfMenu: .window)
		}
	}

	/// Builds and returns the "Home" menu.
	///
	/// - Parameter builder: The [UIMenuBuilder](doc://com.apple.documentation/documentation/uikit/uimenubuilder?language=swift) object used to initialize the menu controller.
	///
	/// - Returns: The "Minimize and Zoom" menu.
	class func newScene() -> UIMenu {
		let newSceneCommand = UIKeyCommand(title: "Home", action: #selector(AppDelegate.handleNewScene), input: "0", modifierFlags: .command, discoverabilityTitle: "Toggle Home")
		return UIMenu(title: "Home", identifier: UIMenu.Identifier("app.kurozora.menus.newScene"), options: .displayInline, children: [newSceneCommand])
	}

	/// Builds and returns the "Minimize and Zoom" menu.
	///
	/// - Parameter builder: The [UIMenuBuilder](doc://com.apple.documentation/documentation/uikit/uimenubuilder?language=swift) object used to initialize the menu controller.
	///
	/// - Returns: The "Minimize and Zoom" menu.
	class func minimizeAndZoom(with builder: UIMenuBuilder) -> UIMenu? {
		guard let minimizeAndZoomMenu = builder.menu(for: .minimizeAndZoom) else { return nil }
		let commands: [UIMenuElement] = minimizeAndZoomMenu.children.map { element in
			if let keyCommand = element as? UICommand, keyCommand.title == "Zoom" {
				return UIKeyCommand(title: keyCommand.title, image: keyCommand.image, action: keyCommand.action, input: "\r", modifierFlags: [.shift, .command], propertyList: keyCommand.propertyList, alternates: keyCommand.alternates, discoverabilityTitle: keyCommand.discoverabilityTitle, attributes: keyCommand.attributes, state: keyCommand.state)
			} else {
				return element
			}
		}
		return UIMenu(title: minimizeAndZoomMenu.title, image: minimizeAndZoomMenu.image, identifier: minimizeAndZoomMenu.identifier, options: minimizeAndZoomMenu.options, children: commands)
	}

	/// Builds and returns the "Refresh Page" menu.
	///
	/// - Returns: The "Refresh Page" UIMenu object.
	class func refreshPage() -> UIMenu {
		let refreshPageCommand = UIKeyCommand(title: "Refresh Page", action: #selector(AppDelegate.handleRefreshControl), input: "R", modifierFlags: .command, discoverabilityTitle: "Refresh Page")
		return UIMenu(title: "Refresh", identifier: UIMenu.Identifier("app.kurozora.menus.refreshPage"), options: .displayInline, children: [refreshPageCommand])
	}

	/// Builds and returns the "Settings" menu.
	///
	/// - Returns: The "Settings" UIMenu object.
	class func openSettings() -> UIMenu {
		let openSettingsCommand = UIKeyCommand(title: "Settings...", action: #selector(AppDelegate.handleSettings(_:)), input: ",", modifierFlags: .command, discoverabilityTitle: "Settings...")
		return UIMenu(title: "Settings", identifier: UIMenu.Identifier("app.kurozora.menus.settings"), options: .displayInline, children: [openSettingsCommand])
	}

	///  Builds and returns the "Refresh Page" menu.
	///
	///  - Returns: The "Refresh Page" UIMenu object.
	class func search() -> UIMenu {
		let refreshPageCommand = UIKeyCommand(title: "Search", action: #selector(AppDelegate.handleSearch(_:)), input: "F", modifierFlags: .command, discoverabilityTitle: "Search")
		return UIMenu(title: "Serach", identifier: UIMenu.Identifier("app.kurozora.menus.search"), options: .displayInline, children: [refreshPageCommand])
	}

	class func account() -> UIMenu {
		var userMenuChildren: [UIMenuElement] = []
		if User.isSignedIn, let user = User.current {
			// Add "username" menu item.
			let usernameCommand = UICommand(title: user.attributes.username, action: #selector(AppDelegate.handleUsername(_:)), discoverabilityTitle: user.attributes.username, attributes: .disabled)
			userMenuChildren.append(usernameCommand)

			// Add "email" menu item.
			if let email = user.attributes.email {
				let emailCommand = UICommand(title: email, action: #selector(AppDelegate.handleEmail(_:)), discoverabilityTitle: email, attributes: .disabled)
				userMenuChildren.append(emailCommand)
			}

			// Add "view my account" menu item.
			let viewMyAccountCommand = UICommand(title: "View My Account...", action: #selector(AppDelegate.handleViewMyAccount(_:)), discoverabilityTitle: "View My Account...")
			userMenuChildren.append(viewMyAccountCommand)

			// Add "sign out" menu item.
			let signOutCommand = UICommand(title: "Sign Out", action: #selector(AppDelegate.handleSignOut(_:)), discoverabilityTitle: "Sign Out")
			userMenuChildren.append(signOutCommand)
		} else {
			// Add "sign in" menu item.
			let signInCommand = UICommand(title: "Sign In", action: #selector(AppDelegate.handleSignIn(_:)), discoverabilityTitle: "Sign In")
			userMenuChildren.append(signInCommand)
		}

		// Create the User group menu.
		let userMenu = UIMenu(title: "", identifier: UIMenu.Identifier("app.kurozora.menus.user"), options: .displayInline, children: userMenuChildren)

		var subscriptionMenuChildren: [UIMenuElement] = []
		if User.isSignedIn, let user = User.current {
			if user.attributes.isSubscribed {
				// Add "subscribe to reminders" menu item.
				let subscribeToReminders =  UICommand(title: "Subscribe to Reminders...", action: #selector(AppDelegate.handleSubscribeToReminders(_:)), discoverabilityTitle: "Subscribe to Reminders...")
				subscriptionMenuChildren.append(subscribeToReminders)
			} else {
				// Add "updgrade to Kurozora+" menu item.
				let upgradeToKurozoraPlus =  UICommand(title: "Upgrade to Kurozora+...", action: #selector(AppDelegate.handleUpgradeToKurozoraPlus(_:)), discoverabilityTitle: "Upgrade to Kurozora+...")
				subscriptionMenuChildren.append(upgradeToKurozoraPlus)
			}
		}

		// Create the Subscription group menu.
		let subscriptionMenu = UIMenu(title: "", identifier: UIMenu.Identifier("app.kurozora.menus.subscription"), options: .displayInline, children: subscriptionMenuChildren)

		// Create the Redeem command.
		let redeemCommand = UICommand(title: "Redeem...", action: #selector(AppDelegate.handleRedeem(_:)), discoverabilityTitle: "Redeem...")

		// Create the Favorites command.
		let favoritesCommand = UICommand(title: "Favorites", action: #selector(AppDelegate.handleFavorites(_:)), discoverabilityTitle: "Favorites")

		return UIMenu(title: "Account", identifier: UIMenu.Identifier("app.kurozora.menus.account"), options: [], children: [userMenu, subscriptionMenu, redeemCommand, favoritesCommand])
	}
}
