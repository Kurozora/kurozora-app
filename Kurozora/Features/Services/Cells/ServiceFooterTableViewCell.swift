//
//  ServiceFooterTableViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 04/05/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import SwiftTheme

/// The visual representation of a single promotional footer row in a table view.
///
/// A `ServiceFooterTableViewCell` object is a specialized type of view that displays footer information about the content of a table view.
///
/// - Tag: ServiceFooterTableViewCell
class ServiceFooterTableViewCell: KTableViewCell {
	// MARK: - IBOutlet
	@IBOutlet weak var restorePurchaseButton: KButton?
	@IBOutlet weak var descriptionLabel: KLabel!
	@IBOutlet weak var privacyButton: UIButton!

	// MARK: - Properties
	weak var delegate: ServiceFooterTableViewCellDelegate?

	/// The service type used to populate the cell.
	var serviceType: ServiceType? {
		didSet {
			self.reloadCell()
		}
	}

	// MARK: - Nib
	override func awakeFromNib() {
		super.awakeFromNib()
		self.configureCell()
	}

	// MARK: - Cell
	override func sharedInit() {
		super.sharedInit()
		self.contentView.backgroundColor = .clear
	}

	override func configureCell() {
		self.privacyButton.theme_setAttributedTitle(Trans.visitPrivacyPolicy, forState: .normal)
	}

	override func reloadCell() {
		self.descriptionLabel.text = serviceType?.footerStringValue
	}

	// MARK: - IBActions
	@IBAction func restorePurchaseButtonPressed(_ sender: UIButton) {
		KStoreObserver.shared.restorePurchase()
	}

	@IBAction func privacyButtonPressed(_ sender: UIButton) {
		self.delegate?.serviceFooterTableViewCell(self, didPressButton: sender)
	}
}
