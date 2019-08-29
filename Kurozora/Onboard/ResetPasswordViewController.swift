//
//  ResetPasswordViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SCLAlertView
import SwiftTheme

class ResetPasswordViewController: UIViewController {
	@IBOutlet weak var userEmailTextField: UITextField! {
		didSet {
			userEmailTextField.theme_textColor = KThemePicker.textFieldTextColor.rawValue
			userEmailTextField.theme_backgroundColor = KThemePicker.textFieldBackgroundColor.rawValue
			userEmailTextField.theme_placeholderAttributes = ThemeDictionaryPicker(keyPath: KThemePicker.textFieldPlaceholderTextColor.stringValue) { value -> [NSAttributedString.Key : AnyObject]? in
				guard let rgba = value as? String else { return nil }
				let color = UIColor(rgba: rgba)
				let titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]

				return titleTextAttributes
			}
		}
	}
	@IBOutlet weak var resetButton: UIButton! {
		didSet {
			resetButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			resetButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue
        
        resetButton.isEnabled = false
		resetButton.alpha = 0.5
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		userEmailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
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
		return storyboard.instantiateViewController(withIdentifier: "ResetPasswordViewController")
	}
    
    //MARK: - IBActions
    @IBAction func resetPressed(sender: AnyObject) {
        view.endEditing(true)
        
        let userEmail = userEmailTextField.trimmedText

		if let isEmail = userEmail?.isValidEmail, isEmail {
			Service.shared.resetPassword(userEmail, withSuccess: { (reset) in
				let appearance = SCLAlertView.SCLAppearance(
					showCloseButton: false
				)
				let alertView = SCLAlertView(appearance: appearance)
				alertView.addButton("Done", action: {
					self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
				})
				alertView.showSuccess("Success!", subTitle: "If an account exists with this email address, you should receive an email with your reset link shortly.")
			})
		} else {
			SCLAlertView().showError("Errr...", subTitle: "Please type a valid email address 😣")
		}
    }

	@IBAction func dismissPressed(sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UITextFieldDelegate
extension ResetPasswordViewController: UITextFieldDelegate {
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard let username = userEmailTextField.text, !username.isEmpty else {
                resetButton.isEnabled = false
				resetButton.alpha = 0.5
                return
        }
        resetButton.isEnabled = true
		resetButton.alpha = 1.0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userEmailTextField:
            resetPressed(sender: userEmailTextField)
        default:
            userEmailTextField.resignFirstResponder()
        }
        
        return true
    }
}
