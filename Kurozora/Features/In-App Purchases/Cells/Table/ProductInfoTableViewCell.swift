//
//  ProductInfoTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 06/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class ProductInfoTableViewCell: UITableViewCell {
	@IBOutlet weak var restorePurchaseButton: UIButton? {
		didSet {
			restorePurchaseButton?.theme_setTitleColor(KThemePicker.tintColor.rawValue, forState: .normal)
		}
	}
	@IBOutlet weak var purchaseInfoLabel: UILabel! {
		didSet {
			purchaseInfoLabel.theme_textColor = KThemePicker.textColor.rawValue
		}
	}
	@IBOutlet weak var privacyButton: UIButton! {
		didSet {
			let paragraphStyle = NSMutableParagraphStyle()
			paragraphStyle.alignment = .center

			// Normal state
			let attributedString = NSMutableAttributedString(string: "For more information, please visit our ", attributes: [.foregroundColor: KThemePicker.subTextColor.colorValue, .paragraphStyle: paragraphStyle])
			attributedString.append(NSAttributedString(string: "Privacy Policy", attributes: [.foregroundColor: KThemePicker.tintColor.colorValue, .paragraphStyle: paragraphStyle]))
			privacyButton.setAttributedTitle(attributedString, for: .normal)
		}
	}

	// MARK: - IBActions
	@IBAction func restorePurchaseButtonPressed(_ sender: UIButton) {
		KStoreObserver.shared.restorePurchase()
	}
}
