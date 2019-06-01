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
        let home = homeStoryboard.instantiateViewController(withIdentifier: "Home") as! HomeCollectionViewController
        
        let libraryStoryboard = UIStoryboard(name: "library", bundle: nil)
        let library = libraryStoryboard.instantiateViewController(withIdentifier: "Library") as! LibraryViewController
        
        let forumsStoryboard = UIStoryboard(name: "forums", bundle: nil)
        let forums = forumsStoryboard.instantiateViewController(withIdentifier: "Forums") as! ForumsViewController
        
        let notificationStoryboard = UIStoryboard(name: "notification", bundle: nil)
        let notifications = notificationStoryboard.instantiateViewController(withIdentifier: "Notification") as! NotificationsViewController
        
        let profileStoryboard = UIStoryboard(name: "profile", bundle: nil)
        let profile = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        
        // Setup animation, title and image
		home.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Explore", image: #imageLiteral(resourceName: "home"), selectedImage: #imageLiteral(resourceName: "home"))
        library.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Library", image: #imageLiteral(resourceName: "list"), selectedImage: #imageLiteral(resourceName: "list"))
        forums.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Forums", image: #imageLiteral(resourceName: "note"), selectedImage: #imageLiteral(resourceName: "note"))
        notifications.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Notifications", image: #imageLiteral(resourceName: "notification"), selectedImage: #imageLiteral(resourceName: "notification"))
        profile.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Profile", image: #imageLiteral(resourceName: "user_male"), selectedImage: #imageLiteral(resourceName: "user_male"))

        // Setup navigation and title
        let n1 = KNavigationController.init(rootViewController: home)
        let n2 = KNavigationController.init(rootViewController: library)
        let n3 = KNavigationController.init(rootViewController: forums)
        let n4 = KNavigationController.init(rootViewController: notifications)
        let n5 = KNavigationController.init(rootViewController: profile)
        
        home.title = "Explore"
        library.title = "Library"
        forums.title = "Forums"
        notifications.title = "Notifications"
        profile.title = "Profile"
        
        // Initialize views
        viewControllers = [n1, n2, n3, n4, n5]
    }
}
