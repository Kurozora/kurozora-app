//
//  LoginViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import KCommonKit
import Alamofire
import SwiftyJSON
import SCLAlertView

class LoginViewController: UIViewController {
    var window: UIWindow?

    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        loginButton.isEnabled = false
        usernameTextField.becomeFirstResponder()
        usernameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(sender: AnyObject) {

        usernameTextField.trimSpaces()

        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let device = UIDevice.modelName + " on iOS " + UIDevice.current.systemVersion
        
        passwordTextField.text = ""
        loginButton.isEnabled = false
        
        Service.shared.login(username, password, device, withSuccess: { (success) in
//            self.window = UIWindow()
//            self.window?.makeKeyAndVisible()

            let customTabBar = KurozoraTabBarController()
//            self.window?.rootViewController = customTabBar
            customTabBar.modalTransitionStyle = .flipHorizontal
            self.present(customTabBar, animated: true, completion: nil)
        }) { (errorMsg) in
            SCLAlertView().showError("Error logging in", subTitle: errorMsg)
        }
    }

}

extension LoginViewController: UINavigationBarDelegate, UIBarPositioningDelegate {

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

}

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
                return
        }
        loginButton.isEnabled = true
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
