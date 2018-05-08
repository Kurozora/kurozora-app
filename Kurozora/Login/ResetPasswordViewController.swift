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
        if usernameTextField.text == "" {
            resetButton.isEnabled = false
        } else {
            resetButton.isEnabled = true
        }
    }
    
    @IBAction func resetPressed(sender: AnyObject) {
        //        let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        //        let vc = storyboard.instantiateViewController(withIdentifier: "Main") as UIViewController
        //        present(vc, animated: true, completion: nil)
        
        usernameTextField.trimSpaces()
        
        let username = usernameTextField.text as Any
        
         usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        let headers:HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        let parameters:Parameters = [
            "username" : username
        ]
    
        let endpoint = GlobalVariables().BaseURLString + "reset"
        
        Alamofire.request(endpoint, method: .post, parameters: parameters, headers: headers)
        .responseJSON { response in
            switch response.result {
            case .success/*(let data)*/:
                if let result = response.result.value{
                    let jsonData = result as! NSDictionary
                    let responseSuccess = jsonData.value(forKey: "success") as! Bool
                    let errorMessage = jsonData.value(forKey: "error_message") as! String
                    let successMessage = jsonData.value(forKey: "success_message") as! String
                    
                    if responseSuccess {
                        self.presentBasicAlertWithTitle(title: successMessage)
                    }else{
                        self.presentBasicAlertWithTitle(title: errorMessage)
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
