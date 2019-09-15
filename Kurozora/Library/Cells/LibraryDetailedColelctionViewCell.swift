//
//  LibraryDetailedColelctionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import Kingfisher

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
		guard let showTitle = showDetailsElement.title else { return }

		self.userProgressLabel?.hero.id = "library_\(showTitle)_progress"
		self.userProgressLabel?.text = "TV · ✓ \(showDetailsElement.episodes ?? 0) · ☆ \(showDetailsElement.averageRating ?? 0)"

		self.episodeImageView?.hero.id = "library_\(showTitle)_banner"
		if let bannerThumbnail = showDetailsElement.banner, !bannerThumbnail.isEmpty {
			let bannerThumbnailUrl = URL(string: bannerThumbnail)
			let resource = ImageResource(downloadURL: bannerThumbnailUrl!)
			self.episodeImageView?.kf.indicatorType = .activity
			self.episodeImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner_image"), options: [.transition(.fade(0.2))])
		} else {
			self.episodeImageView?.image = #imageLiteral(resourceName: "placeholder_banner_image")
		}

		self.contentView.applyShadow()
	}
}
