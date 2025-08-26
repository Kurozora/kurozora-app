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
	func purchaseFooterCollectionViewCell(_ cell: PurchaseFooterCollectionViewCell, didPressRestorePurchaseButton button: UIButton) async
	func purchaseFooterCollectionViewCell(_ cell: PurchaseFooterCollectionViewCell, didPressPrivacyButton button: UIButton) async
	func purchaseFooterCollectionViewCell(_ cell: PurchaseFooterCollectionViewCell, didPressTermsOfUseButton button: UIButton) async
}

class PurchaseFooterCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlet
	@IBOutlet weak var restorePurchaseButton: KButton?
	@IBOutlet weak var primaryLabel: KLabel!
	@IBOutlet weak var termsOfUseButton: KButton!
	@IBOutlet weak var privacyButton: KButton!

	// MARK: - Properties
	weak var delegate: PurchaseFooterCollectionViewCellDelegate?

	// MARK: - Functions
	func configureCell(using primaryText: String?, termsOfUseButtonText: String?, privacyButtonText: String?, restorePurchaseButtonText: String?) {
		self.contentView.backgroundColor = .clear

		self.primaryLabel.text = primaryText
		self.termsOfUseButton.setTitle(termsOfUseButtonText, for: .normal)
		self.privacyButton.setTitle(privacyButtonText, for: .normal)
		self.restorePurchaseButton?.setTitle(restorePurchaseButtonText, for: .normal)
	}

	// MARK: - IBActions
	@IBAction func restorePurchaseButtonPressed(_ sender: UIButton) {
		Task {
			await self.delegate?.purchaseFooterCollectionViewCell(self, didPressRestorePurchaseButton: sender)
		}
	}

	@IBAction func termsOfUseButtonPressed(_ sender: UIButton) {
		Task {
			await self.delegate?.purchaseFooterCollectionViewCell(self, didPressTermsOfUseButton: sender)
		}
	}

	@IBAction func privacyButtonPressed(_ sender: UIButton) {
		Task {
			await self.delegate?.purchaseFooterCollectionViewCell(self, didPressPrivacyButton: sender)
		}
	}
}
