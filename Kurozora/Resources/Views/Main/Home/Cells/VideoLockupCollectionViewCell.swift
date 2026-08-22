//
//  VideoLockupCollectionViewCell.swift
//  Kurozora
//
//  Created by Khoren Katklian on 23/10/2019.
//  Copyright © 2019 Kurozora. All rights reserved.
//

import KurozoraKit
import UIKit

class VideoLockupCollectionViewCell: BaseLockupCollectionViewCell {
	// MARK: - IBOutlets
	@IBOutlet weak var bannerContainerView: UIView!
	@IBOutlet weak var bannerBorderView: BorderView!
	@IBOutlet weak var posterContainerView: UIView!
	@IBOutlet weak var posterBorderView: BorderView!
	@IBOutlet weak var scoreLabel: KTintedLabel!
	@IBOutlet weak var scoreView: KCosmosView!
	@IBOutlet weak var taglineLabel: KLabel!
	@IBOutlet weak var trailerPlayerView: KTrailerPlayerView!

	// MARK: - Properties
	/// The poster's height constraint.
	private var posterHeightConstraint: NSLayoutConstraint?

	/// The poster's aspect ratio constraint.
	private var posterAspectConstraint: NSLayoutConstraint?

	/// The URL of the preferred trailer.
	var preferredTrailerURL: String?

	// MARK: - View
	override func awakeFromNib() {
		super.awakeFromNib()

		self.posterHeightConstraint = self.posterContainerView.constraints.first { constraint in
			constraint.firstAttribute == .height && constraint.secondItem == nil
		}
		self.posterAspectConstraint = self.posterContainerView.constraints.first { constraint in
			constraint.firstAttribute == .width && constraint.secondAttribute == .height
		}

		self.bannerContainerView.backgroundColor = .clear
		self.bannerContainerView.layer.cornerRadius = 22
		self.bannerImageView?.applyCornerRadius(22)
		self.bannerImageView?.layer.borderWidth = 0
		self.bannerBorderView.cornerRadius = 22

		self.posterContainerView.layer.cornerRadius = 22
		self.posterImageView?.applyCornerRadius(22)
		self.posterImageView?.layer.borderWidth = 0
		self.posterBorderView.cornerRadius = 22

		self.trailerPlayerView.layerCornerRadius = 22
		self.trailerPlayerView.layer.masksToBounds = true
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		self.preferredTrailerURL = nil
		self.trailerPlayerView.stopTrailer()
	}

	// MARK: - Functions
	override func configure(using show: Show?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: show, rank: rank, scheduleIsShown: scheduleIsShown)
		self.applyPosterShape(height: 150.0, multiplier: 2.0 / 3.0)
		guard let show = show else { return }

		// Configure genres
		self.secondaryLabel?.text = show.attributes.genres?.localizedJoined()

		// Configure tagline
		self.taglineLabel?.text = show.attributes.tagline

		// Configure score
		let ratingAverage = show.attributes.stats?.ratingAverage ?? 0.0
		self.scoreView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"

		self.scoreView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0

		// Configure trailer
		self.trailerPlayerView.loadTrailer(fromURL: self.preferredTrailerURL ?? show.attributes.videoUrl)
	}

	override func configure(using game: Game?, rank: Int? = nil, scheduleIsShown: Bool = false) {
		super.configure(using: game, rank: rank, scheduleIsShown: scheduleIsShown)
		self.applyPosterShape(height: 100.0, multiplier: 1.0)
		guard let game = game else { return }

		// Configure genres
		self.secondaryLabel?.text = game.attributes.genres?.localizedJoined()

		// Configure tagline
		self.taglineLabel?.text = game.attributes.tagline

		// Configure score
		let ratingAverage = game.attributes.stats?.ratingAverage ?? 0.0
		self.scoreView.rating = ratingAverage
		self.scoreLabel.text = "\(ratingAverage)"

		self.scoreView.isHidden = ratingAverage == 0.0
		self.scoreLabel.isHidden = ratingAverage == 0.0

		// Configure trailer
		self.trailerPlayerView.loadTrailer(fromURL: self.preferredTrailerURL ?? game.attributes.videoUrl)
	}

	/// Reshapes the poster.
	///
	/// - Parameters:
	///    - height: The height the poster is pinned to.
	///    - multiplier: The poster's width relative to its height.
	private func applyPosterShape(height: CGFloat, multiplier: CGFloat) {
		self.posterHeightConstraint?.constant = height

		guard let aspectConstraint = self.posterAspectConstraint, aspectConstraint.multiplier != multiplier else { return }

		let replacement = NSLayoutConstraint(
			item: self.posterContainerView as Any,
			attribute: .width,
			relatedBy: .equal,
			toItem: self.posterContainerView,
			attribute: .height,
			multiplier: multiplier,
			constant: 0.0
		)
		aspectConstraint.isActive = false
		replacement.isActive = true
		self.posterAspectConstraint = replacement
	}
}
