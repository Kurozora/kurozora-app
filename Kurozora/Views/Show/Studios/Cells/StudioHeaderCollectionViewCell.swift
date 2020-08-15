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
	@IBOutlet weak var logoImageView: StudioLogoImageView!
	@IBOutlet weak var nameLabel: KLabel!
	@IBOutlet weak var foundedLabel: KLabel!

	// MARK: - Properties
	var studio: Studio! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	func configureCell() {
		self.nameLabel.text = studio.attributes.name
		let foundingYear = studio.attributes.founded
		self.foundedLabel.text = foundingYear != nil ? "Founded on " + (foundingYear?.mediumDate)! : ""
		self.logoImageView.image = studio.attributes.logoImage
	}
}
