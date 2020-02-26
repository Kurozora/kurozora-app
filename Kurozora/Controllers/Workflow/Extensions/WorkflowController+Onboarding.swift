//
//  WorkflowController+Onboarding.swift
//  Kurozora
//
//  Created by Khoren Katklian on 25/02/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
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

	/**
		Sign out the current user by emptying KDefaults. Also show a message with the reason of the sign out if the user's session was terminated from a different device.

		- Parameter signOutReason: The reason as to why the user has been signed out.
		- Parameter isKiller: A boolean indicating whether the current user is the one who initiated the sign out.
	*/
	func signOut(with signOutReason: String? = nil, whereUser isKiller: Bool = false) {
		try? Kurozora.shared.KDefaults.removeAll()
		NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
		if signOutReason != nil {
			SCLAlertView().showWarning("Signed out", subTitle: signOutReason)
		}
	}
}
