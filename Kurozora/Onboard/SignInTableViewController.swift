//
//  SignInTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class SignInTableViewController: BaseOnboardingTableViewController {
	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		onboardingType = .signIn
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "onboarding", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "SignInTableViewController")
	}

	// MARK: - IBActions
	override func rightNavigationBarButtonPressed(sender: AnyObject) {
		super.rightNavigationBarButtonPressed(sender: sender)

		let username = textFieldArray[0]?.trimmedText
		let password = textFieldArray[1]?.text
		let device = UIDevice.modelName + " on iOS " + UIDevice.current.systemVersion

		Service.shared.signIn(username, password, device, withSuccess: { (success) in
			if success {
				DispatchQueue.main.async {
					WorkflowController.shared.registerForPusher()
					NotificationCenter.default.post(name: .KUserIsSignedInDidChange, object: nil)
					self.dismiss(animated: true, completion: nil)
				}
			}
			self.rightNavigationBarButton.isEnabled = false
		})
	}
}
