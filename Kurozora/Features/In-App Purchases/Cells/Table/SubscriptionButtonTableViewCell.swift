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
		guard let purchaseItem = purchaseItem else { return }

		if #available(iOS 11.2, *) {
			purchaseButton.setTitle("\(purchaseItem.priceLocaleFormatted) / \(purchaseItem.subscriptionPeriod?.fullString ?? "Unknown")", for: .normal)
		} else {
			purchaseButton.setTitle("\(purchaseItem.priceLocaleFormatted) / \(subscriptionDetail["unit"] ?? "Unknown")", for: .normal)
		}
		primaryLabel.text = subscriptionDetail["subtext"]
	}
}
