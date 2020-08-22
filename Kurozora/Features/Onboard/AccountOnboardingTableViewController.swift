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
			rightNavigationBarButton.title = accountOnboardingType.navigationBarButtonTitleValue
		}
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		// Stop activity indicator as it's not needed for now.
		_prefersActivityIndicatorHidden = true

		rightNavigationBarButton.isEnabled = false
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func rightNavigationBarButtonPressed(sender: AnyObject) {
		view.endEditing(true)
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
		let onboardingBaseTableViewCell: OnboardingBaseTableViewCell!

		switch accountOnboardingType.sections[indexPath.section] {
		case .header:
			onboardingBaseTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.onboardingHeaderTableViewCell.identifier, for: indexPath) as? OnboardingHeaderTableViewCell
			onboardingBaseTableViewCell.accountOnboardingType = self.accountOnboardingType
		case .textFields:
			onboardingBaseTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.onboardingTextFieldTableViewCell.identifier, for: indexPath) as? OnboardingBaseTableViewCell
			onboardingBaseTableViewCell?.accountOnboardingType = self.accountOnboardingType

			switch accountOnboardingType.textFieldTypes[indexPath.row] {
			case .username:
				(onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField.textType = .username
			case .email:
				(onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField.textType = .emailAddress
			case .password:
				(onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField.textType = .password
			}

			(onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField.tag = indexPath.row
			(onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField.delegate = self
			(onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
			textFieldArray.append((onboardingBaseTableViewCell as? OnboardingTextFieldTableViewCell)?.textField)
		case .options:
			onboardingBaseTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.onboardingOptionsTableViewCell.identifier, for: indexPath) as? OnboardingBaseTableViewCell
			onboardingBaseTableViewCell?.accountOnboardingType = self.accountOnboardingType
			(onboardingBaseTableViewCell as? OnboardingOptionsTableViewCell)?.onboardingFooterTableViewCellDelegate = self as? SignInTableViewController
		case .footer:
			onboardingBaseTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.onboardingFooterTableViewCell.identifier, for: indexPath) as? OnboardingBaseTableViewCell
			onboardingBaseTableViewCell?.accountOnboardingType = self.accountOnboardingType
		}

		onboardingBaseTableViewCell.configureCell()
		return onboardingBaseTableViewCell
	}
}

// MARK: - UITextFieldDelegate
extension AccountOnboardingTableViewController: UITextFieldDelegate {
	@objc func editingChanged(_ textField: UITextField) {
		if textField.text?.count == 1, textField.text?.first == " " {
			textField.text = ""
			return
		}

		var rightNavigationBarButtonIsEnabled = false
		textFieldArray.forEach({
			if let textField = $0?.text, !textField.isEmpty {
				rightNavigationBarButtonIsEnabled = true
				return
			}
			rightNavigationBarButtonIsEnabled = false
		})

		rightNavigationBarButton.isEnabled = rightNavigationBarButtonIsEnabled
	}

	func textFieldDidBeginEditing(_ textField: UITextField) {
		switch accountOnboardingType {
		case .signUp, .siwa:
			textField.returnKeyType = textField.tag == textFieldArray.count - 1 ? .join : .next
		case .signIn:
			textField.returnKeyType = textField.tag == textFieldArray.count - 1 ? .go : .next
		case .reset:
			textField.returnKeyType = textField.tag == textFieldArray.count - 1 ? .send : .next
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField.tag == textFieldArray.count - 1 {
			rightNavigationBarButtonPressed(sender: textField)
		} else {
			textFieldArray[textField.tag + 1]?.becomeFirstResponder()
		}

		return true
	}
}
