//
//  InAppPurchaseViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/04/2018.
//  Copyright © 2018 Kusa. All rights reserved.
//

//import RMStore
import KCommonKit
import UIKit

class InAppPurchaseViewController: UITableViewController {
    
//    var loadingView: LoaderView!
//
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var proButton: UIButton!
//    @IBOutlet weak var proPlusButton: UIButton!
//
//
//    class func showInAppPurchaseWith(
//        viewController: UIViewController) {
//
//        let controller = UIStoryboard(name: "InApp", bundle: nil).instantiateInitialViewController() as! UINavigationController
//        viewController.present(controller, animated: true, completion: nil)
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.title = "Kurozora Pro"
//
//        loadingView = LoaderView(parentView: view)
//
//        NotificationCenter.default.addObserver(self, selector: "updateViewForPurchaseState", name: NSNotification.Name(rawValue: PurchasedProNotification), object: nil)
//        NotificationCenter.defaultCenter.addObserver(self, selector: "setPrices", name: PurchasedProNotification, object: nil)
//
//        if let navController = parent as? UINavigationController {
//            if let firstController = navController.viewControllers.first, !firstController.isKindOfClass(SettingsViewController) {
//                navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: "dismissViewControllerPressed")
//            }
//        }
//
//        updateViewForPurchaseState()
//        fetchProducts()
//    }
//
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    func updateViewForPurchaseState() {
//        if let _ = InAppController.hasAnyPro() {
//            descriptionLabel.text = "Thanks for supporting Kurozora! You're an exclusive PRO member that is helping us create an even better app"
//        } else {
//            descriptionLabel.text = "Browse all seasonal charts, unlock calendar view, discover more anime, remove all ads forever, and more importantly helps us take Kurozora to the next level"
//        }
//    }
//
//    func fetchProducts() {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        loadingView.startAnimating()
//        let products: Set = [ProInAppPurchase, ProPlusInAppPurchase]
//        RMStore.defaultStore().requestProducts(products, success: { (products, invalidProducts) -> Void in
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//            self.setPrices()
//            self.loadingView.stopAnimating()
//        }) { (error) -> Void in
//            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//
//            let alert = UIAlertController(title: "Products Request Failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//
//            self.presentViewController(alert, animated: true, completion: nil)
//            self.loadingView.stopAnimating()
//        }
//    }
//
//    func setPrices() {
//
//        if let _ = InAppController.purchasedPro() {
//            proButton.setTitle("Unlocked", for: .Normal)
//        } else {
//            let product = RMStore.defaultStore().productForIdentifier(ProInAppPurchase)
//            let localizedPrice = RMStore.localizedPriceOfProduct(product)
//            proButton.setTitle(localizedPrice, forState: .Normal)
//        }
//
//        if let _ = InAppController.purchasedProPlus(){
//            proPlusButton.setTitle("Unlocked", for: .Normal)
//        } else {
//            let product = RMStore.defaultStore().productForIdentifier(ProPlusInAppPurchase)
//            let localizedPrice = RMStore.localizedPriceOfProduct(product)
//            proPlusButton.setTitle(localizedPrice, forState: .Normal)
//        }
//    }
//
//    func purchaseProductWithID(productID: String) {
//        InAppTransactionController.purchaseProductWithID(productID).continueWithSuccessBlock { (task: BFTask!) -> AnyObject? in
//
//
//
//            return nil
//        }
//    }
//
//    func dismissViewControllerPressed() {
//        dismiss(animated: true, completion: nil)
//    }
//
//    @IBAction func buyProPressed(sender: AnyObject) {
//        purchaseProductWithID(ProInAppPurchase)
//    }
//
//    @IBAction func buyProPlusPressed(sender: AnyObject) {
//        purchaseProductWithID(ProPlusInAppPurchase)
//    }
//
}
