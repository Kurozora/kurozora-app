//
//  SmallLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import UIKit
import KurozoraKit

class SmallLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var scoreLabel: KTintedLabel!
	@IBOutlet weak var scoreView: KCosmosView!
	@IBOutlet weak var posterImageOverlay: UIImageView!

	// MARK: - Properties
	lazy var literatureMask: CALayer = {
		let literatureMask = CALayer()
		literatureMask.contents =  UIImage(named: "book_mask")?.cgImage
		literatureMask.frame = self.posterImageView?.bounds ?? .zero
		return literatureMask
	}()

	// MARK: - Functions
	override func configure(using show: Show?) {
		super.configure(using: show)

		// Configure tagline
		self.ternaryLabel?.text = nil

		let ratingAverage = show?.attributes.stats?.ratingAverage ?? 0.0
		self.scoreView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"

		self.scoreView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0

		self.posterImageView?.applyCornerRadius(10.0)
		self.posterImageView?.layer.mask = nil
		self.posterImageOverlay.isHidden = true
	}

	override func configure(using literature: Literature?) {
		super.configure(using: literature)

		// Configure tagline
		self.ternaryLabel?.text = nil

		// Configure score
		let ratingAverage = literature?.attributes.stats?.ratingAverage ?? 0.0
		self.scoreView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"

		self.scoreView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0

		// Configure poster image
		self.posterImageView?.applyCornerRadius(0.0)
		self.posterImageView?.layer.mask = self.literatureMask
		self.posterImageOverlay.isHidden = false
	}

	/// Configures the cell using a `RelatedShow` object.
	///
	/// - Parameter relatedShow: The `RelatedShow` object used to configure the cell.
	func configure(using relatedShow: RelatedShow) {
		self.configure(using: relatedShow.show)

		// Configure relation
		self.ternaryLabel?.text = relatedShow.attributes.relation.name

		// Configure score
		self.scoreView.isHidden = true
		self.scoreLabel.isHidden = true

		// Configure poster image
		self.posterImageView?.applyCornerRadius(10.0)
		self.posterImageView?.layer.mask = nil
		self.posterImageOverlay.isHidden = true
	}

	/// Configures the cell using a `RelatedLiterature` object.
	///
	/// - Parameter relatedLiterature: The `RelatedLiterature` object used to configure the cell.
	func configure(using relatedLiterature: RelatedLiterature) {
		self.configure(using: relatedLiterature.literature)

		// Configure relation
		self.ternaryLabel?.text = relatedLiterature.attributes.relation.name

		// Configure score
		self.scoreView.isHidden = true
		self.scoreLabel.isHidden = true

		// Configure poster image
		self.posterImageView?.applyCornerRadius(0.0)
		self.posterImageView?.layer.mask = self.literatureMask
		self.posterImageOverlay.isHidden = false
	}
}
