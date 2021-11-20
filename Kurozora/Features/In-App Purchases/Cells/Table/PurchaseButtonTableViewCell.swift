//
//  PurchaseButtonTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseButtonTableViewCell: KTableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var purchaseButton: KTintedButton!
	@IBOutlet weak var productImageView: UIImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Properties
	weak var delegate: PurchaseButtonTableViewCellDelegate?
	var productNumber: Int = 0
	var purchased: Bool = false
	var product: Product! {
		didSet {
			self.configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	override func configureCell() {
		switch product.type {
		case .consumable, .nonConsumable:
			self.productImageView.image = store.image(for: product.id)
			self.primaryLabel.text = self.product.displayName
			self.secondaryLabel.text = self.product.description
			self.purchaseButton.setTitle(product.displayPrice, for: .normal)
		case .autoRenewable, .nonRenewable:
			self.primaryLabel.text = self.product.displayName
			self.productImageView.image = #imageLiteral(resourceName: "Promotional/In App Purchases/Subscriptions/\(store.title(for: product.id))")
			self.secondaryLabel.text = store.saving(for: product)
			if let subscription = product.subscription {
				self.updateSubscriptionPurchaseButton(withSubscription: subscription)
			}
		default: break
		}
	}

	/// Updates the purchase button with the relevant information.
	fileprivate func updateSubscriptionPurchaseButton(withSubscription subscription: Product.SubscriptionInfo) {
		let displayPrice = self.product.displayPrice
		let displayUnit = subscription.subscriptionPeriod.shortDisplayUnit
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center

		let purchaseTitle = NSMutableAttributedString()
		purchaseTitle.append(NSAttributedString(string: displayPrice, attributes: [.font: UIFont.preferredFont(forTextStyle: .headline), .paragraphStyle: paragraphStyle]))
		purchaseTitle.append(NSAttributedString(string: "/\(displayUnit)", attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1), .paragraphStyle: paragraphStyle]))

		if self.purchased {
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
		self.delegate?.purchaseButtonTableViewCell(self, didPressButton: sender)
	}
}
