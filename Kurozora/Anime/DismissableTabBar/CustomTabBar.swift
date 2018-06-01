//
//  CustomTabBar.swift
//  Kurozora
//
//  Created by Khoren Katklian on 10/05/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KDatabaseKit
import KCommonKit
import UIKit

protocol CustomAnimatorProtocol {
    func scrollView() -> UIScrollView
}

protocol RequiresAnimeProtocol {
    func initWithAnime(anime: Anime)
}

protocol StatusBarVisibilityProtocol {
    func shouldHideStatusBar() -> Bool
    func updateCanHideStatusBar(canHide: Bool)
}

public class CustomTabBarController: UITabBarController {
//
//    var anime: Anime!
//    public var animator: ZFModalTransitionAnimator!
//
//    public func initWithAnime(anime: Anime) {
//        self.anime = anime
//    }
//
//    func setCurrentViewController(controller: CustomAnimatorProtocol) {
//        animator.gesture.isEnabled = true
//        animator.setContentScrollView(controller.scrollView())
//    }
//    func disableDragDismiss() {
//        animator.gesture.isEnabled = false
//    }
//
//    override public func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Forum view controller
//        let (forumNavController, _) = KAnimeKit.animeForumViewController()
//        self.viewControllers?.append(forumNavController)
//
//        // Update icons frame
//        for controller in viewControllers! {
//            controller.tabBarItem.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
//        }
//
//        delegate = self
//
//        // Set first view controller anime, the rest is set when tab controller delegate
//        let navController = self.viewControllers?.first as! UINavigationController
//        let controller = navController.viewControllers.first as! RequiresAnimeProtocol
//        controller.initWithAnime(anime: anime)
//    }
//
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
//    }
//
//    public override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//
//        if isBeingDismissed {
//            selectedViewControllerCantHideStatusBar()
//
//            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
//            UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
//        }
//    }
//
//    func selectedViewControllerCantHideStatusBar() {
//        let currentNavController = selectedViewController as! UINavigationController
//        if let controller = currentNavController.viewControllers.first as? StatusBarVisibilityProtocol {
//            controller.updateCanHideStatusBar(canHide: false)
//        }
//
//    }
//}
//
//class CustomTabBar: UITabBar {
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        var sizeThatFits = super.sizeThatFits(size)
//        sizeThatFits.height = 44
//        return sizeThatFits
//    }
//}
//
//extension CustomTabBarController: UITabBarControllerDelegate {
//    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//
//        selectedViewControllerCantHideStatusBar()
//
//        let navController = viewController as! UINavigationController
//        if let controller = navController.viewControllers.first as? StatusBarVisibilityProtocol {
//
//            let hide = controller.shouldHideStatusBar()
//            UIApplication.shared.setStatusBarHidden(hide, with: UIStatusBarAnimation.none)
//        }
//
//        return true
//    }
//
//    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//
//        let navController = viewController as! UINavigationController
//        if let controller = navController.viewControllers.first as? RequiresAnimeProtocol {
//            controller.initWithAnime(anime: anime)
//        }
//
//    }
}
