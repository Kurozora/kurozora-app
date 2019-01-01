//
//  AccountTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 26/09/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KCommonKit
import Kingfisher
import SCLAlertView

class AccountTableViewController: UITableViewController {
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let imageUrl = GlobalVariables().KDefaults["user_avatar"]
        
        if let avatar = imageUrl, avatar != "" {
            let avatar = URL(string: avatar)
            let resource = ImageResource(downloadURL: avatar!)
            userAvatar.kf.indicatorType = .activity
            userAvatar.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "default_avatar"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        }
        
        usernameLabel.text = GlobalVariables().KDefaults["username"]
        userEmailLabel.text = "some@email.com"
        userEmailLabel.textColor = .white
        userEmailLabel.textAlignment = .center
        userEmailLabel.font = UIFont(name: "System", size: 13)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        //        case (0,0): break
        case (1,0):
            let alertView = SCLAlertView()
            alertView.addButton("Yes, sign me out 😞", action: {
                if let isLoggedIn = User.isLoggedIn() {
                    if isLoggedIn {
                        Service.shared.logout(withSuccess: { (success) in
                            let storyboard:UIStoryboard = UIStoryboard(name: "login", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController
                            
                            self.present(vc, animated: true, completion: nil)
                        })
					} else {
						let storyboard:UIStoryboard = UIStoryboard(name: "login", bundle: nil)
						let vc = storyboard.instantiateViewController(withIdentifier: "Welcome") as! WelcomeViewController

						self.present(vc, animated: true, completion: nil)
					}
                }
            })
            
            alertView.showNotice("Sign out", subTitle: "Are you sure you want to sign out?", closeButtonTitle: "No, keep me signed in 😆")
        default:
            break
//            SCLAlertView().showInfo(String(indexPath.section), subTitle: String(indexPath.row))
        }
    }
}
