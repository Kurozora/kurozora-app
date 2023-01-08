//
//  PurchaseFooterCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 31/12/2022.
//  Copyright © 2022 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

protocol PurchaseFooterCollectionViewCellDelegate: AnyObject {
	func purchaseFooterCollectionViewCell(_ cell: PurchaseFooterCollectionViewCell, didPressPrivacyButton button: UIButton)
}

class PurchaseFooterCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlet
	@IBOutlet weak var restorePurchaseButton: KButton?
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var privacyButtonPressed: UIButton!

	// MARK: - Properties
	weak var delegate: PurchaseFooterCollectionViewCellDelegate?

	// MARK: - Functions
	func configureCell(using primaryText: String?, privacyButtonText: ThemeAttributedStringPicker?, restorePurchaseButtonText: String?) {
		self.contentView.backgroundColor = .clear

		self.primaryLabel.text = primaryText
		self.privacyButtonPressed.theme_setAttributedTitle(privacyButtonText, forState: .normal)
		self.restorePurchaseButton?.setTitle(restorePurchaseButtonText, for: .normal)
	}

	// MARK: - IBActions
	@IBAction func restorePurchaseButtonPressed(_ sender: UIButton) {
		Task {
			await store.restore()
		}
	}

	@IBAction func privacyButtonPressed(_ sender: UIButton) {
		self.delegate?.purchaseFooterCollectionViewCell(self, didPressPrivacyButton: sender)
	}
}
