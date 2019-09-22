//
//  LoginTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController {
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
	@IBOutlet weak var loginButton: UIBarButtonItem!

	// MARK: - Properties
	var textFieldArray: [UITextField?] = []

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
		loginButton.isEnabled = false
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "login", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "LoginTableViewController")
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func loginButtonPressed(sender: AnyObject) {
		view.endEditing(true)
		let username = textFieldArray[0]?.text?.trimmed
		let password = textFieldArray[1]?.text
		let device = UIDevice.modelName + " on iOS " + UIDevice.current.systemVersion

		Service.shared.login(username, password, device, withSuccess: { (success) in
			if success {
				DispatchQueue.main.async {
					WorkflowController.shared.registerForPusher()
					NotificationCenter.default.post(name: .KUserIsLoggedInDidChange, object: nil)
					self.dismiss(animated: true, completion: nil)
				}
			}
			self.loginButton.isEnabled = false
		})
	}
}

// MARK: - UITableViewDataSource
extension LoginTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return LoginCellType.all.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let identifier = LoginCellType(rawValue: indexPath.row) == .footer ? "LoginFooterTableViewCell" : "LoginTextFieldCell"
		let loginBaseTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! LoginBaseTableViewCell

		switch indexPath.row {
		case 0:
			(loginBaseTableViewCell as? LoginTextFieldCell)?.textField.textType = .emailAddress
		case 1:
			(loginBaseTableViewCell as? LoginTextFieldCell)?.textField.textType = .password
		default: break
		}

		if loginBaseTableViewCell as? LoginTextFieldCell != nil {
			(loginBaseTableViewCell as? LoginTextFieldCell)?.textField.tag = indexPath.row
			(loginBaseTableViewCell as? LoginTextFieldCell)?.textField.delegate = self
			(loginBaseTableViewCell as? LoginTextFieldCell)?.textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
			textFieldArray.append((loginBaseTableViewCell as? LoginTextFieldCell)?.textField)
		}

		loginBaseTableViewCell.configureCell()
		return loginBaseTableViewCell
	}
}

// MARK: - UITextFieldDelegate
extension LoginTableViewController: UITextFieldDelegate {
	@objc func editingChanged(_ textField: UITextField) {
		if textField.text?.count == 1, textField.text?.first == " " {
			textField.text = ""
			return
		}

		var loginButtonIsEnabled = false
		textFieldArray.forEach({
			if let textField = $0?.text, !textField.isEmpty {
				loginButtonIsEnabled = true
				return
			}
			loginButtonIsEnabled = false
		})

		loginButton.isEnabled = loginButtonIsEnabled
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField.tag == textFieldArray.count - 1 {
			loginButtonPressed(sender: textField)
		} else {
			textFieldArray[textField.tag + 1]?.becomeFirstResponder()
		}

		return true
	}
}
