//
//  InformationButtonCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 22/06/2020.
//  Copyright © 2020 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class InformationButtonCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: KTintedLabel!
	@IBOutlet weak var iconImageView: UIImageView!
	@IBOutlet weak var separatorView: SecondarySeparatorView!

	// MARK: - Properties
	var studioInformationSection: StudioInformationSection?
	var studioElement: StudioElement? {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		self.titleLabel.text = studioInformationSection?.stringValue
		self.iconImageView.image = studioInformationSection?.imageValue
	}

	// MARK: - IBActions
	@IBAction func websiteButtonPressed(_ sender: KButton) {
		guard let websiteURL = studioElement?.websiteURL?.url else { return }
		UIApplication.shared.kOpen(websiteURL)
	}
}
