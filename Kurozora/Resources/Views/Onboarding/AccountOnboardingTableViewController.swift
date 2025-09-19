//
//  AccountOnboardingTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class AccountOnboardingTableViewController: KTableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var rightNavigationBarButton: UIBarButtonItem!

	// MARK: - Properties
	var textFieldArray: [UITextField?] = []
	var accountOnboardingType: AccountOnboarding = .signIn {
		didSet {
			self.rightNavigationBarButton.title = self.accountOnboardingType.navigationBarButtonTitleValue
		}
	}

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}

	override var prefersRefreshControlDisabled: Bool {
		return self._prefersRefreshControlDisabled
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}

	override var prefersActivityIndicatorHidden: Bool {
		return self._prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator and disable refresh control
		self._prefersActivityIndicatorHidden = true
		self._prefersRefreshControlDisabled = true

		self.rightNavigationBarButton.isEnabled = false
	}

	// MARK: - Functions
	/// Disables or enables the user interaction on the current view. Also shows a loading indicator.
	///
	/// - Parameter disable: Indicates whether to disable the interaction.
	func disableUserInteraction(_ disable: Bool) {
		if disable {
			self.view.endEditing(true)
		}
		self.navigationItem.hidesBackButton = disable
		self.navigationItem.rightBarButtonItem?.isEnabled = !disable
		self._prefersActivityIndicatorHidden = !disable
		self.view.isUserInteractionEnabled = !disable
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func rightNavigationBarButtonPressed(sender: AnyObject) {
		self.disableUserInteraction(true)
	}
}

// MARK: - UITableViewDataSource
extension AccountOnboardingTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.accountOnboardingType.sections.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.accountOnboardingType.sections[section] {
		case .textFields:
			return self.accountOnboardingType.textFieldTypes.count
		default:
			return 1
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let onboardingBaseTableViewCell: OnboardingBaseTableViewCell?

		switch self.accountOnboardingType.sections[indexPath.section] {
		case .header:
			onboardingBaseTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.onboardingHeaderTableViewCell.identifier, for: indexPath) as? OnboardingHeaderTableViewCell
			onboardingBaseTableViewCell?.accountOnboardingType = self.accountOnboardingType
		case .textFields:
			onboardingBaseTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.onboardingTextFieldTableViewCell.identifier, for: indexPath) as? OnboardingBaseTableViewCell
			onboardingBaseTableViewCell?.accountOnboardingType = self.accountOnboardingType

			(onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField.textType = self.accountOnboardingType.textFieldTypes[indexPath.row].textType
			(onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField.textContentType = self.accountOnboardingType.textFieldTypes[indexPath.row].textContentType
			(onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField.tag = indexPath.row
			(onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField.delegate = self
			(onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
			self.textFieldArray.append((onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField)
		case .options:
			onboardingBaseTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.onboardingOptionsTableViewCell.identifier, for: indexPath) as? OnboardingBaseTableViewCell
			onboardingBaseTableViewCell?.accountOnboardingType = self.accountOnboardingType
			(onboardingBaseTableViewCell as? OnboardingOptionsTableViewCell)?.delegate = self as? SignInTableViewController
		case .footer:
			if let onboardingFooterTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.onboardingFooterTableViewCell.identifier, for: indexPath) as? OnboardingFooterTableViewCell {
				onboardingFooterTableViewCell.delegate = self
				onboardingBaseTableViewCell = onboardingFooterTableViewCell
			} else {
				onboardingBaseTableViewCell = nil
			}

			onboardingBaseTableViewCell?.accountOnboardingType = self.accountOnboardingType
		}

		onboardingBaseTableViewCell?.configureCell()
		return onboardingBaseTableViewCell ?? UITableViewCell()
	}
}

// MARK: - OnboardingFooterTableViewCellDelegate
extension AccountOnboardingTableViewController: OnboardingFooterTableViewCellDelegate {}

// MARK: - UITextFieldDelegate
extension AccountOnboardingTableViewController: UITextFieldDelegate {
	@objc func editingChanged(_ textField: UITextField) {
		if textField.text?.count == 1, textField.text?.first == " " {
			textField.text = ""
			return
		}

		var rightNavigationBarButtonIsEnabled = false
		for item in self.textFieldArray {
			if let textField = item?.text, !textField.isEmpty {
				rightNavigationBarButtonIsEnabled = true
				continue
			}
			rightNavigationBarButtonIsEnabled = false
		}

		self.rightNavigationBarButton.isEnabled = rightNavigationBarButtonIsEnabled
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		switch self.accountOnboardingType {
		case .signUp, .siwa:
			textField.returnKeyType = textField.tag == self.textFieldArray.count - 1 ? .join : .next
		case .signIn:
			textField.returnKeyType = textField.tag == self.textFieldArray.count - 1 ? .go : .next
		case .reset:
			textField.returnKeyType = textField.tag == self.textFieldArray.count - 1 ? .send : .next
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField.tag == self.textFieldArray.count - 1 {
			self.rightNavigationBarButtonPressed(sender: textField)
		} else {
			self.textFieldArray[textField.tag + 1]?.becomeFirstResponder()
		}

		return true
	}
}
