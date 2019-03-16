//
//  ResetPasswordViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import SCLAlertView

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"
		resetButton.theme_setTitleColor("Global.textColor", forState: .normal)
		resetButton.theme_backgroundColor = "Global.tintColor"
        
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
    
    //MARK: - IBActions
    @IBAction func resetPressed(sender: AnyObject) {
        view.endEditing(true)
        
        let userEmail = userEmailTextField.trimmedText

		if let isEmail = userEmail?.isEmail, isEmail {
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
			SCLAlertView().showError("Errr...", subTitle: "Please type your email address 😣")
		}
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
