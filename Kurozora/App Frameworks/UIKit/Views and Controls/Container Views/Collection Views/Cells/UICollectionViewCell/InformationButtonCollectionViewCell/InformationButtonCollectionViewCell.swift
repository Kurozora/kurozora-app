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
	var studioDetailsInformationSection: StudioDetailsInformationSection = .website
	var studio: Studio! {
		didSet {
			configureCell()
		}
	}

	// MARK: - Functions
	/// Configure the cell with the given details.
	fileprivate func configureCell() {
		self.titleLabel.text = studioDetailsInformationSection.stringValue
		self.iconImageView.image = studioDetailsInformationSection.imageValue
		self.separatorView.isHidden = self.studioDetailsInformationSection == .website
	}

	// MARK: - IBActions
	@IBAction func websiteButtonPressed(_ sender: KButton) {
		guard let websiteURL = studio.attributes.websiteUrl?.url else { return }
		UIApplication.shared.kOpen(websiteURL)
	}
}
