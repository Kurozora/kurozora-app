//
//  RootTabBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

//import ANParseKit
import KCommonKit

public class RootTabBar: UITabBarController {
//    public static let ShowedMyAnimeListLoginDefault = "Defaults.ShowedMyAnimeListLogin"
//
//    var selectedDefaultTabOnce = false
//    var chechedForNotificationsOnce = false
//
//    override public func viewDidLoad() {
//        super.viewDidLoad()
//        // Load library
//        LibraryController.sharedInstance.fetchAnimeList(false)
//        delegate = self as UITabBarControllerDelegate
//    }
//
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        if !selectedDefaultTabOnce {
//            selectedDefaultTabOnce = true
//            if let value = UserDefaults.standard.value(forKey: DefaultLoadingScreen) as? String {
//                switch value {
//                case "Season":
//                    break
//                case "Library":
//                    selectedIndex = 1
//                case "Profile":
//                    selectedIndex = 2
//                case "Forum":
//                    selectedIndex = 4
//                default:
//                    break
//                }
//            }
//        }
//    }
//
//    public override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if !chechedForNotificationsOnce {
//            chechedForNotificationsOnce = true
//            checkIfThereAreNotifications()
//        }
//    }
//
//    func newNotifications(count: Int) {
//        var result: String? = nil
//        if count > 0 {
//            result = "\(count)"
//        }
//
//        tabBar.items?[3].badgeValue = result
//    }
//
//    func checkIfThereAreNotifications() {
//        if let navController = viewControllers![3] as? UINavigationController,
//            let notificationVC = navController.viewControllers.first as? NotificationsViewController {
//            notificationVC.fetchNotifications()
//        }
//    }
}

// MARK: - NotificationsViewControllerDelegate
//extension RootTabBar: NotificationsViewControllerDelegate {
//    func notificationsViewControllerHasUnreadNotifications(count: Int) {
//        newNotifications(count: count)
//    }
//    func notificationsViewControllerClearedAllNotifications() {
//        newNotifications(count: 0)
//    }
//}

//extension RootTabBar: UITabBarControllerDelegate {
//    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//
//
//        if let navController = viewController as? UINavigationController {
//
//            let profileController = navController.viewControllers.first as? ProfileViewController
//            let libraryController = navController.viewControllers.first as? AnimeLibraryViewController
//
//            if profileController == nil && libraryController == nil {
//                return true
//            }
//
//            if User.currentUserIsGuest() {
//                let welcome = UIStoryboard(name: "Welcome", bundle: nil).instantiateInitialViewController() as! WelcomeViewController
//                welcome.isInWindowRoot = false
//                present(welcome, animated: true, completion: nil)
//                return false
//            }
//
//            if let _ = libraryController , !UserDefaults.standard.bool(forKey: RootTabBar.ShowedMyAnimeListLoginDefault) {
//                UserDefaults.standard.set(true, forKey: RootTabBar.ShowedMyAnimeListLoginDefault)
//                UserDefaults.standard.synchronize()
//
//                let loginController = ANParseKit.loginViewController()
//                loginController.delegate = self
//                presentViewController(loginController, animated: true, completion: nil)
//                return false
//
//            }
//        }
//
//        return true
//    }
//}

//extension RootTabBar: LoginViewControllerDelegate {
//    public func loginViewControllerPressedDoesntHaveAnAccount() {
//        selectedIndex = 1
//    }
//}
