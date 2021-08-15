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

		Task {
			await self.updateSubscriptionStatus()
			self.tableView.reloadData()
		}
	}

	// MARK: - Functions
	@MainActor
	func updateSubscriptionStatus() async {
		do {
			// This app has only one subscription group so products in the subscriptions
			// array all belong to the same group. The statuses returned by
			// `product.subscription.status` apply to the entire subscription group.
			guard let product = store.subscriptions.first,
				  let statuses = try await product.subscription?.status else {
					  return
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
		} catch {
			print("Could not update subscription status \(error)")
		}
	}

	// MARK: - IBActions
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
}

// MARK: - UITableViewDataSource
extension SubscriptionTableViewController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section(rawValue: indexPath.section) {
		case .header:
			guard let productPreviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.productPreviewTableViewCell, for: indexPath) else {
				fatalError("Cannot dequeue resuable cell with identifier \(R.reuseIdentifier.productPreviewTableViewCell.identifier)")
			}
			productPreviewTableViewCell.previewImages = previewImages
			return productPreviewTableViewCell
		default:
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
}

// MARK: -  UITableViewDelegate
extension SubscriptionTableViewController {
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section(rawValue: indexPath.section) {
		case .header:
			let cellRatio: CGFloat = UIDevice.isLandscape ? 1.5 : 3
			return view.frame.height / cellRatio
		default:
			return UITableView.automaticDimension
		}
	}

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return CGFloat.leastNormalMagnitude
	}
}
