//
//  KAnimeKit.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KDatabaseKit

public class KAnimeKit {
    
    public class func defaultStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Anime", bundle: nil)
    }
    
    public class func threadStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Thread", bundle: nil)
    }
    
    public class func rootTabBarController() -> CustomTabBarController {
        let tabBarController = defaultStoryboard().instantiateInitialViewController() as! CustomTabBarController
        return tabBarController
    }
    
    public class func profileViewController() -> ProfileViewController {
        let controller = UIStoryboard(name: "Profile", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        return controller
    }
    
    public class func animeForumViewController() -> (UINavigationController,ForumViewController) {
        let controller = UIStoryboard(name: "Forum", bundle: nil).instantiateInitialViewController() as! UINavigationController
        return (controller,controller.viewControllers.last! as! ForumViewController)
    }
    
    public class func customThreadViewController() -> CustomThreadViewController {
        let controller = KAnimeKit.threadStoryboard().instantiateViewControllerWithIdentifier("CustomThread") as! CustomThreadViewController
        return controller
    }
    
    public class func notificationThreadViewController() -> (UINavigationController, NotificationThreadViewController) {
        let controller = KAnimeKit.threadStoryboard().instantiateViewController(withIdentifier: "NotificationThreadNav") as! UINavigationController
        return (controller, controller.viewControllers.last! as! NotificationThreadViewController)
    }
    
    class func searchViewController() -> (UINavigationController, SearchViewController) {
        let navigation = UIStoryboard(name: "Browse", bundle: nil).instantiateViewController(withIdentifier: "NavSearch") as! UINavigationController
        navigation.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navigation.modalPresentationStyle = .overCurrentContext
        
        let controller = navigation.viewControllers.last as! SearchViewController
        return (navigation, controller)
    }
}
