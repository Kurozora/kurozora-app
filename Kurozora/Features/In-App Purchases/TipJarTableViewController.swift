//
//  TipJarTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit
import SCLAlertView

class TipJarTableViewController: KTableViewController {
	// MARK: - Properties
	var purchaseDetails = ["Wolf tip 🐺", "Tiger tip 🐯", "Demon tip 👺", "Dragon tip 🐲", "God tip 🙏"]

	#if targetEnvironment(macCatalyst)
	var productIDs: [String] = ["20000331KTIPWOLF_macCatalyst", "20000331KTIPTIGER_macCatalyst", "20000331KTIPDEMON_macCatalyst", "20000331KTIPDRAGON_macCatalyst", "20000331KTIPGOD_macCatalyst"]
	#else
	var productIDs: [String] = ["20000331KTIPWOLF", "20000331KTIPTIGER", "20000331KTIPDEMON", "20000331KTIPDRAGON", "20000331KTIPGOD"]
	#endif

	fileprivate var _productsArray: [SKProduct] {
		get { return productsArray }
		set {
			productsArray = newValue.sorted(by: { return $0.price.decimalValue < $1.price.decimalValue })
		}
	}
	var productsArray: [SKProduct] = [SKProduct]() {
		didSet {
			_prefersActivityIndicatorHidden = true
			self.tableView.reloadData()
		}
	}

	// Activity indicator
	var _prefersActivityIndicatorHidden = false {
		didSet {
			self.setNeedsActivityIndicatorAppearanceUpdate()
		}
	}
	override var prefersActivityIndicatorHidden: Bool {
		return _prefersActivityIndicatorHidden
	}

	// MARK: - View
	override func viewDidLoad() {
		super.viewDidLoad()

		DispatchQueue.global(qos: .background).async {
			// Fetch in-app purchases.
			self.fetchProductInformation()
		}
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
}

// MARK: - UITableViewDataSource
extension TipJarTableViewController {
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
			guard let purchaseHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseHeaderTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.purchaseHeaderTableViewCell.identifier)")
			}
			return purchaseHeaderTableViewCell
		} else if indexPath.section == 1 {
			let purchaseButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PurchaseButtonTableViewCell", for: indexPath) as! PurchaseButtonTableViewCell
			purchaseButtonTableViewCell.productsArray = productsArray
			purchaseButtonTableViewCell.productNumber = indexPath.row
			purchaseButtonTableViewCell.purchaseDetail = purchaseDetails[indexPath.row]
			purchaseButtonTableViewCell.purchaseButton.tag = indexPath.row
			purchaseButtonTableViewCell.purchaseButtonTableViewCellDelegate = self
			return purchaseButtonTableViewCell
		}

		guard let purchaseInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseInfoTableViewCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.purchaseInfoTableViewCell.identifier)")
		}
		return purchaseInfoTableViewCell
	}
}

// MARK: - UITableViewDelegate
extension TipJarTableViewController {

}

// MARK: - PurchaseButtonTableViewCellDelegate
extension TipJarTableViewController: PurchaseButtonTableViewCellDelegate {
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
