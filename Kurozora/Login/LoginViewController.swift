//
//  LoginViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import KCommonKit

protocol LoginViewControllerDelegate: class {
    
    func LoginViewControllerLoggedIn()

}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var isInWindowRoot = true
    weak var delegate: LoginViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewControllerID") as UIViewController
        present(vc, animated: true, completion: nil)
        
//        usernameTextField.trimSpaces()
//
//        guard let username = usernameTextField.text, let password = passwordTextField.text else {
//            presentBasicAlertWithTitle(title: "Username or password field is empty")
//            return
//        }
        
//        User.logInWithUsernameInBackground(username.lowercaseString, password:password) {
//            (user: PFUser?, error: NSError?) -> Void in
//            if let _ = error {
//                // The login failed. Check error to see why.
//                self.loginWithUsername(username, password: password)
//            } else {
//                self.view.endEditing(true)
//                self.dismiss(animated: true, completion: { () -> Void in
//                    self.delegate?.LoginViewControllerLoggedIn()
//                })
//            }
//        }
    }

    func loginWithUsername(username: String, password: String) {
//        User.logInWithUsernameInBackground(usernameTextField.text!, password:passwordTextField.text!) {
//            (user: PFUser?, error: NSError?) -> Void in
//
//            if let error = error {
//                let errorMessage = error.userInfo["error"] as! String
//                let alert = UIAlertController(title: "Hmm", message: errorMessage+". If you signed in with Facebook, login in with Facebook is required.", preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//
//
//                self.presentViewController(alert, animated: true, completion: nil)
//            } else {
//                self.view.endEditing(true)
//                self.dismiss(animated: true, completion: { () -> Void in
//                    self.delegate?.LoginViewControllerLoggedIn()
//                })
//            }
//        }
    }

}

extension LoginViewController: UINavigationBarDelegate, UIBarPositioningDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if textField == passwordTextField {
            loginPressed(sender: textField)
        }
        return true
    }

}

