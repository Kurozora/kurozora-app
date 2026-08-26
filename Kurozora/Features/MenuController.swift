//
//  MenuController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 29/01/2021.
//  Copyright © 2021 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

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
		builder.insertSibling(MenuController.searchMenu(), beforeMenu: .fullscreen)
		builder.insertSibling(MenuController.navigationMenu(), beforeMenu: .fullscreen)
		// The fullscreen group anchors the video commands when the system offers it.
		if builder.menu(for: .fullscreen) != nil {
			builder.insertSibling(MenuController.videoViewMenu(), beforeMenu: .fullscreen)
		} else {
			builder.insertChild(MenuController.videoViewMenu(), atEndOfMenu: .view)
		}

		builder.insertSibling(MenuController.playbackMenu(), beforeMenu: .window)
		builder.insertSibling(MenuController.windowMenu(), beforeMenu: .bringAllToFront)

		if #available(iOS 17.0, *) {
			builder.insertSibling(MenuController.miniPlayerShortcutsMenu(), beforeMenu: .bringAllToFront)
		}

//		builder.insertSibling(MenuController.refreshPageMenu(), beforeMenu: .fullscreen)
		builder.insertSibling(MenuController.openSettingsMenu(), afterMenu: .about)
		builder.insertSibling(MenuController.accountMenu(), beforeMenu: .window)

		if let minimizeAndZoom = MenuController.minimizeAndZoom(with: builder) {
			// Remove and add own menu
			builder.remove(menu: .minimizeAndZoom)
			builder.insertChild(minimizeAndZoom, atStartOfMenu: .window)
		}

		#if DEBUG
		builder.insertSibling(MenuController.debugMenu(), beforeMenu: .window)
		#endif
	}

	/// Builds and returns the "Window" menu.
	///
	/// - Returns: The "Window" UIMenu object.
	class func windowMenu() -> UIMenu {
		let newSceneCommand = MenuController.newSceneCommand()
		let miniPlayerCommand = MenuController.miniPlayerCommand()
		return UIMenu(identifier: UIMenu.Identifier("app.kurozora.menus.newScene"), options: .displayInline, children: [
			newSceneCommand,
			miniPlayerCommand
		])
	}

	/// Builds and returns the "Home" command.
	///
	/// - Returns: The "Home" UIKeyCommand object.
	class func newSceneCommand() -> UIKeyCommand {
		return UIKeyCommand(title: L10n.home, action: #selector(AppDelegate.handleNewScene), input: "0", modifierFlags: .command, discoverabilityTitle: L10n.toggleHome)
	}

	/// Builds and returns the "MiniPlayer" command.
	///
	/// - Returns: The "MiniPlayer" UIKeyCommand object.
	class func miniPlayerCommand() -> UIKeyCommand {
		return UIKeyCommand(title: L10n.miniPlayer, action: #selector(AppDelegate.handleMiniPlayer(_:)), input: "M", modifierFlags: [.alternate, .command], discoverabilityTitle: L10n.toggleMiniPlayer)
	}

	/// Builds and returns the "MiniPlayer" menu.
	///
	/// - Returns: The "MiniPlayer" UIMenu object.
	@available(iOS 17.0, *)
	class func miniPlayerShortcutsMenu() -> UIMenu {
		return UIMenu(title: L10n.miniPlayer, identifier: UIMenu.Identifier("app.kurozora.menus.miniPlayer"), options: .displayInline, children: MenuController.miniPlayerShortcutsCommands())
	}

	/// Builds and returns the "MiniPlayer" commands.
	///
	/// - Returns: The "MiniPlayer" UIKeyCommand objects.
	@available(iOS 17.0, *)
	class func miniPlayerShortcutsCommands() -> [UIKeyCommand] {
		return MiniPlayerViewController.viewOptionCommands()
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

	/// Builds and returns the video group of the "View" menu.
	///
	/// - Returns: The video "View" UIMenu object.
	class func videoViewMenu() -> UIMenu {
		let actualSizeCommand = UIKeyCommand(title: L10n.actualSize, action: #selector(TrailerFullscreenViewController.zoomActualSize), input: "0", modifierFlags: .command, discoverabilityTitle: L10n.actualSize)
		let increaseSizeCommand = UIKeyCommand(title: L10n.increaseSize, action: #selector(TrailerFullscreenViewController.zoomIn), input: "+", modifierFlags: .command, discoverabilityTitle: L10n.increaseSize)
		let decreaseSizeCommand = UIKeyCommand(title: L10n.decreaseSize, action: #selector(TrailerFullscreenViewController.zoomOut), input: "-", modifierFlags: .command, discoverabilityTitle: L10n.decreaseSize)
		let sizeMenu = UIMenu(identifier: UIMenu.Identifier("app.kurozora.menus.videoView.size"), options: .displayInline, children: [
			actualSizeCommand,
			increaseSizeCommand,
			decreaseSizeCommand
		])

		let fullscreenCommand = UIKeyCommand(title: L10n.fullscreen, action: #selector(TrailerFullscreenViewController.toggleTrailerFullscreen), input: "F", modifierFlags: .command, discoverabilityTitle: L10n.fullscreen)
		let pictureInPictureCommand = UIKeyCommand(title: L10n.pictureInPicture, action: #selector(TrailerFullscreenViewController.togglePictureInPicture), input: "P", modifierFlags: [.command, .alternate], discoverabilityTitle: L10n.pictureInPicture)
		let screenMenu = UIMenu(identifier: UIMenu.Identifier("app.kurozora.menus.videoView.screen"), options: .displayInline, children: [
			fullscreenCommand,
			pictureInPictureCommand
		])

		return UIMenu(identifier: UIMenu.Identifier("app.kurozora.menus.videoView"), options: .displayInline, children: [sizeMenu, screenMenu])
	}

	/// Builds and returns the "Time Display" menu.
	///
	/// - Returns: The "Time Display" UIMenu object.
	class func timeDisplayMenu() -> UIMenu {
		let elapsedTimeCommand = UICommand(title: L10n.elapsedTime, action: #selector(TrailerFullscreenViewController.showElapsedTime), discoverabilityTitle: L10n.elapsedTime)
		let frameCountCommand = UICommand(title: L10n.frameCount, action: #selector(TrailerFullscreenViewController.showFrameCount), discoverabilityTitle: L10n.frameCount)
		let readingMenu = UIMenu(identifier: UIMenu.Identifier("app.kurozora.menus.timeDisplay.reading"), options: .displayInline, children: [
			elapsedTimeCommand,
			frameCountCommand
		])

		let goToTimestampCommand = UIKeyCommand(title: "\(L10n.goToTimestamp)…", action: #selector(TrailerFullscreenViewController.goToTimestamp), input: "K", modifierFlags: [.command, .shift], discoverabilityTitle: L10n.goToTimestamp)
		let goToFrameCommand = UIKeyCommand(title: "\(L10n.goToFrame)…", action: #selector(TrailerFullscreenViewController.goToFrame), input: "I", modifierFlags: [.command, .shift], discoverabilityTitle: L10n.goToFrame)
		let jumpMenu = UIMenu(identifier: UIMenu.Identifier("app.kurozora.menus.timeDisplay.jump"), options: .displayInline, children: [
			goToTimestampCommand,
			goToFrameCommand
		])

		return UIMenu(title: L10n.timeDisplay, identifier: UIMenu.Identifier("app.kurozora.menus.timeDisplay"), children: [readingMenu, jumpMenu])
	}

	/// Builds and returns the "Playback" menu.
	///
	/// - Returns: The "Playback" UIMenu object.
	class func playbackMenu() -> UIMenu {
		let playPauseCommand = UIKeyCommand(title: L10n.playPause, action: #selector(TrailerFullscreenViewController.togglePlayPause), input: " ", discoverabilityTitle: L10n.playPause)
		let stepBackwardCommand = UIKeyCommand(title: L10n.stepBackward, action: #selector(TrailerFullscreenViewController.stepBackward), input: UIKeyCommand.inputLeftArrow, discoverabilityTitle: L10n.stepBackward)
		let stepForwardCommand = UIKeyCommand(title: L10n.stepForward, action: #selector(TrailerFullscreenViewController.stepForward), input: UIKeyCommand.inputRightArrow, discoverabilityTitle: L10n.stepForward)
		let rewindCommand = UIKeyCommand(title: L10n.rewind, action: #selector(TrailerFullscreenViewController.keyboardRewind), input: UIKeyCommand.inputLeftArrow, modifierFlags: .command, discoverabilityTitle: L10n.rewind)
		let fastForwardCommand = UIKeyCommand(title: L10n.fastForward, action: #selector(TrailerFullscreenViewController.keyboardFastForward), input: UIKeyCommand.inputRightArrow, modifierFlags: .command, discoverabilityTitle: L10n.fastForward)
		let goToBeginningCommand = UIKeyCommand(title: L10n.goToBeginning, action: #selector(TrailerFullscreenViewController.jumpToBeginning), input: UIKeyCommand.inputLeftArrow, modifierFlags: .alternate, discoverabilityTitle: L10n.goToBeginning)
		let goToEndCommand = UIKeyCommand(title: L10n.goToEnd, action: #selector(TrailerFullscreenViewController.jumpToEnd), input: UIKeyCommand.inputRightArrow, modifierFlags: .alternate, discoverabilityTitle: L10n.goToEnd)
		let transportMenu = UIMenu(identifier: UIMenu.Identifier("app.kurozora.menus.playback.transport"), options: .displayInline, children: [
			playPauseCommand,
			stepBackwardCommand,
			stepForwardCommand,
			rewindCommand,
			fastForwardCommand,
			goToBeginningCommand,
			goToEndCommand
		])

		let increaseVolumeCommand = UIKeyCommand(title: L10n.increaseVolume, action: #selector(TrailerFullscreenViewController.increaseVolume), input: UIKeyCommand.inputUpArrow, discoverabilityTitle: L10n.increaseVolume)
		let decreaseVolumeCommand = UIKeyCommand(title: L10n.decreaseVolume, action: #selector(TrailerFullscreenViewController.decreaseVolume), input: UIKeyCommand.inputDownArrow, discoverabilityTitle: L10n.decreaseVolume)
		let fullVolumeCommand = UIKeyCommand(title: L10n.fullVolume, action: #selector(TrailerFullscreenViewController.maximizeVolume), input: UIKeyCommand.inputUpArrow, modifierFlags: .alternate, discoverabilityTitle: L10n.fullVolume)
		let muteCommand = UIKeyCommand(title: L10n.mute, action: #selector(TrailerFullscreenViewController.muteVolume), input: UIKeyCommand.inputDownArrow, modifierFlags: .alternate, discoverabilityTitle: L10n.mute)
		let volumeMenu = UIMenu(identifier: UIMenu.Identifier("app.kurozora.menus.playback.volume"), options: .displayInline, children: [
			increaseVolumeCommand,
			decreaseVolumeCommand,
			fullVolumeCommand,
			muteCommand
		])

		return UIMenu(title: L10n.playback, identifier: UIMenu.Identifier("app.kurozora.menus.playback"), children: [transportMenu, MenuController.timeDisplayMenu(), volumeMenu])
	}

	/// Builds and returns the "Navigation" menu.
	///
	/// - Returns: The "Navigation" UIMenu object.
	class func navigationMenu() -> UIMenu {
		let backCommand = UIKeyCommand(title: L10n.back, action: #selector(AppDelegate.handleNavigateBack(_:)), input: "[", modifierFlags: .command, discoverabilityTitle: L10n.back)
		let forwardCommand = UIKeyCommand(title: L10n.forward, action: #selector(AppDelegate.handleNavigateForward(_:)), input: "]", modifierFlags: .command, discoverabilityTitle: L10n.forward)
		return UIMenu(title: L10n.navigation, identifier: UIMenu.Identifier("app.kurozora.menus.navigation"), options: .displayInline, children: [backCommand, forwardCommand])
	}

	/// Builds and returns the "Refresh Page" menu.
	///
	/// - Returns: The "Refresh Page" UIMenu object.
	class func refreshPageMenu() -> UIMenu {
		let refreshPageCommand = UIKeyCommand(title: L10n.refreshPage, action: #selector(AppDelegate.handleRefreshControl), input: "R", modifierFlags: .command, discoverabilityTitle: L10n.refreshPage)
		return UIMenu(title: L10n.refresh, identifier: UIMenu.Identifier("app.kurozora.menus.refreshPage"), options: .displayInline, children: [refreshPageCommand])
	}

	/// Builds and returns the "Settings" menu.
	///
	/// - Returns: The "Settings" UIMenu object.
	class func openSettingsMenu() -> UIMenu {
		let openSettingsCommand = UIKeyCommand(title: L10n.settingsCommand, action: #selector(AppDelegate.handleSettings(_:)), input: ",", modifierFlags: .command, discoverabilityTitle: L10n.settingsCommand)
		return UIMenu(title: L10n.settings, identifier: UIMenu.Identifier("app.kurozora.menus.settings"), options: .displayInline, children: [openSettingsCommand])
	}

	///  Builds and returns the "Search" menu.
	///
	///  - Returns: The "Search" UIMenu object.
	class func searchMenu() -> UIMenu {
		let searchPageCommand = UIKeyCommand(title: L10n.search, action: #selector(AppDelegate.handleSearch(_:)), input: "F", modifierFlags: .command, discoverabilityTitle: L10n.search)
		return UIMenu(title: L10n.search, identifier: UIMenu.Identifier("app.kurozora.menus.search"), options: .displayInline, children: [searchPageCommand])
	}

	/// Builds and returns the "Account" menu.
	///
	/// - Returns: The "Account" UIMenu object.
	class func accountMenu() -> UIMenu {
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

			// Add "view my profile" menu item.
			let viewMyProfileCommand = UICommand(title: L10n.viewMyProfileCommand, action: #selector(AppDelegate.handleViewMyProfile(_:)), discoverabilityTitle: L10n.viewMyProfileCommand)
			userMenuChildren.append(viewMyProfileCommand)

			// Add "account settings" menu item.
			let accountSettingsCommand = UICommand(title: L10n.accountSettingsCommand, action: #selector(AppDelegate.handleAccountSettings(_:)), discoverabilityTitle: L10n.accountSettingsCommand)
			userMenuChildren.append(accountSettingsCommand)

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

		var membershipMenuChildren: [UIMenuElement] = []
		if User.isSignedIn, let user = User.current {
			if user.attributes.isSubscribed {
				// Add "subscribe to reminders" menu item.
				let subscribeToRemindersCommand = UICommand(title: L10n.subscribeToRemindersCommand, action: #selector(AppDelegate.handleSubscribeToReminders(_:)), discoverabilityTitle: L10n.subscribeToRemindersCommand)
				membershipMenuChildren.append(subscribeToRemindersCommand)
			} else {
				// Add "upgrade to Kurozora+" menu item.
				let upgradeToKurozoraPlusCommand = UICommand(title: L10n.upgradeToKurozoraPlus, action: #selector(AppDelegate.handleUpgradeToKurozoraPlus(_:)), discoverabilityTitle: L10n.upgradeToKurozoraPlus)
				membershipMenuChildren.append(upgradeToKurozoraPlusCommand)
			}
		}

		// Add "redeem" menu item.
		let redeemCommand = UICommand(title: L10n.redeemCommand, action: #selector(AppDelegate.handleRedeem(_:)), discoverabilityTitle: L10n.redeemCommand)
		membershipMenuChildren.append(redeemCommand)

		// Add "manage subscriptions" menu item. The App Store sheet is unavailable on macOS.
		#if !targetEnvironment(macCatalyst)
		if !ProcessInfo.processInfo.isiOSAppOnMac {
			let manageSubscriptionsCommand = UICommand(title: L10n.manageSubscriptions, action: #selector(AppDelegate.handleManageSubscriptions(_:)), discoverabilityTitle: L10n.manageSubscriptions)
			membershipMenuChildren.append(manageSubscriptionsCommand)
		}
		#endif

		// Add "restore purchase" menu item.
		let restorePurchaseCommand = UICommand(title: L10n.restorePurchase, action: #selector(AppDelegate.handleRestorePurchase(_:)), discoverabilityTitle: L10n.restorePurchase)
		membershipMenuChildren.append(restorePurchaseCommand)

		// Create the Membership group menu.
		let membershipMenu = UIMenu(title: "", identifier: UIMenu.Identifier("app.kurozora.menus.membership"), options: .displayInline, children: membershipMenuChildren)

		// Create the Library command.
		let libraryCommand = UICommand(title: L10n.library, action: #selector(AppDelegate.handleLibrary(_:)), discoverabilityTitle: L10n.library)

		// Create the Favorites command.
		let favoritesCommand = UICommand(title: L10n.favorites, action: #selector(AppDelegate.handleFavorites(_:)), discoverabilityTitle: L10n.favorites)

		// Create the Reminders command.
		let remindersCommand = UICommand(title: L10n.reminders, action: #selector(AppDelegate.handleReminders(_:)), discoverabilityTitle: L10n.reminders)

		// Create the Switch Account group menu.
		let switchAccountMenu = MenuController.switchAccountMenu()

		return UIMenu(title: L10n.account, identifier: UIMenu.Identifier("app.kurozora.menus.account"), options: [], children: [userMenu, membershipMenu, libraryCommand, favoritesCommand, remindersCommand, switchAccountMenu])
	}

	/// Builds and returns the "Switch Account" menu.
	///
	/// - Returns: The "Switch Account" UIMenu object.
	class func switchAccountMenu() -> UIMenu {
		let accounts = AccountManager.shared.allAccounts()
		let selectedSlug = UserSettings.selectedAccount
		let accountCommands: [UIMenuElement] = accounts.count > 1 ? accounts.map { account in
			let title = account.username ?? account.slug
			return UICommand(title: title, action: #selector(AppDelegate.handleSwitchAccount(_:)), propertyList: account.slug, discoverabilityTitle: title, state: account.slug == selectedSlug ? .on : .off)
		} : []

		return UIMenu(title: L10n.switchAccount, identifier: UIMenu.Identifier("app.kurozora.menus.switchAccount"), options: .displayInline, children: accountCommands)
	}

	#if DEBUG
	/// Builds and returns the "Debug" menu.
	///
	/// - Returns: The "Debug" UIMenu object.
	class func debugMenu() -> UIMenu {
		let showFlexCommand = UIKeyCommand(title: "Show FLEX Menu", action: #selector(AppDelegate.handleShowFlex(_:)), input: "F", modifierFlags: [.command, .control, .alternate], discoverabilityTitle: "Show FLEX Menu")
		let toggleFlexOverlayCommand = UIKeyCommand(title: "Toggle FLEX Overlay", action: #selector(AppDelegate.handleToggleFlexOverlay(_:)), input: "E", modifierFlags: [.command, .control, .alternate], discoverabilityTitle: "Toggle FLEX Overlay")
		return UIMenu(title: "Debug", identifier: UIMenu.Identifier("app.kurozora.menus.debug"), options: [], children: [showFlexCommand, toggleFlexOverlayCommand])
	}
	#endif
}
