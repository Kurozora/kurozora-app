//
//  UIViewController+Kurozora.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import MBProgressHUD
import SPStorkController
//import JTSImageViewController

extension UIViewController {
	/**
		Return a HUD with the given text.

		- Parameter text: The text to be shown on the HUD.

		- Returns: a HUD with the given text.
	*/
	func showHUD(_ text: String) -> MBProgressHUD {
		let HUD = MBProgressHUD.showAdded(to: view, animated: true)
		HUD.label.text = text
		HUD.removeFromSuperViewOnHide = true
		return HUD
	}

	/**
		Modally present the given view controller.

		Presents the given controller in the default transition style on iOS 13+ and as SPStorkController on older iOS versions.

		- Parameter controller: The view controller to present
	*/
	func present(_ controller: UIViewController) {
		if #available(iOS 13.0, *) {
			self.present(controller, animated: true, completion: nil)
		} else {
			let transitioningDelegate = SPStorkTransitioningDelegate()
			transitioningDelegate.showIndicator = false
			controller.transitioningDelegate = transitioningDelegate
			controller.modalPresentationStyle = .custom
			self.present(controller, animated: true, completion: nil)
		}
    }
//    public func presentAnimeModal(anime: Anime) -> ZFModalTransitionAnimator {
//
//        let tabBarController = KAnimeKit.rootTabBarController()
//        tabBarController.initWithAnime(anime)
//
//        let animator = ZFModalTransitionAnimator(modalViewController: tabBarController)
//        animator?.dragable = true
//        animator.direction = .bottom
//
//        tabBarController.animator = animator
//        tabBarController.transitioningDelegate = animator;
//        tabBarController.modalPresentationStyle = UIModalPresentationStyle.custom;
//
//        presentViewController(tabBarController, animated: true, completion: nil)
//
//        return animator!
//    }
//    
//    func presentSearchViewController(searchScope: SearchScope) {
//        let (navigation, controller) = KAnimeKit.searchViewController()
//        controller.initWithSearchScope(searchScope)
//        present(navigation, animated: true, completion: nil)
//    }
//    
}
