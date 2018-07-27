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
        
        let homeStoryboard = UIStoryboard(name: "home", bundle: nil)
        let home = homeStoryboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
        
        let libraryStoryboard = UIStoryboard(name: "library", bundle: nil)
        let library = libraryStoryboard.instantiateViewController(withIdentifier: "Library") as! LibraryViewController
        
        let forumsStoryboard = UIStoryboard(name: "forums", bundle: nil)
        let forums = forumsStoryboard.instantiateViewController(withIdentifier: "Forums") as! ForumsViewController
        
        let notificationStoryboard = UIStoryboard(name: "profile", bundle: nil)
        let notifications = notificationStoryboard.instantiateViewController(withIdentifier: "Notifications") as! NotificationsViewController
        
        let profileStoryboard = UIStoryboard(name: "profile", bundle: nil)
        let profile = profileStoryboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        
//        let profile = ProfileViewController()
        
        home.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Home", image: UIImage(named: "home"), selectedImage: UIImage(named: "home"))
        library.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Library", image: UIImage(named: "list"), selectedImage: UIImage(named: "list"))
        forums.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Forums", image: UIImage(named: "note"), selectedImage: UIImage(named: "note"))
        notifications.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Notifications", image: UIImage(named: "globe"), selectedImage: UIImage(named: "globe"))
        profile.tabBarItem = ESTabBarItem.init(BounceAnimation(), title: "Profile", image: UIImage(named: "user_male"), selectedImage: UIImage(named: "user_male"))
        
        let n1 = KurozoraNavigationController.init(rootViewController: home)
        let n2 = KurozoraNavigationController.init(rootViewController: library)
        let n3 = KurozoraNavigationController.init(rootViewController: forums)
        let n4 = KurozoraNavigationController.init(rootViewController: notifications)
        let n5 = KurozoraNavigationController.init(rootViewController: profile)

        home.title = "Home"
        library.title = "Library"
        forums.title = "Forums"
        notifications.title = "Notifications"
        profile.title = "Profile"

        viewControllers = [n1, n2, n3, n4, n5]
//        viewControllers = [home, library, forums, notifications, profile]
    }
}
