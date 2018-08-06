//
//  ResetPasswordViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
import KCommonKit
import Alamofire
import SwiftyJSON

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var usernameTextField: CustomTextField!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationBar.delegate = self
        
        resetButton.isEnabled = false
        usernameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    //MARK: Actions
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPressed(sender: AnyObject) {
        //        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        //        let vc = storyboard.instantiateViewController(withIdentifier: "Main") as UIViewController
        //        present(vc, animated: true, completion: nil)
        
        usernameTextField.trimSpaces()
        
        let username = usernameTextField.text!
        
        let headers:HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let parameters:Parameters = [
            "username" : username
        ]
    
        let endpoint = GlobalVariables().BaseURLString + "user/reset"
        
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
                           self.presentBasicAlertWithTitle(title: "Please check your email for the password reset link!")
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
                    self.presentBasicAlertWithTitle(title: "There was an error while resetting your password.  If this error persists, check out our Twitter account @KurozoraApp for more information!")
            }
        }
    }
}

extension ResetPasswordViewController: UINavigationBarDelegate, UIBarPositioningDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

}

extension ResetPasswordViewController: UITextFieldDelegate {
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let username = usernameTextField.text, !username.isEmpty
            else {
                resetButton.isEnabled = false
                return
        }
        resetButton.isEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            resetPressed(sender: usernameTextField)
        default:
            usernameTextField.resignFirstResponder()
        }
        
        return true
    }
    
}
