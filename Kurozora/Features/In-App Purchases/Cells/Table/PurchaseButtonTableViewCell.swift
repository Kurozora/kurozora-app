//
//  PurchaseButtonTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseButtonTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var purchaseButton: KTintedButton!
	@IBOutlet weak var productImageView: UIImageView!
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Properties
	weak var delegate: PurchaseButtonTableViewCellDelegate?
	var productNumber: Int = 0
	var product: Product! {
		didSet {
			Task {
				await self.configureCell()
			}
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	@MainActor
	func configureCell() async {
		self.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue

		switch product.type {
		case .consumable, .nonConsumable:
			self.productImageView.image = store.image(for: product.id).toImage(withFrameSize: CGRect(x: 0, y: 0, width: 150, height: 150), placeholder: #imageLiteral(resourceName: "Icons/Tip Jar"))
			self.primaryLabel.text = self.product.displayName
			self.secondaryLabel.text = self.product.description
			self.purchaseButton.setTitle(product.displayPrice, for: .normal)
		case .autoRenewable, .nonRenewable:
			self.productImageView.image = #imageLiteral(resourceName: "Promotional/In App Purchases/Subscriptions/\(store.image(for: product.id))")

			if let subscriptionPeriod = product.subscription?.subscriptionPeriod,
			   let firstProduct = store.subscriptions.first {
				let subscriptionDescription: String = subscriptionPeriod.displayUnit + " at " + product.displayPricePerMonth + "mo. Save " + product.priceSaved(comparedTo: firstProduct.pricePerMonth)

				// Configure button title
				if (try? await store.isPurchased(product.id)) ?? false {
					let purchaseTitle = """
					\(product.displayPrice)
					—————
					\(subscriptionPeriod.unitString) ✔︎
					"""
					self.purchaseButton.setTitle(purchaseTitle, for: .normal)
					self.purchaseButton.isEnabled = false
					self.purchaseButton.alpha = 0.70
				} else {
					let purchaseTitle = """
					\(product.displayPrice)
					—————
					\(subscriptionPeriod.unitString)
					"""
					self.purchaseButton.setTitle(purchaseTitle, for: .normal)
					self.purchaseButton.isEnabled = true
					self.purchaseButton.alpha = 1.0
				}

				// If it has an introduction price. For example a week of trial period.
				if let introductoryOffer = product.subscription?.introductoryOffer {
					let subscriptionPeriod = introductoryOffer.period.displayUnit
					let subscriptionTrialPeriod = "Includes " + subscriptionPeriod + " free trial!"

					if productNumber == 0 {
						self.secondaryLabel.text = subscriptionTrialPeriod
					} else {
						self.secondaryLabel.text = """
						\(subscriptionTrialPeriod)
						(\(subscriptionDescription))
						"""
					}
				}
			}
		default: break
		}
	}

	// MARK: - IBActions
	@IBAction func purchaseButtonPressed(_ sender: UIButton) {
		Task {
			await self.delegate?.purchaseButtonTableViewCell(self, didPressButton: sender)
		}
	}
}
