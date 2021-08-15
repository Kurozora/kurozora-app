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
	/// The array containing the purchasable products.
	var products: [Product] {
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

	// Refresh control
	var _prefersRefreshControlDisabled = false {
		didSet {
			self.setNeedsRefreshControlAppearanceUpdate()
		}
	}
	override var prefersRefreshControlDisabled: Bool {
		return _prefersRefreshControlDisabled
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

		// Disable refresh control
		self._prefersRefreshControlDisabled = true

		// Disable activity indicator
		self._prefersActivityIndicatorHidden = true

		// Warn the user if they are not allowed to make purchases.
		if !AppStore.canMakePayments {
			self.presentAlertController(title: "Can't Purchase", message: KStoreObserver.AlertType.disabled.message)
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
			return products.count
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
			purchaseButtonTableViewCell.product = products[indexPath.row]
			purchaseButtonTableViewCell.delegate = self
			return purchaseButtonTableViewCell
		default:
			guard let serviceFooterTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.serviceFooterTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.serviceFooterTableViewCell.identifier)")
			}
			serviceFooterTableViewCell.delegate = self
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
	func purchaseButtonTableViewCell(_ cell: PurchaseButtonTableViewCell, didPressButton button: UIButton) async {
		guard WorkflowController.shared.isSignedIn() else { return }
		await self.purchase(cell.product)
	}

	func purchase(_ product: Product) async {
		do {
			if try await store.purchase(product) != nil {
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		} catch StoreError.failedVerification {
			DispatchQueue.main.async {
				self.presentAlertController(title: "Faild purchase", message: "Your purchase could not be verified by the App Store.")
			}
		} catch {
			print("Failed purchase: \(error)")
		}
	}
}

// MAKR: - ServiceFooterTableViewCellDelegate
extension ProductTableViewController: ServiceFooterTableViewCellDelegate {
	func serviceFooterTableViewCell(_ cell: ServiceFooterTableViewCell, didPressButton button: UIButton) {
		if let legalKNavigationViewController = R.storyboard.legal.instantiateInitialViewController() {
			self.present(legalKNavigationViewController, animated: true)
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
