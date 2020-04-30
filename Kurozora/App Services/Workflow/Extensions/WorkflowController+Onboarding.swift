//
//  WorkflowController+Onboarding.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit
import SCLAlertView

// MARK: - Onboarding
extension WorkflowController {
	/**
		Checks whether the current user is signed in. If the user is signed in then a success block is run. Otherwise the user is asked to sign in.

		- Parameter completion: Optional completion handler (default is `nil`).
	*/
	func isSignedIn(_ completion: (() -> Void)? = nil) {
		if User.isSignedIn {
			completion?()
		} else {
			if let signInTableViewController = R.storyboard.onboarding.signInTableViewController() {
				let kNavigationController = KNavigationController(rootViewController: signInTableViewController)
				UIApplication.topViewController?.present(kNavigationController)
			}
		}
	}
}
