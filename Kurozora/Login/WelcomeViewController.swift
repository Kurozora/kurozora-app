//
//  WelcomeViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 17/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import Foundation

class WelcomeViewController: UIViewController {
    
//    var isInWindowRoot = true

    override func viewWillAppear(_ animated: Bool) {
        // Sets the status bar to hidden when the view has finished appearing
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Sets the status bar to visible when the view is about to disappear
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.isHidden = false
    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showSignIn" {
//            let sign = segue.destination as! LoginViewController
//            sign.delegate = self
//            sign.isInWindowRoot = isInWindowRoot
//        } else if segue.identifier == "showSignUp" {
//            let sign = segue.destination as! RegisterViewController
//            sign.delegate = self
//            sign.user = sender as? User
//            sign.isInWindowRoot = isInWindowRoot
//            sign.loggedInWithFacebook = loggedInWithFacebook
//        }
//    }
//
//    func presentRootTabBar() {
//
//        fillInitialUserDataIfNeeded()
//
//        if isInWindowRoot {
//            WorkflowController.presentRootTabBar(animated: true)
//        } else {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
//
//    @IBAction func RegisterWithEmailPressed(sender: AnyObject) {
//        performSegue(withIdentifier: "showSignUp", sender: nil)
//    }
//
//    @IBAction func LoginPressed(sender: AnyObject) {
//        performSegue(withIdentifier: "showSignIn", sender: nil)
//    }
}

//extension WelcomeViewController: LoginViewControllerDelegate {
//    func LoginViewControllerLoggedIn() {
//        presentRootTabBar()
//    }
//}
//
//extension WelcomeViewController: RegisterViewControllerDelegate {
//    func RegisterViewControllerCreatedAccount() {
//        presentRootTabBar()
//    }
//}
