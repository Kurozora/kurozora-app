//
//  LibraryDetailedCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 20/08/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class LibraryDetailedCollectionViewCell: LibraryBaseCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var episodeImageView: BannerImageView!
	@IBOutlet weak var userProgressLabel: UILabel!

	// MARK: - Functions
	override func configure(using show: Show) {
		super.configure(using: show)

		// Configure title
		self.titleLabel.textColor = .white

		// Configure user progress
		self.userProgressLabel.text = show.attributes.informationStringShort

		// Configure episode preview
		if let episodeBackgroundColor = show.attributes.banner?.backgroundColor {
			self.episodeImageView.backgroundColor = UIColor(hexString: episodeBackgroundColor)
		}
		show.attributes.bannerImage(imageView: self.episodeImageView)

		// Configure poster
		self.posterShadowView?.applyShadow()
	}

	override func configure(using literature: Literature) {
		super.configure(using: literature)

		// Configure title
		self.titleLabel.textColor = .white

		// Configure user progress
		self.userProgressLabel.text = literature.attributes.informationStringShort

		// Configure episode preview
		if let episodeBackgroundColor = literature.attributes.banner?.backgroundColor {
			self.episodeImageView.backgroundColor = UIColor(hexString: episodeBackgroundColor)
		}
		literature.attributes.bannerImage(imageView: self.episodeImageView)

		// Configure poster
		self.posterShadowView?.applyShadow()
	}

	override func configure(using game: Game) {
		super.configure(using: game)

		// Configure title
		self.titleLabel.textColor = .white

		// Configure user progress
		self.userProgressLabel.text = game.attributes.informationStringShort

		// Configure episode preview
		if let episodeBackgroundColor = game.attributes.banner?.backgroundColor {
			self.episodeImageView.backgroundColor = UIColor(hexString: episodeBackgroundColor)
		}
		game.attributes.bannerImage(imageView: self.episodeImageView)

		// Configure poster
		self.posterShadowView?.applyShadow()
	}
}
