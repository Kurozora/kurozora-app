//
//  SubscriptionButtonTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/07/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import StoreKit

protocol SubscriptionButtonTableViewCellDelegate: class {
	func subscriptionButtonPressed(_ sender: UIButton)
}

class SubscriptionButtonTableViewCell: UITableViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var subscriptionButton: UIButton! {
		didSet {
			subscriptionButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			subscriptionButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var subtextLabel: UILabel! {
		didSet {
			subtextLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	// MARK: - Properties
	weak var subscriptionButtonTableViewCellDelegate: SubscriptionButtonTableViewCellDelegate?
	var subscriptionItem: SKProduct?
	var subscriptionDetail: [String: String] = [:] {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let subscriptionItem = subscriptionItem else { return }

		if #available(iOS 11.2, *) {
			subscriptionButton.setTitle("\(subscriptionItem.priceLocaleFormatted) / \(subscriptionItem.subscriptionPeriod?.fullString ?? "Unknown")", for: .normal)
		} else {
			subscriptionButton.setTitle("\(subscriptionItem.priceLocaleFormatted) / \(subscriptionDetail["unit"] ?? "Unknown")", for: .normal)
		}
		subtextLabel.text = subscriptionDetail["subtext"]
	}

	// MARK: - IBActions
	@IBAction func subscriptionButtonPressed(_ sender: UIButton) {
		subscriptionButtonTableViewCellDelegate?.subscriptionButtonPressed(sender)
	}
}
