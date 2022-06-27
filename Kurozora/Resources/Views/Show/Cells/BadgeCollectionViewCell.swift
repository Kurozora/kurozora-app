//
//  BadgeCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 16/01/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class BadgeCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var primaryLabel: KLabel?
	@IBOutlet weak var primaryImageView: UIImageView?
	@IBOutlet weak var secondaryLabel: KSecondaryLabel!

	// MARK: - Initializers
	override func awakeFromNib() {
		super.awakeFromNib()

		self.primaryImageView?.theme_tintColor = KThemePicker.tintColor.rawValue
	}

	// MARK: - Properties
	var showDetailBage: ShowDetail.Badge = .rating
	var show: Show! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		self.primaryLabel?.text = showDetailBage.primaryInformation(from: self.show)
		self.primaryImageView?.image = showDetailBage.primaryImage(from: self.show)
		self.secondaryLabel.text = showDetailBage.secondaryInformation(from: self.show)
	}
}