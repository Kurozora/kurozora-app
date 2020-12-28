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

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		self.titleLabel.textColor = .white
		self.userProgressLabel.text = show.attributes.informationStringShort
		self.episodeImageView.image = show.attributes.bannerImage
		self.posterShadowView?.applyShadow()
	}
}
