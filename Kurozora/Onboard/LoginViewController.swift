//
//  LoginViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

class LoginViewController: UIViewController {
	var window: UIWindow?

	@IBOutlet weak var usernameTextField: UITextField! {
		didSet {
			usernameTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			usernameTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			usernameTextField.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}
	@IBOutlet weak var passwordTextField: UITextField! {
		didSet {
			passwordTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			passwordTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			passwordTextField.theme_placeholderAttributes = ThemeStringAttributesPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key: Any]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}
	@IBOutlet weak var forgotPasswordButton: UIButton! {
		didSet {
			forgotPasswordButton.theme_setTitleColor(KThemePicker.textColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var loginButton: UIButton! {
		didSet {
			loginButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			loginButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		loginButton.isEnabled = false
		loginButton.alpha = 0.5
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		usernameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
		passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}

	// MARK: - Functions
	/**
		Instantiates and returns a view controller from the relevant storyboard.

		- Returns: a view controller from the relevant storyboard.
	*/
	static func instantiateFromStoryboard() -> UIViewController? {
		let storyboard = UIStoryboard(name: "login", bundle: nil)
		return storyboard.instantiateViewController(withIdentifier: "LoginViewController")
	}

	// MARK: - IBActions
	@IBAction func loginPressed(sender: AnyObject) {
		view.endEditing(true)
		let username = usernameTextField.trimmedText
		let password = passwordTextField.text
		let device = UIDevice.modelName + " on iOS " + UIDevice.current.systemVersion

		Service.shared.login(username, password, device, withSuccess: { (success) in
			if success {
				DispatchQueue.main.async {
					WorkflowController.shared.registerForPusher()

					let customTabBar = KTabBarController()
					customTabBar.modalPresentationStyle = .fullScreen
					self.present(customTabBar, animated: true, completion: nil)
				}
			} else {
				self.passwordTextField.text = ""
				self.loginButton.isEnabled = false
				self.loginButton.alpha = 0.5
			}
		})
	}
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
	@objc func editingChanged(_ textField: UITextField) {
		if textField.text?.count == 1 {
			if textField.text?.first == " " {
				textField.text = ""
				return
			}
		}
		guard let username = usernameTextField.text, !username.isEmpty,
			let password = passwordTextField.text, !password.isEmpty
			else {
				loginButton.isEnabled = false
				loginButton.alpha = 0.5
				return
		}
		loginButton.isEnabled = true
		loginButton.alpha = 1.0
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField {
		case usernameTextField: passwordTextField.becomeFirstResponder()
		case passwordTextField: loginPressed(sender: passwordTextField)
		default: usernameTextField.resignFirstResponder()
		}

		return true
	}
}
