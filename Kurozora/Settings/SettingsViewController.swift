//
//  SettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit

let DefaultLoadingScreen = "Defaults.InitialLoadingScreen";

class SettingsViewController: UITableViewController {
    
//    let FacebookPageDeepLink = "fb://profile/713541968752502";
//    let FacebookPageURL = "https://www.facebook.com/AozoraApp";
//    let TwitterPageDeepLink = "twitter://user?id=3366576341";
//    let TwitterPageURL = "https://www.twitter.com/AozoraApp";
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var linkWithMyAnimeListLabel: UILabel!
    @IBOutlet weak var linkWithKitsuLabel: UILabel!
    @IBOutlet weak var termsOfServicesLabel: UILabel!
    //    @IBOutlet weak var facebookLikeButton: FBSDKLikeButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        facebookLikeButton.objectID = "https://www.facebook.com/AozoraApp"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        updateLoginButton()
    }
    
//    func updateLoginButton() {
//        if User.currentUserLoggedIn() {
//            // Logged In both
//            loginLabel.text = "Logout from Kurozora"
//        } else if User.currentUserIsGuest() {
//            // User is guest
//            loginLabel.text = "Login to Kurozora"
//        }
//
//        if User.syncingWithMyAnimeList() {
//            linkWithMyAnimeListLabel.text = "Unlink MyAnimeList"
//        } else {
//            linkWithMyAnimeListLabel.text = "Sync with MyAnimeList"
//        }
//
//    }
    
    // MARK: - IBActions
    
    @IBAction func dismissPressed(sender: AnyObject) {
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView functions
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let segueIdentifier: String
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

//        guard let cell = tableView.cellForRow(at: indexPath as IndexPath) else {
//            return
//        }

        switch (indexPath.section, indexPath.row) {
//        case (0,0):
//            // Login / Logout
//            if User.currentUserLoggedIn() {
//                // Logged In both, logout
//                let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//                alert.popoverPresentationController?.sourceView = cell.superview
//                alert.popoverPresentationController?.sourceRect = cell.frame
//
//                alert.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
//
//                    WorkflowController.logoutUser().continueWithExecutor( BFExecutor.mainThreadExecutor(), withSuccessBlock: { (task: BFTask!) -> AnyObject? in
//
//                        if let error = task.error {
//                            print("Failed loggin out: \(error)")
//                        } else {
//                            print("Logout succeeded")
//                        }
//                        WorkflowController.presentOnboardingController(true)
//                        return nil
//                    })
//                }))
//                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
//                }))
//
//                self.present(alert, animated: true, completion: nil)
//
//            } else if User.currentUserIsGuest() {
//                // User is guest, login
//                WorkflowController.presentOnboardingController(true)
//            }
//        case (0,1):
//            // Sync with MyAnimeList
//            if User.syncingWithMyAnimeList() {
//                let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//                alert.popoverPresentationController?.sourceView = cell.superview
//                alert.popoverPresentationController?.sourceRect = cell.frame
//
//                alert.addAction(UIAlertAction(title: "Stop syncing with MyAnimeList", style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
//
//                    User.logoutMyAnimeList()
//                    self.updateLoginButton()
//                }))
//                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
//                }))
//
//                self.present(alert, animated: true, completion: nil)
//            } else {
//
//                let loginController = ANParseKit.loginViewController()
//                presentViewController(loginController, animated: true, completion: nil)
//
//                UserDefaults.standardUserDefaults().setBool(true, forKey: RootTabBar.ShowedMyAnimeListLoginDefault)
//                UserDefaults.standard.synchronize()
//            }
//
        case (0,2):
            // Select initial tab
            let alert = UIAlertController(title: "Select Initial Tab", message: "This tab will load when application starts", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Season", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                UserDefaults.standard.setValue("Season", forKey: DefaultLoadingScreen)
                UserDefaults.standard.synchronize()
            }))
            alert.addAction(UIAlertAction(title: "Library", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                UserDefaults.standard.setValue("Library", forKey: DefaultLoadingScreen)
                UserDefaults.standard.synchronize()
            }))
            alert.addAction(UIAlertAction(title: "Profile", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                UserDefaults.standard.setValue("Profile", forKey: DefaultLoadingScreen)
                UserDefaults.standard.synchronize()
            }))
            alert.addAction(UIAlertAction(title: "Forum", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                UserDefaults.standard.setValue("Forum", forKey: DefaultLoadingScreen)
                UserDefaults.standard.synchronize()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            }))

            self.present(alert, animated: true, completion: nil)

//        case (1,0):
//            // Unlock features
//            let controller = UIStoryboard(name: "InApp", bundle: nil).instantiateViewControllerWithIdentifier("InApp") as! InAppPurchaseViewController
//            navigationController?.pushViewController(controller, animated: true)
//        case (1,1):
//            // Restore purchases
//            InAppTransactionController.restorePurchases().continueWithBlock({ (task: BFTask!) -> AnyObject? in
//
//                if let _ = task.result {
//                    let alert = UIAlertController(title: "Restored!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//
//                    self.presentViewController(alert, animated: true, completion: nil)
//                }
//
//                return nil
//            })
//        case (2,0):
//            // Rate app
//            iRate.sharedInstance().openRatingsPageInAppStore()
//        case (2,1):
//            // Recommend to friends
//            DialogController.sharedInstance.showFBAppInvite(self)
//        case (3,0):
//            // Open Facebook
//            var url: NSURL?
//            if let twitterScheme = NSURL(string: "fb://requests"), UIApplication.shared.canOpenURL(twitterScheme as URL) {
//                url = NSURL(string: FacebookPageDeepLink)
//            } else {
//                url = NSURL(string: FacebookPageURL)
//            }
//            UIApplication.shared.openURL(url! as URL)
//        case (3,1):
//            // Open Twitter
//            var url: NSURL?
//            if let twitterScheme = NSURL(string: "twitter://"), UIApplication.shared.canOpenURL(twitterScheme as URL) {
//                url = NSURL(string: TwitterPageDeepLink)
//            } else {
//                url = NSURL(string: TwitterPageURL)
//            }
//            UIApplication.shared.openURL(url! as URL)
        case (4,0):
            // Segue to legal page
            segueIdentifier = "LegalSegue"
            self.performSegue(withIdentifier: segueIdentifier, sender: self)
        default:
            break
        }


    }
    
//    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//
//        switch section {
//        case 0:
//            return nil
//        case 1:
//            var message = ""
//            if let user = User.currentUser(),
//                user.hasTrial() &&
//                    InAppController.purchasedPro() == nil &&
//                    InAppController.purchasedProPlus() == nil {
//                message = "** You're on a 15 day PRO trial **\n"
//            }
//            message += "Going PRO unlocks all features and help us keep improving the app"
//            return message
//        case 2:
//            return "If you're looking for support drop us a message on Facebook or Twitter"
//        case 3:
//            let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
//            let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
//            return "Created by Anime fans for Anime fans, enjoy!\nKurozora \(version) (\(build))"
//        default:
//            return nil
//        }
//    }
}

//extension SettingsViewController: ModalTransitionScrollable {
//    var transitionScrollView: UIScrollView? {
//        return tableView
//    }
//}
