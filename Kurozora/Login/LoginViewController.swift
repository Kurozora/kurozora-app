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

protocol LoginViewControllerDelegate: class {

    func LoginViewControllerLoggedIn()

}

class LoginViewController: UIViewController {
    
    let defaultValues = UserDefaults.standard
    
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
 
        loginButton.isEnabled = false
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

        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "username": username,
            "password": password
        ]

        let endpoint = GlobalVariables().BaseURLString + "login"

        Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
        .responseJSON { response in
            switch response.result {
                case .success/*(let data)*/:
                    if response.result.value != nil{
                        let swiftyJsonVar = JSON(response.result.value!)
                    
                        let responseSuccess = swiftyJsonVar["success"]
                        let responseMessage = swiftyJsonVar["error_message"]
                    
                        if responseSuccess.boolValue {
                            self.presentBasicAlertWithTitle(title: "Authenticated")
                        }else{
                            self.presentBasicAlertWithTitle(title: responseMessage.stringValue)
                        }
                        
//    //                NSLog("------------------DATA START-------------------")
//    //                NSLog("Response String: \(String(describing: data))")
//    //                self.presentBasicAlertWithTitle(title: "Authenticated")
//    //                NSLog("------------------DATA END-------------------")
                    }
                case .failure(let err):
                    NSLog("------------------DATA START-------------------")
                    NSLog("Response String: \(String(describing: err))")
                    self.presentBasicAlertWithTitle(title: "There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
                    NSLog("------------------DATA END-------------------")
//                    let storyboard:UIStoryboard = UIStoryboard(name: "profile", bundle: nil)
//                    let vc = storyboard.instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
//                    self.show(vc, sender: self)
//                    print(error)
//                    self.presentBasicAlertWithTitle(title: "There was an error while logging in to your account. If this error persists, check out our Twitter account @KurozoraApp for more information!")
            }
        }

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
