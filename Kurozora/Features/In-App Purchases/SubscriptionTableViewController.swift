//
//  SubscriptionTableViewController.swift
//  Kurozora
//
//  Created by Khoren Katklian on 24/06/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionTableViewController: ProductTableViewController {
	// MARK: - Properties
	var currentSubscription: Product?
	var status: Product.SubscriptionInfo.Status?

	override var products: [Product] {
		return store.subscriptions.filter { $0.id != currentSubscription?.id }
	}

	override var previewImages: [UIImage?] {
		return [R.image.promotional.inAppPurchases.icons(), R.image.promotional.inAppPurchases.gifs()]
	}

	override var serviceType: ServiceType? {
		return .subscription
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.productTableViewControllerDelegate = self

		Task {
			if let subscriptionUpdateStatus = await self.productTableViewControllerDelegate?.updateSubscriptionStatus(), subscriptionUpdateStatus {
				self.tableView.reloadData()
			}
		}
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UITableViewDataSource
extension SubscriptionTableViewController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.allCases.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section(rawValue: section) else { return 0 }
		switch section {
		case .header:
			return 1
		case .currentSubscription:
			return self.currentSubscription != nil ? 2 : 0
		case .subscriptions:
			return self.products.count
		case .footer:
			return 1
		}
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .header:
			guard let productPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productPreviewTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productPreviewTableViewCell.identifier)")
			}
			productPreviewTableViewCell.previewImages = previewImages
			return productPreviewTableViewCell
		case .currentSubscription:
			switch indexPath.item {
			case 0:
				guard let purchaseButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseButtonTableViewCell, for: indexPath) else {
					fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.purchaseButtonTableViewCell.identifier)")
				}
				purchaseButtonTableViewCell.delegate = self
				purchaseButtonTableViewCell.productNumber = indexPath.row
				purchaseButtonTableViewCell.purchased = true
				purchaseButtonTableViewCell.product = currentSubscription
				return purchaseButtonTableViewCell
			default:
				guard let purchaseStatusTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseStatusTableViewCell, for: indexPath) else {
					fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.purchaseStatusTableViewCell.identifier)")
				}
				purchaseStatusTableViewCell.product = self.currentSubscription
				purchaseStatusTableViewCell.status = self.status
				return purchaseStatusTableViewCell
			}
		case .subscriptions:
			guard let purchaseButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.purchaseButtonTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.purchaseButtonTableViewCell.identifier)")
			}
			purchaseButtonTableViewCell.delegate = self
			purchaseButtonTableViewCell.productNumber = indexPath.row
			purchaseButtonTableViewCell.purchased = false
			purchaseButtonTableViewCell.product = products[indexPath.row]
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

// MARK: -  UITableViewDelegate
extension SubscriptionTableViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section(rawValue: indexPath.section) {
		case .header:
			return view.frame.height > 260 ? 260 : view.frame.height * 0.33
		default:
			return UITableView.automaticDimension
		}
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}

	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		switch Section(rawValue: section) {
		case .currentSubscription:
			if self.currentSubscription == nil {
				return CGFloat.leastNormalMagnitude
			}
			fallthrough
		default:
			return super.tableView(tableView, heightForFooterInSection: section)
		}
	}
}

// MARK: - ProductTableViewControllerDelegate
extension SubscriptionTableViewController: ProductTableViewControllerDelegate {
	@MainActor
	func updateSubscriptionStatus() async -> Bool {
		do {
			// This app has only one subscription group so products in the subscriptions
			// array all belong to the same group. The statuses returned by
			// `product.subscription.status` apply to the entire subscription group.
			guard let product = store.subscriptions.first,
				  let statuses = try await product.subscription?.status else {
					  return false
				  }

			var highestStatus: Product.SubscriptionInfo.Status? = nil
			var highestProduct: Product? = nil

			// Iterate through `statuses` for this subscription group and find
			// the `Status` with the highest level of service which isn't
			// expired or revoked.
			for status in statuses {
				switch status.state {
				case .expired, .revoked:
					continue
				default:
					let renewalInfo = try store.checkVerified(status.renewalInfo)

					guard let newSubscription = store.subscriptions.first(where: { $0.id == renewalInfo.currentProductID }) else {
						continue
					}

					guard let currentProduct = highestProduct else {
						highestStatus = status
						highestProduct = newSubscription
						continue
					}

					let highestTier = store.tier(for: currentProduct.id)
					let newTier = store.tier(for: renewalInfo.currentProductID)

					if newTier > highestTier {
						highestStatus = status
						highestProduct = newSubscription
					}
				}
			}

			status = highestStatus
			currentSubscription = highestProduct
			return true
		} catch {
			print("Could not update subscription status \(error)")
			return false
		}
	}
}

// MARK: - Section
extension SubscriptionTableViewController {
	/**
		Set of available subscription table view sections.
	*/
	enum Section: Int, CaseIterable {
		// MARK: - Cases
		/// The heder section of the table view.
		case header

		/// The current supscription section of the table view
		case currentSubscription

		/// The subscriptions section of the table view.
		case subscriptions

		/// The heder section of the table view.
		case footer
	}
}
