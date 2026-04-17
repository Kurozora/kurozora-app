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

		guard let emailAddress = textFieldArray.first??.text?.trimmingCharacters(in: .whitespacesAndNewlines), emailAddress.isValidEmail else {
			self.presentAlertController(title: L10n.Onboarding.forgotPasswordErrorAlertHeadline, message: L10n.Onboarding.forgotPasswordErrorAlertSubheadline)

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
			_ = try await KService.resetPassword(withEmailAddress: email)

			self.presentAlertController(title: L10n.Onboarding.forgotPasswordAlertHeadline, message: L10n.Onboarding.forgotPasswordAlertSubheadline, defaultActionButtonTitle: L10n.done) { _ in
				self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
			}
		} catch {
			self.presentAlertController(title: L10n.Onboarding.forgotPasswordErrorAlertHeadline, message: error.localizedDescription)
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
