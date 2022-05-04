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
	@IBOutlet weak var episodeImageView: BannerImageView!
	@IBOutlet weak var userProgressLabel: UILabel!

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()

		// Configure title
		self.titleLabel.textColor = .white

		// Configure user progress
		self.userProgressLabel.text = show.attributes.informationStringShort

		// Configure episode preview
		if let episodeBackgroundColor = self.show.attributes.banner?.backgroundColor {
			self.episodeImageView.backgroundColor = UIColor(hexString: episodeBackgroundColor)
		}
		self.show.attributes.bannerImage(imageView: self.episodeImageView)

		// Configure poster
		self.posterShadowView?.applyShadow()
	}
}
