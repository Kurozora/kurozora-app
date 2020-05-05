//
//  ResetPasswordViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SCLAlertView

class ResetPasswordTableViewController: AccountOnboardingTableViewController {
	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		// Configure properties
		self.accountOnboardingType = .reset
	}

	// MARK: - IBActions
	override func rightNavigationBarButtonPressed(sender: AnyObject) {
		super.rightNavigationBarButtonPressed(sender: sender)

		guard let emailAddress = textFieldArray.first??.trimmedText, emailAddress.isValidEmail else {
			SCLAlertView().showError("Errr...", subTitle: "Please type a valid Kurozora ID 😣")
			return
		}

		KService.resetPassword(withEmailAddress: emailAddress) { result in
			switch result {
			case .success:
				let appearance = SCLAlertView.SCLAppearance(
					showCloseButton: false
				)
				let alertView = SCLAlertView(appearance: appearance)
				alertView.addButton("Done", action: {
					self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
				})
				alertView.showSuccess("Success!", subTitle: "If an account exists with this Kurozora ID, you should receive an email with your reset link shortly.")
			case .failure: break
			}
		}
	}
}
