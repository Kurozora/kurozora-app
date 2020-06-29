//
//  StudioHeaderCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class StudioHeaderCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var logoImageView: CircularImageView!
	@IBOutlet weak var nameLabel: KLabel!
	@IBOutlet weak var foundedLabel: KLabel!

	// MARK: - Properties
	var studioElement: StudioElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		guard let studioElement = studioElement else { return }

		self.nameLabel.text = studioElement.name
		if let foundedString = studioElement.founded {
			self.foundedLabel.text = !foundedString.isEmpty ? "Founded on " + foundedString.mediumDate : ""
		}

		if let studioLogo = studioElement.logo {
			self.logoImageView.setImage(with: studioLogo, placeholder: R.image.placeholders.showBanner()!)
		}
	}
}
