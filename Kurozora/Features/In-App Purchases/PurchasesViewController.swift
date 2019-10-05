//
//  PurchasesViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit
import SCLAlertView

class PurchaseViewController: UITableViewController {
	// MARK: - Properties
	var subscriptionDetails = [["unit": "1 Month", "subtext": "Includes 1 week free trial!"], ["unit": "6 Months", "subtext": "(6 months at $1,99/mo. Save 50%)\nIncludes 2 weeks free trial!"], ["unit": "12 Months", "subtext": "(12 months at $1,58/mo. Save 60%)\nIncludes 2 weeks free trial!"]]
	var productIDs: [String] = ["20000331KPLUS1M", "20000331KPLUS6M", "20000331KPLUS12M"]
	fileprivate var _productsArray: [SKProduct] {
		get { return productsArray }
		set {
			productsArray = newValue.sorted(by: { return $0.price.decimalValue < $1.price.decimalValue })
		}
	}
	var productsArray: [SKProduct] = [SKProduct]() {
		didSet {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

		// Setup subscriptions
		fetchProductInformation()

		// Setup table view
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = UITableView.automaticDimension
	}

	// MARK: - Functions
	/// Retrieves product information from the App Store.
	fileprivate func fetchProductInformation() {
		if KStoreObserver.shared.isAuthorizedForPayments {
			KStoreObserver.shared.setProductIDs(ids: self.productIDs)
			KStoreObserver.shared.fetchAvailableProducts { products in
				self._productsArray = products
			}
		} else {
			// Warn the user that they are not allowed to make purchases.
			SCLAlertView().showWarning("Can't Purchase", subTitle: KStoreObserver.AlertType.disabled.message)
		}
	}

	// MARK: - IBActions
	@IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UITableViewDataSource
extension PurchaseViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 3
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 1 {
			return productsArray.count
		}
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let subscriptionPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionPreviewTableViewCell", for: indexPath) as! SubscriptionPreviewTableViewCell
			return subscriptionPreviewTableViewCell
		} else if indexPath.section == 1 {
			let subscriptionButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionButtonTableViewCell", for: indexPath) as! SubscriptionButtonTableViewCell
			subscriptionButtonTableViewCell.subscriptionItem = productsArray[indexPath.row]
			subscriptionButtonTableViewCell.subscriptionDetail = subscriptionDetails[indexPath.row]
			subscriptionButtonTableViewCell.subscriptionButton.tag = indexPath.row
			subscriptionButtonTableViewCell.subscriptionButtonTableViewCellDelegate = self
			return subscriptionButtonTableViewCell
		}

		let subscriptionInfoCell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionInfoCell", for: indexPath) as! SubscriptionInfoCell
		return subscriptionInfoCell
	}
}

// MARK: -  UITableViewDelegate
extension PurchaseViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			let cellRatio: CGFloat = UIDevice.isLandscape ? 1.5 : 3
			return view.frame.height / cellRatio
		}

		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 20
	}
}

// MARK: - SubscriptionButtonTableViewCellDelegate
extension PurchaseViewController: SubscriptionButtonTableViewCellDelegate {
	func subscriptionButtonPressed(_ sender: UIButton) {
		if self.productsArray.count != 0 {
			KStoreObserver.shared.purchase(product: self.productsArray[sender.tag]) { (alert, product, transaction) in
				if let tran = transaction, let prod = product {
					print("Transaction: \(tran)")
					print("Product: \(prod)")
				}
				SCLAlertView().showWarning(alert.message)
			}
		}
	}
}
