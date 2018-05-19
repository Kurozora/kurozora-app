//
//  InAppTransactionController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

import KCommonKit

let PurchasedProNotification = "InApps.Purchased.Pro"

class InAppTransactionController {
//
//    class func purchaseProductWithID(productID: String) -> BFTask {
//        let completionSource = BFTaskCompletionSource()
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//
//        RMStore.defaultStore().addPayment(productID, success: { (transaction: SKPaymentTransaction!) -> Void in
//            self.purchaseCompleted([transaction])
//            completionSource.setResult([transaction])
//        }) { (transaction: SKPaymentTransaction!, error: NSError!) -> Void in
//            self.purchaseFailed(nil, error: error)
//            completionSource.setError(error)
//        }
//
//        return completionSource.task
//    }
//
//    class func restorePurchases() -> BFTask {
//        let completionSource = BFTaskCompletionSource()
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//
//        RMStore.defaultStore().restoreTransactionsOnSuccess({ (transactions) -> Void in
//            let allTransactions = transactions as! [SKPaymentTransaction]
//            self.purchaseCompleted(allTransactions)
//            completionSource.setResult(allTransactions)
//        }, failure: { (error) -> Void in
//            self.purchaseFailed(nil, error: error)
//            completionSource.setError(error)
//        })
//
//        return completionSource.task
//    }
//
//    class func purchaseCompleted(transactions: [SKPaymentTransaction]) {
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//
//        for transaction in transactions {
//            let productIdentifier = transaction.payment.productIdentifier
//
//            if productIdentifier == ProPlusInAppPurchase {
//                User.currentUser()!.addUniqueObject("PRO+", forKey: "badges")
//            } else if productIdentifier == ProInAppPurchase {
//                User.currentUser()!.addUniqueObject("PRO", forKey: "badges")
//            }
//            User.currentUser()!.saveInBackground()
//            NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
//        }
//        UserDefaults.standard.synchronize()
//
//        // Unlock..
//        NotificationCenter.default.post(name: PurchasedProNotification, object: nil)
//
//    }
//
//    class func purchaseFailed(transaction: SKPaymentTransaction?, error: NSError) {
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//
//        let alert = UIAlertController(title: "Payment Transaction Failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
//
//        if let window = UIApplication.shared.delegate?.window {
//            window?.rootViewController!.present(alert, animated: true, completion: nil)
//        }
//
//    }
}
