//
//  LoginViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import KCommonKit
import Alamofire
import SwiftyJSON
import SCLAlertView
import PusherSwift

class LoginViewController: UIViewController {
    var window: UIWindow?

	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: TKTransitionSubmitButton!
	@IBOutlet weak var forgotPasswordButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		view.theme_backgroundColor = "Global.backgroundColor"
		forgotPasswordButton.theme_setTitleColor("Global.textColor", forState: .normal)
		loginButton.theme_setTitleColor("Global.textColor", forState: .normal)
		loginButton.theme_backgroundColor = "Global.tintColor"
 
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
    
    // MARK: - IBActions
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
		loginButton.startLoadingAnimation()
		view.endEditing(true)
		let username = usernameTextField.trimmedText
        let password = passwordTextField.text
        let device = UIDevice.modelName + " on iOS " + UIDevice.current.systemVersion

		Service.shared.login(username, password, device, withSuccess: { (success) in
			if success {
				DispatchQueue.main.async {
					WorkflowController.pusherInit()

					self.loginButton.startFinishAnimation(1) {
						let customTabBar = KurozoraTabBarController()
						customTabBar.transitioningDelegate = self
						self.present(customTabBar, animated: true, completion: nil)
					}
				}
			} else {
				self.loginButton.returnToOriginalState()
				self.passwordTextField.text = ""
				self.loginButton.isEnabled = false
				self.loginButton.alpha = 0.5
			}
		})
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension LoginViewController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return TKFadeInAnimator(transitionDuration: 0.5, startingAlpha: 0.8)
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return nil
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
        guard
            let username = usernameTextField.text, !username.isEmpty,
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
            case usernameTextField:
                passwordTextField.becomeFirstResponder()
            case passwordTextField:
                loginPressed(sender: passwordTextField)
            default:
                usernameTextField.resignFirstResponder()
        }
        
        return true
    }
}
