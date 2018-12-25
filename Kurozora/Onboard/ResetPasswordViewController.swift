//
//  ResetPasswordViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit
import SCLAlertView

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var userEmailTextField: CustomTextField!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetButton.isEnabled = false
//        userEmailTextField.becomeFirstResponder()
        userEmailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //MARK: Actions    
    @IBAction func resetPressed(sender: AnyObject) {
        view.endEditing(true)
        userEmailTextField.trimSpaces()
        
        let userEmail = userEmailTextField.text!
        
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
            let username = userEmailTextField.text, !username.isEmpty
            else {
                resetButton.isEnabled = false
                return
        }
        resetButton.isEnabled = true
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
