//
//  PurchaseButtonCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

protocol PurchaseButtonCollectionViewCellDelegate: AnyObject {
	func purchaseButtonCollectionViewCell(_ cell: PurchaseButtonCollectionViewCell, didPressButton button: UIButton)
}

class PurchaseButtonCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var purchaseButton: KTintedButton!
	@IBOutlet weak var productImageView: UIImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Properties
	weak var delegate: PurchaseButtonCollectionViewCellDelegate?
	var product: Product!

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(using product: Product?, isPurchased: Bool = false) {
		guard let product = product else {
			return
		}
		self.product = product

		switch product.type {
		case .consumable, .nonConsumable:
			self.productImageView.image = store.image(for: product.id)
			self.primaryLabel.text = product.displayName
			self.secondaryLabel.text = product.description
			self.purchaseButton.setTitle(product.displayPrice, for: .normal)
		case .autoRenewable, .nonRenewable:
			self.primaryLabel.text = product.displayName
			self.productImageView.image = #imageLiteral(resourceName: "Promotional/In App Purchases/Subscriptions/\(store.title(for: product.id))")
			self.secondaryLabel.text = store.saving(for: product)
			if let subscription = product.subscription {
				self.updateSubscriptionPurchaseButton(for: product, withSubscription: subscription, isPurchased: isPurchased)
			}
		default: break
		}
	}

	/// Updates the purchase button with the relevant information.
	fileprivate func updateSubscriptionPurchaseButton(for product: Product, withSubscription subscription: Product.SubscriptionInfo, isPurchased: Bool) {
		let displayPrice = product.displayPrice
		let displayUnit = subscription.subscriptionPeriod.shortDisplayUnit
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center

		let purchaseTitle = NSMutableAttributedString()
		purchaseTitle.append(NSAttributedString(string: displayPrice, attributes: [.font: UIFont.preferredFont(forTextStyle: .headline), .paragraphStyle: paragraphStyle]))
		purchaseTitle.append(NSAttributedString(string: "/\(displayUnit)", attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1), .paragraphStyle: paragraphStyle]))

		if isPurchased {
			self.purchaseButton.isEnabled = false
			self.purchaseButton.alpha = 0.70
		} else {
			self.purchaseButton.isEnabled = true
			self.purchaseButton.alpha = 1.0
		}

		self.purchaseButton.setAttributedTitle(purchaseTitle, for: .normal)
	}

	// MARK: - IBActions
	@IBAction func purchaseButtonPressed(_ sender: UIButton) {
		self.delegate?.purchaseButtonCollectionViewCell(self, didPressButton: sender)
	}
}
