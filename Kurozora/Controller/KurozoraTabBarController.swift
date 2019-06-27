//
//  KurozoraTabBarController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class KurozoraTabBarController: ESTabBarController {
	var once: Bool = false

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if !once {
			self.tabBar.isTranslucent = true
			self.tabBar.itemPositioning = .centered
			self.tabBar.backgroundColor = .clear
			self.tabBar.barStyle = .default
			self.tabBar.theme_tintColor = KThemePicker.tintColor.rawValue
			self.tabBar.theme_barTintColor = KThemePicker.barTintColor.rawValue

			once = true
		}
	}

    override func viewDidLoad() {
		super.viewDidLoad()

        // Instantiate views
        let homeStoryboard = UIStoryboard(name: "home", bundle: nil)
        let homeCollectionViewController = homeStoryboard.instantiateViewController(withIdentifier: "HomeCollectionViewController") as! HomeCollectionViewController
        
        let libraryStoryboard = UIStoryboard(name: "library", bundle: nil)
        let libraryViewController = libraryStoryboard.instantiateViewController(withIdentifier: "Library") as! LibraryViewController
        
        let forumsStoryboard = UIStoryboard(name: "forums", bundle: nil)
        let forumsViewController = forumsStoryboard.instantiateViewController(withIdentifier: "Forums") as! ForumsViewController
        
        let notificationStoryboard = UIStoryboard(name: "notification", bundle: nil)
        let notificationsViewController = notificationStoryboard.instantiateViewController(withIdentifier: "Notification") as! NotificationsViewController
        
        let feedStoryboard = UIStoryboard(name: "feed", bundle: nil)
        let feedTabsViewController = feedStoryboard.instantiateViewController(withIdentifier: "FeedTabsViewController") as! FeedTabsViewController
        
        // Setup animation, title and image
		homeCollectionViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Explore", image: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "home"))
        libraryViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Library", image: #imageLiteral(resourceName: "list"), selectedImage: #imageLiteral(resourceName: "list"))
        forumsViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Forums", image: #imageLiteral(resourceName: "forums"), selectedImage: #imageLiteral(resourceName: "forums"))
        notificationsViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Notifications", image: #imageLiteral(resourceName: "notification"), selectedImage: #imageLiteral(resourceName: "notification"))
        feedTabsViewController.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Feed", image: #imageLiteral(resourceName: "profile"), selectedImage: #imageLiteral(resourceName: "profile"))

        // Setup navigation and title
        let n1 = KNavigationController.init(rootViewController: homeCollectionViewController)
        let n2 = KNavigationController.init(rootViewController: libraryViewController)
        let n3 = KNavigationController.init(rootViewController: forumsViewController)
        let n4 = KNavigationController.init(rootViewController: notificationsViewController)
        let n5 = KNavigationController.init(rootViewController: feedTabsViewController)
        
        homeCollectionViewController.title = "Explore"
        libraryViewController.title = "Library"
        forumsViewController.title = "Forums"
        notificationsViewController.title = "Notifications"
        feedTabsViewController.title = "Feed"
        
        // Initialize views
        viewControllers = [n1, n2, n3, n4, n5]
    }
}
