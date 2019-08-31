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

	override func configureCell() {
		super.configureCell()
		guard let libraryElement = libraryElement else { return }
		guard let showTitle = libraryElement.title else { return }

		self.userProgressLabel?.hero.id = "library_\(showTitle)_progress"
		self.userProgressLabel?.text = "TV ·  \(libraryElement.episodeCount ?? 0) ·  \(libraryElement.averageRating ?? 0)"

		self.episodeImageView?.hero.id = "library_\(showTitle)_banner"
		if let backgroundThumbnail = libraryElement.backgroundThumbnail, backgroundThumbnail != "" {
			let backgroundThumbnailUrl = URL(string: backgroundThumbnail)
			let resource = ImageResource(downloadURL: backgroundThumbnailUrl!)
			self.episodeImageView?.kf.indicatorType = .activity
			self.episodeImageView?.kf.setImage(with: resource, placeholder: #imageLiteral(resourceName: "placeholder_banner"), options: [.transition(.fade(0.2))])
		} else {
			self.episodeImageView?.image = #imageLiteral(resourceName: "placeholder_banner")
		}

		self.contentView.applyShadow()
	}
}
