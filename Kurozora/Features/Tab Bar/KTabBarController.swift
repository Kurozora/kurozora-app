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
		homeCollectionViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Explore", image: R.image.symbols.house(), selectedImage: R.image.symbols.house_fill())
		libraryViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Library", image: R.image.symbols.rectangle_stack(), selectedImage: R.image.symbols.rectangle_stack_fill())
		forumsViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Forums", image: R.image.symbols.doc_plaintext(), selectedImage: R.image.symbols.doc_plaintext_fill())
		notificationsViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Notifications", image: R.image.symbols.app_badge(), selectedImage: R.image.symbols.app_badge_fill())
		feedViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Feed", image: R.image.symbols.person_crop_circle(), selectedImage: R.image.symbols.person_crop_circle_fill())

        // Initialize views
		viewControllers = [homeCollectionViewController, libraryViewController, forumsViewController, notificationsViewController, feedViewController]

		setupBadgeValue()
		NotificationCenter.default.addObserver(self, selector: #selector(toggleBadge), name: .KSNotificationsBadgeIsOn, object: nil)
    }

	// MARK: - Functions
	@objc func toggleBadge() {
		setupBadgeValue()
	}

	fileprivate func setupBadgeValue() {
		if UserSettings.notificationsBadge, User.isSignedIn {
			self.tabBar.items?[3].badgeValue = "\(69)"
		} else {
			self.tabBar.items?[3].badgeValue = nil
		}
	}
}
