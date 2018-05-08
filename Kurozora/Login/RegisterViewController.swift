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

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationBar.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    //MARK: Actions
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        if usernameTextField.text == "" || emailTextField.text == "" || passwordTextField.text == "" {
            registerButton.isEnabled = false
        } else {
            registerButton.isEnabled = true
        }
    }
    
    @IBAction func registerPressed(sender: AnyObject) {
        //        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        //        let vc = storyboard.instantiateViewController(withIdentifier: "Main") as UIViewController
        //        present(vc, animated: true, completion: nil)
        
        usernameTextField.trimSpaces()
        emailTextField.trimSpaces()
        
        let username = usernameTextField.text as Any
        let email = emailTextField.text as Any
        let password = passwordTextField.text as Any
        
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
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
                    if let result = response.result.value{
                        let jsonData = result as! NSDictionary
                        let responseSuccess = jsonData.value(forKey: "success") as! Bool
                        let responseMessage:String
                        
                        if responseSuccess {
                            responseMessage = jsonData.value(forKey: "success_message") as! String
                            self.presentBasicAlertWithTitle(title: responseMessage)
                        }else{
                            responseMessage = jsonData.value(forKey: "error_message") as! String
                            self.presentBasicAlertWithTitle(title: responseMessage)
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

