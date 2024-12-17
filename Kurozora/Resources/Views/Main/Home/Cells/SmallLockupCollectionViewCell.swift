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
	@IBOutlet weak var broadcastLabel: BroadcastLabel!
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

	// MARK: - View
	override func prepareForReuse() {
		super.prepareForReuse()

		self.broadcastLabel.stopCountdown()
		self.broadcastLabel.text = ""
	}

	// MARK: - Functions
	override func configure(using show: Show?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: show, rank: rank, scheduleIsShown: scheduleIsShown)

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

		// Configure broadcast label
		self.broadcastLabel.text = ""
			if show?.attributes.status.name == "Currently Airing",
			   let broadcastDate = show?.attributes.broadcastDate {
		   let nextBroadcastAt = show?.attributes.nextBroadcastAt {

			self.broadcastLabel.startCountdown(to: nextBroadcastAt, duration: show?.attributes.durationCount ?? 0)
		}
	}

	override func configure(using literature: Literature?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: literature, rank: rank, scheduleIsShown: scheduleIsShown)

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

		// Configure broadcast label
		self.broadcastLabel.text = ""
		if scheduleIsShown {
			if literature?.attributes.status.name == "Currently Publishing",
			   let publicationDate = literature?.attributes.publicationDate {

				self.broadcastLabel.startCountdown(to: publicationDate, duration: literature?.attributes.durationCount ?? 0)
			}
		}
	}

	/// Configures the cell using a `RelatedShow` object.
	///
	/// - Parameter relatedShow: The `RelatedShow` object used to configure the cell.
	func configure(using relatedShow: RelatedShow) {
		self.configure(using: relatedShow.show)

		// Configure relation
		self.ternaryLabel?.text = relatedShow.attributes.relation.name

		// Configure poster image
		self.posterImageView?.applyCornerRadius(10.0)
		self.posterImageView?.layer.mask = nil
		self.posterImageOverlay.isHidden = true

		// Configure broadcast label
		self.broadcastLabel.text = nil
	}

	/// Configures the cell using a `RelatedLiterature` object.
	///
	/// - Parameter relatedLiterature: The `RelatedLiterature` object used to configure the cell.
	func configure(using relatedLiterature: RelatedLiterature) {
		self.configure(using: relatedLiterature.literature)

		// Configure relation
		self.ternaryLabel?.text = relatedLiterature.attributes.relation.name

		// Configure poster image
		self.posterImageView?.applyCornerRadius(0.0)
		self.posterImageView?.layer.mask = self.literatureMask
		self.posterImageOverlay.isHidden = false

		// Configure broadcast label
		self.broadcastLabel.text = nil
	}
}
