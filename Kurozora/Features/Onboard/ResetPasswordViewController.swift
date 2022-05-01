//
//  ResetPasswordViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

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
			self.presentAlertController(title: "Errr...", message: "Please type a valid Kurozora ID 😣")
			return
		}

		KService.resetPassword(withEmailAddress: emailAddress) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success:
				self.presentAlertController(title: "Success!", message: "If an account exists with this Kurozora ID, you should receive an email with your reset link shortly.", defaultActionButtonTitle: Trans.done) { _ in
					self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
				}
			case .failure: break
			}
		}
	}
}

// MARK: - KTableViewControllerDataSource
extension ResetPasswordTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [
			OnboardingHeaderTableViewCell.self,
			OnboardingTextFieldTableViewCell.self
		]
	}
}
