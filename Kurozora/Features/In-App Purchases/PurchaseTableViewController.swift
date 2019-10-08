//
//  PurchaseTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit
import SCLAlertView

class PurchaseTableViewController: UITableViewController {
	// MARK: - IBOutlets
	@IBOutlet weak var leftNavigationBarButton: UIBarButtonItem!

	// MARK: - Properties
	var subscriptionDetails = [["unit": "1 Month", "trial": "Includes 1 week free trial!"], ["unit": "6 Months", "trial": "Includes 2 weeks free trial!"], ["unit": "12 Months", "trial": "Includes 2 weeks free trial!"]]
	var productIDs: [String] = ["20000331KPLUS1M", "20000331KPLUS6M", "20000331KPLUS12M"]
	fileprivate var _productsArray: [SKProduct] {
		get { return productsArray }
		set {
			productsArray = newValue.sorted(by: { return $0.price.decimalValue < $1.price.decimalValue })
		}
	}
	var productsArray: [SKProduct] = [SKProduct]() {
		didSet {
			self.tableView.reloadData()
		}
	}
	var leftNavigationBarButtonIsHidden: Bool = false {
		didSet {
			if leftNavigationBarButtonIsHidden {
				navigationItem.leftBarButtonItems = nil
			}
		}
	}

	// MARK: - View
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// Setup subscriptions
		self.fetchProductInformation()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.theme_backgroundColor = KThemePicker.backgroundColor.rawValue

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
				DispatchQueue.main.async {
					self._productsArray = products
				}
			}
		} else {
			// Warn the user that they are not allowed to make purchases.
			SCLAlertView().showWarning("Can't Purchase", subTitle: KStoreObserver.AlertType.disabled.message)
		}
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UITableViewDataSource
extension PurchaseTableViewController {
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
			let subscriptionPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PurchasePreviewTableViewCell", for: indexPath) as! PurchasePreviewTableViewCell
			return subscriptionPreviewTableViewCell
		} else if indexPath.section == 1 {
			let subscriptionButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PurchaseButtonTableViewCell", for: indexPath) as! SubscriptionButtonTableViewCell
			subscriptionButtonTableViewCell.productsArray = productsArray
			subscriptionButtonTableViewCell.productNumber = indexPath.row
			subscriptionButtonTableViewCell.subscriptionDetail = subscriptionDetails[indexPath.row]
			subscriptionButtonTableViewCell.purchaseButton.tag = indexPath.row
			subscriptionButtonTableViewCell.purchaseButtonTableViewCellDelegate = self
			return subscriptionButtonTableViewCell
		}

		let purchaseInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PurchaseInfoTableViewCell", for: indexPath) as! PurchaseInfoTableViewCell
		return purchaseInfoTableViewCell
	}
}

// MARK: -  UITableViewDelegate
extension PurchaseTableViewController {
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
		return 22
	}
}

// MARK: - SubscriptionButtonTableViewCellDelegate
extension PurchaseTableViewController: PurchaseButtonTableViewCellDelegate {
	func purchaseButtonPressed(_ sender: UIButton) {
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
