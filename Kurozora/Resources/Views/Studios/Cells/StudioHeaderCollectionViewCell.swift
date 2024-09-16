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

	// MARK: - Functions
	/// Configure the cell with the given studio object.
	///
	/// - Parameter studio: The `Studio` object used to configure the cell.
	func configure(using studio: Studio) {
		self.nameLabel.text = studio.attributes.name

		if let foundingYear = studio.attributes.foundedAt {
			self.foundedLabel.text = "Founded on " + foundingYear.formatted(date: .abbreviated, time: .omitted)
		} else {
			self.foundedLabel.text = nil
		}

		if studio.attributes.profile != nil {
			studio.attributes.profileImage(imageView: self.logoImageView)
		} else {
			studio.attributes.logoImage(imageView: self.logoImageView)
		}
	}
}
