//
//  KurozoraTabBarController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/07/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class KurozoraTabBarController: ESTabBarController {
    override func viewDidLoad() {
		super.viewDidLoad()
		self.tabBar.itemPositioning = .centered
		self.tabBar.theme_tintColor = "Global.barTitleTextColor"
		self.tabBar.theme_barTintColor = "Global.barTintColor"

        // Instantiate views
        let homeStoryboard = UIStoryboard(name: "home", bundle: nil)
        let home = homeStoryboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        
        let libraryStoryboard = UIStoryboard(name: "library", bundle: nil)
        let library = libraryStoryboard.instantiateViewController(withIdentifier: "Library") as! LibraryViewController
        
        let forumsStoryboard = UIStoryboard(name: "forums", bundle: nil)
        let forums = forumsStoryboard.instantiateViewController(withIdentifier: "Forums") as! ForumsViewController
        
        let notificationStoryboard = UIStoryboard(name: "notification", bundle: nil)
        let notifications = notificationStoryboard.instantiateViewController(withIdentifier: "Notification") as! NotificationsViewController
        
        let profileStoryboard = UIStoryboard(name: "profile", bundle: nil)
        let profile = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        
        // Setup animation, title and image
		home.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Explore", image: #imageLiteral(resourceName: "home.png"), selectedImage: #imageLiteral(resourceName: "home.png"))
        library.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Library", image: #imageLiteral(resourceName: "list.png"), selectedImage: #imageLiteral(resourceName: "list.png"))
        forums.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Forums", image: #imageLiteral(resourceName: "note.png"), selectedImage: #imageLiteral(resourceName: "note.png"))
        notifications.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Notifications", image: #imageLiteral(resourceName: "notification_icon.png"), selectedImage: #imageLiteral(resourceName: "notification_icon.png"))
        profile.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Profile", image: #imageLiteral(resourceName: "user_male.png"), selectedImage: #imageLiteral(resourceName: "user_male.png"))
        
        // Setup navigation and title
        let n1 = KurozoraNavigationController.init(rootViewController: home)
        let n2 = KurozoraNavigationController.init(rootViewController: library)
        let n3 = KurozoraNavigationController.init(rootViewController: forums)
        let n4 = KurozoraNavigationController.init(rootViewController: notifications)
        let n5 = KurozoraNavigationController.init(rootViewController: profile)
        
        home.title = "Explore"
        library.title = "Library"
        forums.title = "Forums"
        notifications.title = "Notifications"
        profile.title = "Profile"
        
        // Initialize views
        viewControllers = [n1, n2, n3, n4, n5]
    }
}
