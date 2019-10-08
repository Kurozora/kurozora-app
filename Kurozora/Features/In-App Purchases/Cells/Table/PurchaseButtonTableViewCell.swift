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
	@IBOutlet weak var bubbleView: UIView! {
		didSet {
			bubbleView.theme_backgroundColor = KThemePicker.tableViewCellBackgroundColor.rawValue
		}
	}
	@IBOutlet weak var purchaseButton: UIButton! {
		didSet {
			purchaseButton.theme_backgroundColor = KThemePicker.tintColor.rawValue
			purchaseButton.theme_setTitleColor(KThemePicker.tintedButtonTextColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var primaryLabel: UILabel! {
		didSet {
			primaryLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}

	// MARK: - Properties
	weak var purchaseButtonTableViewCellDelegate: PurchaseButtonTableViewCellDelegate?
	var productsArray: [SKProduct]?
	var productNumber: Int = 0
	var purchaseDetail: String = "" {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		guard let purchaseItem = productsArray?[productNumber] else { return }

		purchaseButton.setTitle("\(purchaseItem.priceLocaleFormatted)", for: .normal)
		primaryLabel.text = purchaseDetail
	}

	// MARK: - IBActions
	@IBAction func purchaseButtonPressed(_ sender: UIButton) {
		purchaseButtonTableViewCellDelegate?.purchaseButtonPressed(sender)
	}
}
