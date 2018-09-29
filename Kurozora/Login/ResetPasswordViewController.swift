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
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // MARK: - Status bar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view, typically from a nib.
        navigationBar.delegate = self
        
        resetButton.isEnabled = false
        userEmailTextField.becomeFirstResponder()
        userEmailTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
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
        view.endEditing(true)
        userEmailTextField.trimSpaces()
        
        let userEmail = userEmailTextField.text!
        
        Service.shared.resetPassword(userEmail, withSuccess: { (reset) in
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("Done", action: {
                let storyboard: UIStoryboard = UIStoryboard(name: "login", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
                self.show(vc, sender: self)
            })
            alertView.showSuccess("Success!", subTitle: "If an account exists with this email address, you should receive an email with your reset link shortly.")
        }) { (errorMessage) in
            SCLAlertView().showError("Error resetting password", subTitle: errorMessage)
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
