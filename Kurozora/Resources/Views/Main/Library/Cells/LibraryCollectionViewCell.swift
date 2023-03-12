//
//  LibraryCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 08/05/2018.
//  Copyright © 2018 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class LibraryBaseCollectionViewCell: UICollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var titleLabel: KLabel!
	@IBOutlet weak var posterShadowView: UIView?
	@IBOutlet weak var posterImageView: PosterImageView!
	@IBOutlet weak var posterImageOverlayView: UIImageView!

	// MARK: - Properties
	let mangaMask: UIImageView? = UIImageView(image: UIImage(named: "book_mask"))

	// MARK: - Functions
	/// Configure the cell with the given show's details.
	func configure(using show: Show) {
		// Configure title
		self.titleLabel.text = show.attributes.title

		// Configure poster
		if let backgroundColor = show.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: backgroundColor)
		}
		show.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView?.mask = nil
		self.posterImageView?.applyCornerRadius(10.0)
		self.posterImageOverlayView.isHidden = true
	}

	/// Configure the cell with the given literature's details.
	func configure(using literature: Literature) {
		// Configure title
		self.titleLabel.text = literature.attributes.title

		// Configure poster
		if let backgroundColor = literature.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: backgroundColor)
		}
		literature.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView?.mask = self.mangaMask
		self.posterImageView?.applyCornerRadius(0.0)
		self.posterImageOverlayView.isHidden = false
	}

	/// Configure the cell with the given game's details.
	func configure(using game: Game) {
		// Configure title
		self.titleLabel.text = game.attributes.title

		// Configure poster
		if let backgroundColor = game.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: backgroundColor)
		}
		game.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView?.mask = nil
		self.posterImageView?.applyCornerRadius(18.0)
		self.posterImageOverlayView.isHidden = true
	}
}
