//
//  MenuController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

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
		builder.insertSibling(MenuController.account(), beforeMenu: .window)
	}

	/**
		Builds and returns the "Refresh Page" menu.

		- Returns: The "Refresh Page" UIMenu object.
	*/
	class func refreshPage() -> UIMenu {
		let refreshPageCommand = UIKeyCommand(title: "Refresh Page", action: #selector(AppDelegate.handleRefreshControl(_:)), input: "R", modifierFlags: .command, discoverabilityTitle: "Refresh Page")
		return UIMenu(title: "Refresh", identifier: UIMenu.Identifier("app.kurozora.menus.refreshPage"), options: .displayInline, children: [refreshPageCommand])
	}

	/**
		Builds and returns the "Preferences" menu.

		- Returns: The "Preferences" UIMenu object.
	*/
	class func openPreferences() -> UIMenu {
		let openPreferencesCommand = UIKeyCommand(title: "Preferences...", action: #selector(AppDelegate.handlePreferences(_:)), input: ",", modifierFlags: .command, discoverabilityTitle: "Preferences...")
		return UIMenu(title: "Preferences", identifier: UIMenu.Identifier("app.kurozora.menus.preferences"), options: .displayInline, children: [openPreferencesCommand])
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
			if user.attributes.isPro {
				// Add "subscribe to reminders" menu item.
				let subscribeToReminders =  UICommand(title: "Subscribe to Reminders...", action: #selector(AppDelegate.handleSubscribeToReminders(_:)), discoverabilityTitle: "Subscribe to Reminders...")
				subscriptionMenuChildren.append(subscribeToReminders)
			} else {
				// Add "updgrade to pro" menu item.
				let upgradeToPro =  UICommand(title: "Upgrade to Pro...", action: #selector(AppDelegate.handleUpgradeToPro(_:)), discoverabilityTitle: "Upgrade to Pro...")
				subscriptionMenuChildren.append(upgradeToPro)
			}
		}

		// Create the Subscription group menu.
		let subscriptionMenu = UIMenu(title: "", identifier: UIMenu.Identifier("app.kurozora.menus.subscription"), options: .displayInline, children: subscriptionMenuChildren)

		// Create the Redeem command.
		let redeemCommand = UICommand(title: "Redeem...", action: #selector(AppDelegate.handleRedeem(_:)), discoverabilityTitle: "Redeem...")

		// Create the Favorite Shows command.
		let favoriteShowsCommand = UICommand(title: "Favorite Shows", action: #selector(AppDelegate.handleFavoriteShows(_:)), discoverabilityTitle: "Favorite Shows")

		return UIMenu(title: "Account", identifier: UIMenu.Identifier("app.kurozora.menus.account"), options: [], children: [userMenu, subscriptionMenu, redeemCommand, favoriteShowsCommand])
	}
}
