//
//  KTabBarController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class KTabBarController: ESTabBarController {
	fileprivate var once: Bool = false

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
		let homeStoryboard = UIStoryboard(name: "home", bundle: nil)
		let homeCollectionViewController = homeStoryboard.instantiateInitialViewController() as! KNavigationController

		let libraryStoryboard = UIStoryboard(name: "library", bundle: nil)
		let libraryViewController = libraryStoryboard.instantiateInitialViewController() as! KNavigationController

		let forumsStoryboard = UIStoryboard(name: "forums", bundle: nil)
		let forumsViewController = forumsStoryboard.instantiateInitialViewController() as! KNavigationController

		let notificationStoryboard = UIStoryboard(name: "notification", bundle: nil)
		let notificationsViewController = notificationStoryboard.instantiateInitialViewController() as! KNavigationController

		let feedStoryboard = UIStoryboard(name: "feed", bundle: nil)
		let feedViewController = feedStoryboard.instantiateInitialViewController() as! KNavigationController

        // Setup animation, title and image
		homeCollectionViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Explore", image: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "home"))
		libraryViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Library", image: #imageLiteral(resourceName: "list"), selectedImage: #imageLiteral(resourceName: "list"))
		forumsViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Forums", image: #imageLiteral(resourceName: "forums"), selectedImage: #imageLiteral(resourceName: "forums"))
		notificationsViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Notifications", image: #imageLiteral(resourceName: "notification"), selectedImage: #imageLiteral(resourceName: "notification"))
		feedViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Feed", image: #imageLiteral(resourceName: "profile"), selectedImage: #imageLiteral(resourceName: "profile"))

        // Initialize views
		viewControllers = [homeCollectionViewController, libraryViewController, forumsViewController, notificationsViewController, feedViewController]

		setupBadgeValue()
		NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeValue(_:)), name: updateNotificationsBadgeValueNotification, object: nil)
    }

	// MARK: - Functions
	fileprivate func setupBadgeValue() {
		self.tabBar.items?[3].badgeValue = "69"
	}

	@objc func updateBadgeValue(_ notification: Notification) {
		self.tabBar.items?[3].badgeValue = "69"
	}
}
