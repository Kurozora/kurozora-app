//
//  LibraryDetailedCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class LibraryDetailedCollectionViewCell: LibraryBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var episodeImageView: UIImageView!
	@IBOutlet weak var userProgressLabel: UILabel!

	// MARK: - View
	override func layoutSubviews() {
		super.layoutSubviews()

		self.applyShadow()
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		guard let showDetailsElement = showDetailsElement else { return }

		self.titleLabel.textColor = .white

		self.userProgressLabel?.text = showDetailsElement.informationStringShort

		if let bannerImage = showDetailsElement.banner {
			self.episodeImageView?.setImage(with: bannerImage, placeholder: R.image.placeholders.showBanner()!)
		}

		posterShadowView?.applyShadow()
	}
}
