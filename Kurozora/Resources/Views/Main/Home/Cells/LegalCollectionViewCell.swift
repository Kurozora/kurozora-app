//
//  LegalCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 19/04/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class LegalCollectionViewCell: KCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var separatorView: SeparatorView!
	@IBOutlet weak var termsConditionsLabel: KSecondaryLabel!
	@IBOutlet weak var chevronButtonView: UIButton! {
		didSet {
			self.chevronButtonView.theme_tintColor = KThemePicker.subTextColor.rawValue
		}
	}

	// MARK: - Properties
	override var isSkeletonEnabled: Bool {
		return false
	}
}

// MARK: - Measurement
extension LegalCollectionViewCell {
	/// Returns the item that measures the legal row.
	///
	/// - Returns: The item that measures the legal row.
	static func measurableItem() -> CellHeightMeasurer.Item {
		return CellHeightMeasurer.Item(cellType: LegalCollectionViewCell.self) { _ in }
	}
}
