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

//protocol LoginViewControllerDelegate: class {
//
//    func LoginViewControllerLoggedIn()
//
//}

class LoginViewController: UIViewController {

    let defaultValues = UserDefaults.standard
    
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
//    var isInWindowRoot = true
//    weak var delegate: LoginViewControllerDelegate?
    
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
    
    @objc func textFieldDidChange(textField: UITextField) {
        if usernameTextField.text == "" || passwordTextField.text == "" {
            loginButton.isUserInteractionEnabled = false
        } else {
            loginButton.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
//        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "Main") as UIViewController
//        present(vc, animated: true, completion: nil)
        
        usernameTextField.trimSpaces()

        let username = usernameTextField.text
        let password = passwordTextField.text
        
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)

        var headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        if let authorizationHeader = Request.authorizationHeader(user: username!, password: password!) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        let endpoint = GlobalVariables().BaseURLString + "login"

        Alamofire.request(endpoint, method: .post, headers: headers)
        .responseJSON { response in
            switch response.result {
                case .success/*(let data)*/:
                    if let result = response.result.value{
                        let jsonData = result as! NSDictionary
                        let responseSuccess = jsonData.value(forKey: "success") as! Bool
//                        let responseMessage = jsonData.value(forKey: "message") as! String
                        
                        if responseSuccess {
//                            self.presentBasicAlertWithTitle(title: "Authenticated")
                            
                            
                        }else{
                            
//                            self.presentBasicAlertWithTitle(title: responseMessage)
                        }
                    }
    //                NSLog("------------------DATA START-------------------")
    //                NSLog("Response String: \(String(describing: data))")
    //                self.presentBasicAlertWithTitle(title: "Authenticated")
    //                NSLog("------------------DATA END-------------------")
                case .failure/*(let error)*/:
                    let storyboard:UIStoryboard = UIStoryboard(name: "Home", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "Home") as! HomeViewController
                    self.show(vc, sender: self)
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

//    func loginWithUsername(username: String, password: String) {
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
//    }

}

extension LoginViewController: UINavigationBarDelegate, UIBarPositioningDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

//extension LoginViewController: UITextFieldDelegate {
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        view.endEditing(true)
//        if textField == passwordTextField {
//            loginPressed(sender: textField)
//        }
//        return true
//    }
//
//}

