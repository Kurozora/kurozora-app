//
//  PurchaseButtonTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

protocol PurchaseButtonTableViewCellDelegate: class {
	func purchaseButtonPressed(_ sender: UIButton)
}

class PurchaseButtonTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var bubbleView: UIView? {
		didSet {
			bubbleView?.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}
	@IBOutlet weak var purchaseButton: UIButton! {
		didSet {
			purchaseButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			purchaseButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var primaryLabel: KLabel!

	// MARK: - Properties
	weak var purchaseButtonTableViewCellDelegate: PurchaseButtonTableViewCellDelegate?
	var productNumber: Int = 0
	var productTitle: String = ""
	var productsArray: [SKProduct]? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		guard let purchaseItem = productsArray?[productNumber] else { return }
		let localPrice = purchaseItem.priceLocaleFormatted

		// Global configs.
		self.purchaseButton.tag = productNumber

		// If the product is a subscription.
		if let subscriptionPeriod = purchaseItem.subscriptionPeriod, let firstProductPrice = productsArray?.first?.price {
			let subscriptionDescription: String = subscriptionPeriod.fullString.lowercased() + " at " + purchaseItem.pricePerMonthLocalized + "mo. Save " + purchaseItem.priceSaved(comparedTo: firstProductPrice)

			self.purchaseButton.setTitle("\(localPrice) / \(subscriptionPeriod.fullString)", for: .normal)

			// If it has an introduction price. For example a week of trial period.
			if let introductoryPrice = purchaseItem.introductoryPrice {
				let subscriptionPeriod = introductoryPrice.subscriptionPeriod.fullString.lowercased()
				let subscriptionTrialPeriod = "Includes " + subscriptionPeriod + " free trial!"
				if productNumber == 0 {
					self.primaryLabel.text = subscriptionTrialPeriod
				} else {
					self.primaryLabel.text = """
					\(subscriptionTrialPeriod)
					(\(subscriptionDescription))
					"""
				}
			}
		} else { // If the product is a one time purchase.
			self.purchaseButton.setTitle(localPrice, for: .normal)
			self.primaryLabel.text = self.productTitle
		}
	}

	// MARK: - IBActions
	@IBAction func purchaseButtonPressed(_ sender: UIButton) {
		purchaseButtonTableViewCellDelegate?.purchaseButtonPressed(sender)
	}
}
