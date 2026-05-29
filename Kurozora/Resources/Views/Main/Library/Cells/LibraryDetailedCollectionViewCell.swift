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
	@IBOutlet weak var bannerContainerView: UIView!
	@IBOutlet weak var episodeImageView: BannerImageView!
	@IBOutlet weak var episodeBorderView: BorderView!
	@IBOutlet weak var shadowImageView: UIImageView?
	@IBOutlet weak var userProgressLabel: UILabel!

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.bannerContainerView.layer.cornerRadius = 22
		self.episodeImageView?.applyCornerRadius(22)
		self.episodeImageView?.layer.borderWidth = 0
		self.episodeBorderView.cornerRadius = 22

		self.shadowImageView?.layer.cornerRadius = 22
		self.shadowImageView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		self.shadowImageView?.layer.masksToBounds = true
	}

	// MARK: - Functions
	override func configure(using show: Show, showSelectionIcon: Bool) {
		super.configure(using: show, showSelectionIcon: showSelectionIcon)

		// Configure title
		self.primaryLabel.textColor = .white

		// Configure user progress
		self.userProgressLabel.text = show.attributes.informationStringShort

		// Configure episode preview
		if let episodeBackgroundColor = show.attributes.banner?.backgroundColor {
			self.episodeImageView.backgroundColor = UIColor(hexString: episodeBackgroundColor)
		}
		show.attributes.bannerImage(imageView: self.episodeImageView)

		// Configure poster
		self.posterShadowView?.applyShadow()
		self.posterImageView?.applyCornerRadius(12.0)
		self.posterBorderView?.cornerRadius = 12.0
		self.posterBorderView?.isHidden = false
	}

	override func configure(using literature: Literature, showSelectionIcon: Bool) {
		super.configure(using: literature, showSelectionIcon: showSelectionIcon)

		// Configure title
		self.primaryLabel.textColor = .white

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

	override func configure(using game: Game, showSelectionIcon: Bool) {
		super.configure(using: game, showSelectionIcon: showSelectionIcon)

		// Configure title
		self.primaryLabel.textColor = .white

		// Configure user progress
		self.userProgressLabel.text = game.attributes.informationStringShort

		// Configure episode preview
		if let episodeBackgroundColor = game.attributes.banner?.backgroundColor {
			self.episodeImageView.backgroundColor = UIColor(hexString: episodeBackgroundColor)
		}
		game.attributes.bannerImage(imageView: self.episodeImageView)

		// Configure poster
		self.posterShadowView?.applyShadow()
		self.posterImageView?.applyCornerRadius(12.0)
		self.posterBorderView?.cornerRadius = 12.0
		self.posterBorderView?.isHidden = false
	}
}
