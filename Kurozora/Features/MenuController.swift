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
	/// - Parameter builder: The [UIMenuBuilder](https://developer.apple.com/documentation/uikit/uimenubuilder?language=swift) object used to initialize the menu controller.
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

		#if DEBUG
		builder.insertSibling(MenuController.debug(), beforeMenu: .window)
		#endif
	}

	/// Builds and returns the "Home" menu.
	///
	/// - Parameter builder: The [UIMenuBuilder](https://developer.apple.com/documentation/uikit/uimenubuilder?language=swift) object used to initialize the menu controller.
	///
	/// - Returns: The "Minimize and Zoom" menu.
	class func newScene() -> UIMenu {
		let newSceneCommand = UIKeyCommand(title: L10n.home, action: #selector(AppDelegate.handleNewScene), input: "0", modifierFlags: .command, discoverabilityTitle: L10n.toggleHome)
		return UIMenu(title: L10n.home, identifier: UIMenu.Identifier("app.kurozora.menus.newScene"), options: .displayInline, children: [newSceneCommand])
	}

	/// Builds and returns the "Minimize and Zoom" menu.
	///
	/// - Parameter builder: The [UIMenuBuilder](https://developer.apple.com/documentation/uikit/uimenubuilder?language=swift) object used to initialize the menu controller.
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
		let refreshPageCommand = UIKeyCommand(title: L10n.refreshPage, action: #selector(AppDelegate.handleRefreshControl), input: "R", modifierFlags: .command, discoverabilityTitle: L10n.refreshPage)
		return UIMenu(title: L10n.refresh, identifier: UIMenu.Identifier("app.kurozora.menus.refreshPage"), options: .displayInline, children: [refreshPageCommand])
	}

	/// Builds and returns the "Settings" menu.
	///
	/// - Returns: The "Settings" UIMenu object.
	class func openSettings() -> UIMenu {
		let openSettingsCommand = UIKeyCommand(title: L10n.settingsCommand, action: #selector(AppDelegate.handleSettings(_:)), input: ",", modifierFlags: .command, discoverabilityTitle: L10n.settingsCommand)
		return UIMenu(title: L10n.settings, identifier: UIMenu.Identifier("app.kurozora.menus.settings"), options: .displayInline, children: [openSettingsCommand])
	}

	///  Builds and returns the "Search" menu.
	///
	///  - Returns: The "Search" UIMenu object.
	class func search() -> UIMenu {
		let searchPageCommand = UIKeyCommand(title: L10n.search, action: #selector(AppDelegate.handleSearch(_:)), input: "F", modifierFlags: .command, discoverabilityTitle: L10n.search)
		return UIMenu(title: L10n.search, identifier: UIMenu.Identifier("app.kurozora.menus.search"), options: .displayInline, children: [searchPageCommand])
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
			let viewMyAccountCommand = UICommand(title: L10n.viewMyAccount, action: #selector(AppDelegate.handleViewMyAccount(_:)), discoverabilityTitle: L10n.viewMyAccount)
			userMenuChildren.append(viewMyAccountCommand)

			// Add "sign out" menu item.
			let signOutCommand = UICommand(title: L10n.signOut, action: #selector(AppDelegate.handleSignOut(_:)), discoverabilityTitle: L10n.signOut)
			userMenuChildren.append(signOutCommand)
		} else {
			// Add "sign in" menu item.
			let signInCommand = UICommand(title: L10n.signIn, action: #selector(AppDelegate.handleSignIn(_:)), discoverabilityTitle: L10n.signIn)
			userMenuChildren.append(signInCommand)
		}

		// Create the User group menu.
		let userMenu = UIMenu(title: "", identifier: UIMenu.Identifier("app.kurozora.menus.user"), options: .displayInline, children: userMenuChildren)

		var subscriptionMenuChildren: [UIMenuElement] = []
		if User.isSignedIn, let user = User.current {
			if user.attributes.isSubscribed {
				// Add "subscribe to reminders" menu item.
				let subscribeToReminders =  UICommand(title: L10n.subscribeToRemindersCommand, action: #selector(AppDelegate.handleSubscribeToReminders(_:)), discoverabilityTitle: L10n.subscribeToRemindersCommand)
				subscriptionMenuChildren.append(subscribeToReminders)
			} else {
				// Add "updgrade to Kurozora+" menu item.
				let upgradeToKurozoraPlus =  UICommand(title: L10n.upgradeToKurozoraPlus, action: #selector(AppDelegate.handleUpgradeToKurozoraPlus(_:)), discoverabilityTitle: L10n.upgradeToKurozoraPlus)
				subscriptionMenuChildren.append(upgradeToKurozoraPlus)
			}
		}

		// Create the Subscription group menu.
		let subscriptionMenu = UIMenu(title: "", identifier: UIMenu.Identifier("app.kurozora.menus.subscription"), options: .displayInline, children: subscriptionMenuChildren)

		// Create the Redeem command.
		let redeemCommand = UICommand(title: L10n.redeemCommand, action: #selector(AppDelegate.handleRedeem(_:)), discoverabilityTitle: L10n.redeemCommand)

		// Create the Favorites command.
		let favoritesCommand = UICommand(title: L10n.favorites, action: #selector(AppDelegate.handleFavorites(_:)), discoverabilityTitle: L10n.favorites)

		return UIMenu(title: L10n.account, identifier: UIMenu.Identifier("app.kurozora.menus.account"), options: [], children: [userMenu, subscriptionMenu, redeemCommand, favoritesCommand])
	}

	#if DEBUG
	/// Builds and returns the "Debug" menu.
	///
	/// - Returns: The "Debug" UIMenu object.
	class func debug() -> UIMenu {
		let showFlexCommand = UIKeyCommand(title: "Show FLEX Menu", action: #selector(AppDelegate.handleShowFlex(_:)), input: "F", modifierFlags: [.command, .control, .alternate], discoverabilityTitle: "Show FLEX Menu")
		let toggleFlexOverlayCommand = UIKeyCommand(title: "Toggle FLEX Overlay", action: #selector(AppDelegate.handleToggleFlexOverlay(_:)), input: "E", modifierFlags: [.command, .control, .alternate], discoverabilityTitle: "Toggle FLEX Overlay")
		return UIMenu(title: "Debug", identifier: UIMenu.Identifier("app.kurozora.menus.debug"), options: [], children: [showFlexCommand, toggleFlexOverlayCommand])
	}
	#endif
}
