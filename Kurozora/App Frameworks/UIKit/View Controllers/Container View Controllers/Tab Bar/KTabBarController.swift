//
//  KTabBarController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import ESTabBarController_swift

class KTabBarController: ESTabBarController {
	// MARK: - Properties
	fileprivate var once: Bool = false

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if !once {
			self.tabBar.isTranslucent = true
			self.tabBar.itemPositioning = .centered
			self.tabBar.backgroundColor = .clear
			self.tabBar.barStyle = .default

			once = true
		}
	}

    override func viewDidLoad() {
		super.viewDidLoad()

        // Instantiate views
		let homeCollectionViewController = R.storyboard.home.homeKNavigationController()!
		let libraryViewController = R.storyboard.library.libraryKNavigationController()!
		let forumsViewController = R.storyboard.forums.forumsKNavigationController()!
		let notificationsViewController = R.storyboard.notifications.notificationKNvaigationController()!
		let feedTableViewController = R.storyboard.feed.feedTableKNavigationController()!

        // Setup animation, title and image
		homeCollectionViewController.tabBarItem = ESTabBarItem(BounceAnimation(), title: "Explore", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
		libraryViewController.tabBarItem = ESTabBarItem(BounceAnimation(), title: "Library", image: UIImage(systemName: "rectangle.stack"), selectedImage: UIImage(systemName: "rectangle.stack.fill"))
		forumsViewController.tabBarItem = ESTabBarItem(BounceAnimation(), title: "Forums", image: UIImage(systemName: "doc.plaintext"), selectedImage: UIImage(systemName: "doc.plaintext.fill"))
		notificationsViewController.tabBarItem = ESTabBarItem(BounceAnimation(), title: "Notifications", image: UIImage(systemName: "app.badge"), selectedImage: UIImage(systemName: "app.badge.fill"))
		feedTableViewController.tabBarItem = ESTabBarItem(BounceAnimation(), title: "Feed", image: UIImage(systemName: "person.crop.circle"), selectedImage: UIImage(systemName: "person.crop.circle.fill"))

        // Initialize views
		viewControllers = [homeCollectionViewController, libraryViewController, forumsViewController, notificationsViewController, feedTableViewController]

		setupBadgeValue()
		NotificationCenter.default.addObserver(self, selector: #selector(toggleBadge), name: .KSNotificationsBadgeIsOn, object: nil)
    }

	// MARK: - Functions
	/// Toggles the badge on/off on the tab bar item.
	@objc func toggleBadge() {
		setupBadgeValue()
	}

	/// Sets up the badge value on the tab bar item.
	fileprivate func setupBadgeValue() {
		if UserSettings.notificationsBadge, User.isSignedIn {
			self.tabBar.items?[3].badgeValue = "\(69)"
		} else {
			self.tabBar.items?[3].badgeValue = nil
		}
	}
}
