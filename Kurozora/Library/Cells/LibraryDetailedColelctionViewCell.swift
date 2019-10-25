//
//  LibraryDetailedColelctionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit

class LibraryDetailedColelctionViewCell: LibraryCollectionViewCell {
	@IBOutlet weak var episodeImageView: UIImageView!
	@IBOutlet weak var userProgressLabel: UILabel!
    @IBOutlet weak var watchedButton: UIButton!

	override func layoutSubviews() {
		super.layoutSubviews()

		self.applyShadow()
		posterShadowView?.applyShadow()
	}

	// MARK: - Functions
	override func configureCell() {
		super.configureCell()
		guard let showDetailsElement = showDetailsElement else { return }

		self.userProgressLabel?.text = "TV · ✓ \(showDetailsElement.episodes ?? 0) · ☆ \(showDetailsElement.averageRating ?? 0)"

		if let bannerImage = showDetailsElement.banner {
			self.episodeImageView?.setImage(with: bannerImage, placeholder: #imageLiteral(resourceName: "placeholder_banner_image"))
		}

		self.contentView.applyShadow()
	}
}
