//
//  ProductTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

class ProductTableViewController: KTableViewController {
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

	/// The service type used to populate the table view cells.
	var serviceType: ServiceType? {
		return nil
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
				self.presentAlertController(title: "Can't Purchase", message: KStoreObserver.AlertType.disabled.message)
			}
		}
	}
}

// MARK: - UITableViewDataSource
extension ProductTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section(rawValue: section) {
		case .header:
			return 1
		case .body:
			return productsArray.count
		case .footer:
			return 1
		case .none:
			return 0
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .body:
			let purchaseButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PurchaseButtonTableViewCell", for: indexPath) as! PurchaseButtonTableViewCell
			purchaseButtonTableViewCell.productNumber = indexPath.row
			purchaseButtonTableViewCell.productTitle = productTitles.isEmpty ? "" : productTitles[indexPath.row]
			purchaseButtonTableViewCell.productsArray = productsArray
			purchaseButtonTableViewCell.purchaseButton.tag = indexPath.row
			purchaseButtonTableViewCell.purchaseButtonTableViewCellDelegate = self
			return purchaseButtonTableViewCell
		default:
			guard let serviceFooterTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.serviceFooterTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.serviceFooterTableViewCell.identifier)")
			}
			serviceFooterTableViewCell.serviceType = serviceType
			return serviceFooterTableViewCell
		}
	}
}

// MARK: - UITableViewDelegate
extension ProductTableViewController {
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 28
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}

	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
}

// MARK: - KTableViewDataSource
extension ProductTableViewController {
	override func registerCells(for tableView: UITableView) -> [UITableViewCell.Type] {
		return [ServiceFooterTableViewCell.self]
	}
}

// MARK: - PurchaseButtonTableViewCellDelegate
extension ProductTableViewController: PurchaseButtonTableViewCellDelegate {
	func purchaseButtonPressed(_ sender: UIButton) {
		if self.productsArray.count != 0 {
			WorkflowController.shared.isSignedIn {
				KStoreObserver.shared.purchase(product: self.productsArray[sender.tag]) { alertType, _, _ in
					self.presentAlertController(title: "", message: alertType.message)
				}
			}
		}
	}
}

// MARK: - Types
extension ProductTableViewController {
	/**
		Set of available product table view sections.
	*/
	enum Section: Int, CaseIterable {
		// MARK: - Cases
		/// The heder section of the table view.
		case header

		/// The body section of the table view.
		case body

		/// The heder section of the table view.
		case footer
	}
}
