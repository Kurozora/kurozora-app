//
//  SettingsViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 21/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import UIKit
import KCommonKit
import KDatabaseKit
import Kingfisher
import SCLAlertView

let DefaultLoadingScreen = "Defaults.InitialLoadingScreen";

class SettingsViewController: UITableViewController {
    //    let FacebookPageDeepLink = "fb://profile/713541968752502"
    //    let FacebookPageURL = "https://www.facebook.com/KurozoraApp"
    let TwitterPageDeepLink = "twitter://user?id=991929359052177409"
    let TwitterPageURL = "https://www.twitter.com/KurozoraApp"
    
    let MediumPageDeepLink = "medium://@kurozora"
    let MediumPageURL = "https://medium.com/@kurozora"
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var cacheSizeLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let imageUrl = GlobalVariables().KDefaults["user_avatar"]
        
        if let avatar = imageUrl, avatar != "" {
            let avatar = URL(string: avatar)
            let resource = ImageResource(downloadURL: avatar!)
            userAvatar.kf.indicatorType = .activity
            userAvatar.kf.setImage(with: resource, placeholder: UIImage(named: "default_avatar"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        }
        
        usernameLabel.text = GlobalVariables().KDefaults["username"]
        
        // Calculate cache size
        caculateCache()
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		//        facebookLikeButton.objectID = "https://www.facebook.com/KurozoraApp"

		ImageCache.default.calculateDiskCacheSize { size in
			// Convert from bytes to mebibytes (2^20)
			let sizeInMiB = Double(size/1048576)
			self.cacheSizeLabel.text = String(format:"%.2f", sizeInMiB) + "MiB"
		}
	}
    
    // MARK: - Functions
    func caculateCache() {
        ImageCache.default.calculateDiskCacheSize { size in
            // Convert from bytes to mebibytes (2^20)
            let sizeInMiB = Double(size/1048576)
            self.cacheSizeLabel.text = String(format:"%.2f", sizeInMiB) + "MiB"
        }
    }
    
    // MARK: - IBAction
    @IBAction func dismissPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        if let isAdmin = User.isAdmin() {
            if !isAdmin && section == 1 {
                return count - 1
            }
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let isAdmin = User.isAdmin() {
            if !isAdmin && indexPath.section == 1 {
                return super.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: indexPath.section + 1))
            }
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        let segueIdentifier: String
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        //        guard let settingsCell = tableView.cellForRow(at: indexPath as IndexPath) else {
        //            return
        //        }
        
        switch (indexPath.section, indexPath.row) {
            //        case (0,0): break
            //        case (1,0): break
        //        case (2,0): break
        case (2,1):
            let alertView = SCLAlertView()
            alertView.addButton("Clear 🗑", action: {
                // Clear memory cache right away.
                KingfisherManager.shared.cache.clearMemoryCache()
                
                // Clear disk cache. This is an async operation.
                KingfisherManager.shared.cache.clearDiskCache()
                
                // Clean expired or size exceeded disk cache. This is an async operation.
                KingfisherManager.shared.cache.cleanExpiredDiskCache()
                
                // Refresh cacheSizeLabel
                self.caculateCache()
            })
            
            alertView.showWarning("Clear all cache?", subTitle: "All of your caches will be cleared and Kurozora will restart.", closeButtonTitle: "Cancel")
            //        case (0,2):
            //        case (3,0):
            //            // Unlock features
            //            let controller = UIStoryboard(name: "InApp", bundle: nil).instantiateViewControllerWithIdentifier("InApp") as! InAppPurchaseViewController
            //            navigationController?.pushViewController(controller, animated: true)
            //        case (3,1):
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
            //        case (4,0):
            //            // Rate app
        //            iRate.sharedInstance().openRatingsPageInAppStore()
        case (5,0):
            // Open Twitter
            var url: URL?
            let twitterScheme = URL(string: "twitter://")!
            
            if UIApplication.shared.canOpenURL(twitterScheme) {
                url = URL(string: TwitterPageDeepLink)
            } else {
                url = URL(string: TwitterPageURL)
            }
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        case (5,1):
            // Open Medium
            var url: URL?
            let twitterScheme = URL(string: "medium://")!
            
            if UIApplication.shared.canOpenURL(twitterScheme) {
                url = URL(string: MediumPageDeepLink)
            } else {
                url = URL(string: MediumPageURL)
            }
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        default:
            SCLAlertView().showInfo(String(indexPath.section), subTitle: String(indexPath.row))
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
