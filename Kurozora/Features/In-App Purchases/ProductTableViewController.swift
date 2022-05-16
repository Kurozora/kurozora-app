//
//  ProductTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 13/04/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

protocol ProductTableViewControllerDelegate: AnyObject {
	/// Updates the subscription status of the purchaser.
	/// Override this method with your implementation to update the subscription status before the view is (re)loaded.
	@discardableResult
	func updateSubscriptionStatus() async -> Bool
}

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

	/// The `ProductTableViewControllerDelegate` object.
	weak var productTableViewControllerDelegate: ProductTableViewControllerDelegate?

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
extension ProductTableViewController { }

// MARK: - UITableViewDelegate
extension ProductTableViewController {
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 28
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
	func purchaseButtonTableViewCell(_ cell: PurchaseButtonTableViewCell, didPressButton button: UIButton) {
		guard WorkflowController.shared.isSignedIn() else { return }
		Task {
			await self.purchase(cell.product)
		}
	}

	func purchase(_ product: Product) async {
		do {
			let transaction = try await store.purchase(product)
			if transaction != nil {
//				KService.verifyReceipt() { result in
//					switch result {
//					case .success(let receipts)
//					case .failure: break
//					}
//				}
				await self.productTableViewControllerDelegate?.updateSubscriptionStatus()
				DispatchQueue.main.async { [weak self] in
					guard let self = self else { return }
					self.tableView.reloadData()
				}
			}
		} catch StoreError.failedVerification {
			DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }
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
