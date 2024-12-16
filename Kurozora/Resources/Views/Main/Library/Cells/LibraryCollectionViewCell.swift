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
	@IBOutlet weak var selectionImageOverlayView: UIImageView!

	// MARK: - Properties
	lazy var literatureMask: CALayer = {
		let literatureMask = CALayer()
		literatureMask.contents =  UIImage(named: "book_mask")?.cgImage
		literatureMask.frame = self.posterImageView.bounds
		return literatureMask
	}()

	/// Determines whether to show selection icon.
	var showSelectionIcon: Bool = false

	override var isSelected: Bool {
		didSet {
			self.setNeedsLayout()
		}
	}

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.showSelectionIcon = false
	}

	override func layoutSubviews() {
		self.selectionImageOverlayView.isHidden = !self.showSelectionIcon
		self.selectionImageOverlayView.image = self.isSelected ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
	}

	// MARK: - Functions
	/// Configure the cell with the given show's details.
	///
	/// - Parameters:
	///    - show: The show to configure the cell with.
	///    - showSelectionIcon: A boolean value indicating whether to show selection icon.
	func configure(using show: Show, showSelectionIcon: Bool) {
		// Configure selection icon
		self.showSelectionIcon = showSelectionIcon

		// Configure title
		self.titleLabel.text = show.attributes.title

		// Configure poster
		if let backgroundColor = show.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: backgroundColor)
		}
		show.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView?.applyCornerRadius(10.0)
		self.posterImageView?.layer.mask = nil
		self.posterImageOverlayView.isHidden = true
	}

	/// Configure the cell with the given literature's details.
	///
	/// - Parameters:
	///    - literature: The literature to configure the cell with.
	///    - showSelectionIcon: A boolean value indicating whether to show selection icon.
	func configure(using literature: Literature, showSelectionIcon: Bool) {
		// Configure selection icon
		self.showSelectionIcon = showSelectionIcon

		// Configure title
		self.titleLabel.text = literature.attributes.title

		// Configure poster
		if let backgroundColor = literature.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: backgroundColor)
		}
		literature.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView?.applyCornerRadius(0.0)
		self.posterImageView?.layer.mask = self.literatureMask
		self.posterImageOverlayView.isHidden = false
	}

	/// Configure the cell with the given game's details.
	///
	/// - Parameters:
	///    - game: The game to configure the cell with.
	///    - showSelectionIcon: A boolean value indicating whether to show selection icon.
	func configure(using game: Game, showSelectionIcon: Bool) {
		// Configure selection icon
		self.showSelectionIcon = showSelectionIcon

		// Configure title
		self.titleLabel.text = game.attributes.title

		// Configure poster
		if let backgroundColor = game.attributes.poster?.backgroundColor {
			self.posterImageView.backgroundColor = UIColor(hexString: backgroundColor)
		}
		game.attributes.posterImage(imageView: self.posterImageView)

		self.posterImageView?.applyCornerRadius(18.0)
		self.posterImageView?.layer.mask = nil
		self.posterImageOverlayView.isHidden = true
	}
}
