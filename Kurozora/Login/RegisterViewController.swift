//
//  RegisterViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import KCommonKit
import Alamofire
import SwiftyJSON

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        registerButton.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.delegate = self
        
        usernameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    //MARK: Actions
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerPressed(sender: AnyObject) {
        //        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        //        let vc = storyboard.instantiateViewController(withIdentifier: "Main") as UIViewController
        //        present(vc, animated: true, completion: nil)
        
        usernameTextField.trimSpaces()
        emailTextField.trimSpaces()
        
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        let endpoint = GlobalVariables().BaseURLString + "register"
        
        Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
        .responseJSON { response in
            switch response.result {
                case .success/*(let data)*/:
                    if response.result.value != nil{
                        let swiftyJsonVar = JSON(response.result.value!)
//                        let jsonData = result as! NSDictionary
                        
                        let responseSuccess = swiftyJsonVar["success"]
                        let responseMessage = swiftyJsonVar["error_message"]
                        
                        if responseSuccess.boolValue {
                            self.presentBasicAlertWithTitle(title: "Account created successfully! Please check your email for confirmation!")
                        }else{
                            self.presentBasicAlertWithTitle(title: responseMessage.stringValue)
                        }
                    }
//                    NSLog("------------------DATA START-------------------")
//                    NSLog("Response String: \(String(describing: data))")
//                    self.presentBasicAlertWithTitle(title: "Authenticated")
//                    NSLog("------------------DATA END-------------------")
                case .failure(let error):
                    print(error)
                    self.presentBasicAlertWithTitle(title: "There was an error while creating your account.  If this error persists, check out our Twitter account @KurozoraApp for more information!")
            }
        }
    }
    
}

extension RegisterViewController: UINavigationBarDelegate, UIBarPositioningDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let username = usernameTextField.text, !username.isEmpty,
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
            else {
                registerButton.isEnabled = false
                return
        }
        registerButton.isEnabled = true
    }
    
}

