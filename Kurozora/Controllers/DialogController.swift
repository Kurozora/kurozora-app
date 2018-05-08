//
//  DialogController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import Foundation
//import iRate
//import FBSDKShareKit

class DialogController: NSObject {
    
    static let sharedInstance = DialogController()
    
    let DefaultFacebookAppInvitePromped = "Default.FacebookAppInvite.Promped"
    let DefaultFacebookAppInviteEventCount = "Default.FacebookAppInvite.EventCount"
    
//    func canShowFBAppInvite(viewController: UIViewController) {
//
//        let promped = UserDefaults.standard.bool(forKey: DefaultFacebookAppInvitePromped)
//        if promped {
//            return
//        }
//
//        let eventCount = UserDefaults.standard.integer(forKey: DefaultFacebookAppInviteEventCount)
//        if eventCount > 8 {
//            let alert = UIAlertController(title: "Help this app get Discovered", message: "If you like this app, please recommend it to your friends (private recommendation)", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Sure", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//                self.showFBAppInvite(viewController)
//            }))
//            alert.addAction(UIAlertAction(title: "No, thanks", style: UIAlertActionStyle.Default, handler: nil))
//            viewController.presentViewController(alert, animated: true, completion: nil)
//
//            UserDefaults.standard.set(true, forKey: DefaultFacebookAppInvitePromped)
//            UserDefaults.standard.synchronize()
//
//        } else {
//            // Increment event count
//            UserDefaults.standard.set(eventCount + 1, forKey: DefaultFacebookAppInviteEventCount)
//            UserDefaults.standard.synchronize()
//        }
//
//    }
    
//    func showFBAppInvite(viewController: UIViewController) {
//        let content = FBSDKAppInviteContent()
//        content.appLinkURL = NSURL(string: "https://fb.me/1471151336531847")
//        content.appInvitePreviewImageURL = NSURL(string: "https://files.parsetfss.com/496f5287-6440-4a0e-a747-4633b4710808/tfss-2143b956-6840-4e86-a0f1-f706c03f61f8-facebook-app-invite")
//        FBSDKAppInviteDialog.showFromViewController(viewController, withContent: content, delegate: nil)
//    }
}

//extension DialogController: FBSDKAppInviteDialogDelegate {
//    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]) {
//        print(results)
//    }
//
//    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError) {
//        print(error)
//    }
//}
