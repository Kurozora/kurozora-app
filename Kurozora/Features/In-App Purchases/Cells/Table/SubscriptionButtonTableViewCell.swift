//
//  SubscriptionButtonTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionButtonTableViewCell: PurchaseButtonTableViewCell {
	// MARK: - Properties
	var subscriptionDetail: [String: String] = [:] {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let purchaseItem = productsArray?[productNumber] else { return }
		let trialDuration = subscriptionDetail["trial"] ?? ""

		if let subscriptionPeriod = purchaseItem.subscriptionPeriod, let firstProductPrice = productsArray?.first?.price {
			// Configure purchase button
			purchaseButton.setTitle("\(purchaseItem.priceLocaleFormatted) / \(subscriptionPeriod.fullString)", for: .normal)

			// Configure primary label
			if productNumber == 0 {
				primaryLabel.text = trialDuration
			} else {
				primaryLabel.text = """
				\(trialDuration)
				(\(subscriptionPeriod.fullString.lowercased()) at \(purchaseItem.pricePerMonthString)/mo. Save \(purchaseItem.priceSaved(comparedTo: firstProductPrice)))
				"""
			}
		}
	}
}
