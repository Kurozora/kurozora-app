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

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell(with show: Show?, showDetailBadge: ShowDetail.Badge) {
		guard let show = show else { return }

		self.primaryLabel?.text = showDetailBadge.primaryInformation(from: show)
		self.primaryImageView?.image = showDetailBadge.primaryImage(from: show)
		self.secondaryLabel.text = showDetailBadge.secondaryInformation(from: show)
	}

	func configureCell(with literature: Literature?, literatureDetailBadge: LiteratureDetail.Badge) {
		guard let literature = literature else { return }

		self.primaryLabel?.text = literatureDetailBadge.primaryInformation(from: literature)
		self.primaryImageView?.image = literatureDetailBadge.primaryImage(from: literature)
		self.secondaryLabel.text = literatureDetailBadge.secondaryInformation(from: literature)
	}
}
