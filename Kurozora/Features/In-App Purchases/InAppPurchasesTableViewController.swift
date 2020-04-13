//
//  InAppPurchasesTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import StoreKit
import SCLAlertView

class InAppPurchasesTableViewController: KTableViewController {
	// MARK: - IBOutlets
	/// The left navigation bar button of the navigation controller's `navigationItem`.
	@IBOutlet weak var leftNavigationBarButton: UIBarButtonItem?

	// MARK: - Properties
	/// The titles of the products. Different from the one in `SKProduct` since that doesn't support spacial characters such as emojis.
	var productTitles: [String] {
		return []
	}

	/// The ids of the in app purchases to be displayed.
	var productIDs: [String] {
		return []
	}

	/// Images displaying the features included in the in-app purchase.
	var previewImages: [UIImage?] {
		return []
	}

	/// A storage for the `leftBarButtonItems` of `navigationItem`.
	fileprivate var _leftBarButtonItems: [UIBarButtonItem]?
	/// Set to `false` to hide the left navigation bar.
	var leftNavigationBarButtonIsHidden: Bool = false {
		didSet {
			if leftNavigationBarButtonIsHidden {
				let leftBarButtonItems = navigationItem.leftBarButtonItems
				if leftBarButtonItems != nil {
					_leftBarButtonItems = navigationItem.leftBarButtonItems
					navigationItem.leftBarButtonItems = nil
				}
			} else {
				navigationItem.leftBarButtonItems = _leftBarButtonItems
			}
		}
	}

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
			// Fetch subscriptions.
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
			DispatchQueue.main.async {
				// Warn the user that they are not allowed to make purchases.
				SCLAlertView().showWarning("Can't Purchase", subTitle: KStoreObserver.AlertType.disabled.message)
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension InAppPurchasesTableViewController {
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
		if indexPath.section == 1 {
			let purchaseButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PurchaseButtonTableViewCell", for: indexPath) as! PurchaseButtonTableViewCell
			return purchaseButtonTableViewCell
		}

		guard let productInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productInfoTableViewCell, for: indexPath) else {
			fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productInfoTableViewCell.identifier)")
		}
		return productInfoTableViewCell
	}
}

// MARK: - UITableViewDelegate
extension InAppPurchasesTableViewController {
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if indexPath.section == 1 {
			if let purchaseButtonTableViewCell = cell as? PurchaseButtonTableViewCell {
				purchaseButtonTableViewCell.productNumber = indexPath.row
				purchaseButtonTableViewCell.productTitle = productTitles.isEmpty ? "" : productTitles[indexPath.row]
				purchaseButtonTableViewCell.productsArray = productsArray
				purchaseButtonTableViewCell.purchaseButton.tag = indexPath.row
				purchaseButtonTableViewCell.purchaseButtonTableViewCellDelegate = self
			}
		}
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 22
	}
}

// MARK: - SubscriptionButtonTableViewCellDelegate
extension InAppPurchasesTableViewController: PurchaseButtonTableViewCellDelegate {
	func purchaseButtonPressed(_ sender: UIButton) {
		if self.productsArray.count != 0 {
			KStoreObserver.shared.purchase(product: self.productsArray[sender.tag]) { (alert, _, _) in
				SCLAlertView().showWarning(alert.message)
			}
		}
	}
}
