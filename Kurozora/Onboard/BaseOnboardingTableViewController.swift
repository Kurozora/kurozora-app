//
//  BaseOnboardingTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/09/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class BaseOnboardingTableViewController: UITableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var subTextLabel: UILabel! {
		didSet {
			subTextLabel?.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var rightNavigationBarButton: UIBarButtonItem!

	// MARK: - Properties
	var textFieldArray: [UITextField?] = []
	var onboardingType: OnboardingType = .register

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
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
extension BaseOnboardingTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return onboardingType.cellType.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = onboardingType.cellType[indexPath.row] == .footer ? "OnboardingFooterTableViewCell" : "OnboardingTextFieldCell"
		let onboardingBaseTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OnboardingBaseTableViewCell
		onboardingBaseTableViewCell.onboardingType = onboardingType

		switch onboardingType.cellType[indexPath.row] {
		case .username:
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.textType = .username
		case .email:
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.textType = .emailAddress
		case .password:
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.textType = .password
		default: break
		}

		if onboardingBaseTableViewCell as? OnboardingTextFieldCell != nil {
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.tag = indexPath.row
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.delegate = self
			(onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
			textFieldArray.append((onboardingBaseTableViewCell as? OnboardingTextFieldCell)?.textField)
		}

		onboardingBaseTableViewCell.configureCell()
		return onboardingBaseTableViewCell
	}
}

// MARK: - UITextFieldDelegate
extension BaseOnboardingTableViewController: UITextFieldDelegate {
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
		switch onboardingType {
		case .register:
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
