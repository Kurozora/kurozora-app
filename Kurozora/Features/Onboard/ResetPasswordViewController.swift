//
//  ResetPasswordViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView

class ResetPasswordTableViewController: BaseOnboardingTableViewController {
	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		onboardingType = .reset
	}

	// MARK: - IBActions
	override func rightNavigationBarButtonPressed(sender: AnyObject) {
		super.rightNavigationBarButtonPressed(sender: sender)

		guard let userEmail = textFieldArray.first??.trimmedText, userEmail.isValidEmail else {
			SCLAlertView().showError("Errr...", subTitle: "Please type a valid Kurozora ID 😣")
			return
		}

		KService.shared.resetPassword(userEmail, withSuccess: { _ in
			let appearance = SCLAlertView.SCLAppearance(
				showCloseButton: false
			)
			let alertView = SCLAlertView(appearance: appearance)
			alertView.addButton("Done", action: {
				self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
			})
			alertView.showSuccess("Success!", subTitle: "If an account exists with this Kurozora ID, you should receive an email with your reset link shortly.")
		})
	}
}
