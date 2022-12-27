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
			self.presentAlertController(title: Trans.forgotPasswordErrorAlertHeadline, message: Trans.forgotPasswordErrorAlertSubheadline)

			self.disableUserInteraction(false)
			return
		}

		Task { [weak self] in
			guard let self = self else { return }
			await self.resetPassword(for: emailAddress)
		}
	}

	func resetPassword(for email: String) async {
		do {
			_ = try await KService.resetPassword(withEmailAddress: email).value

			self.presentAlertController(title: Trans.forgotPasswordAlertHeadline, message: Trans.forgotPasswordAlertSubheadline, defaultActionButtonTitle: Trans.done) { _ in
				self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
			}
		} catch {
			self.presentAlertController(title: Trans.forgotPasswordErrorAlertHeadline, message: error.localizedDescription)
			print(error.localizedDescription)
		}

		self.disableUserInteraction(false)
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
